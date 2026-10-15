# Temporal Java scaffolds

Starting points, not templates to paste. Detect the SDK, Spring Boot, and Java versions first and
match the repository's existing wiring style.

## Saga workflow

Each compensation activity looks up provider state by the same key before acting, so a forward step
that timed out is reconciled instead of blindly reversed, and "nothing to undo" is a no-op.
Notification sits outside the saga: a failed email must never refund a captured payment.

```java
// @WorkflowImpl(taskQueues = "payment-saga") only with temporal-spring-boot-starter auto-discovery
public class PaymentSagaWorkflowImpl implements PaymentSagaWorkflow {

    private final PaymentActivities payments = Workflow.newActivityStub(PaymentActivities.class,
        ActivityOptions.newBuilder()
            .setStartToCloseTimeout(Duration.ofSeconds(30))
            .setRetryOptions(RetryProfiles.LIMITED)
            .build());

    private final NotificationActivities notifications = Workflow.newActivityStub(
        NotificationActivities.class,
        ActivityOptions.newBuilder()
            .setStartToCloseTimeout(Duration.ofSeconds(10))
            .setRetryOptions(RetryProfiles.DEFAULT)
            .build());

    @Override
    public PaymentResult execute(PaymentCommand cmd) {
        var key = Workflow.getInfo().getWorkflowId();
        var saga = new Saga(new Saga.Options.Builder().setParallelCompensation(false).build());
        CaptureResult capture;
        try {
            saga.addCompensation(payments::releaseHold, key);
            var hold = payments.placeHold(key, cmd);

            saga.addCompensation(payments::reverseAuthorization, key);
            var auth = payments.authorize(key, hold);

            saga.addCompensation(payments::refundCapture, key);
            capture = payments.capture(key, auth);
        } catch (ActivityFailure | CanceledFailure e) {
            Workflow.newDetachedCancellationScope(saga::compensate).run();
            throw e;
        }
        notifications.paymentCaptured(key, cmd.customerId(), capture.receipt());
        return new PaymentResult(capture.id(), capture.amount());
    }
}
```

## Retry options

Values are starting points: set attempts and intervals from the provider's documented rate limits
and the workflow's business deadline. `setDoNotRetry` takes error types (the `ApplicationFailure`
type string, or an exception class name), never `ApplicationFailure` itself.

```java
public final class RetryProfiles {

    /** External writes: few attempts, provider-aware backoff, business rejections never retried. */
    public static final RetryOptions LIMITED = RetryOptions.newBuilder()
        .setInitialInterval(Duration.ofSeconds(2))
        .setBackoffCoefficient(2.0)
        .setMaximumInterval(Duration.ofSeconds(30))
        .setMaximumAttempts(3)
        .setDoNotRetry("CARD_DECLINED", "INSUFFICIENT_FUNDS")
        .build();

    /** Internal idempotent writes, bounded by the business deadline. */
    public static final RetryOptions DEFAULT = RetryOptions.newBuilder()
        .setInitialInterval(Duration.ofSeconds(1))
        .setBackoffCoefficient(2.0)
        .setMaximumInterval(Duration.ofMinutes(1))
        .setMaximumAttempts(10)
        .build();

    /** Transient read failures only; capped so retries cannot amplify an incident. */
    public static final RetryOptions READ = RetryOptions.newBuilder()
        .setInitialInterval(Duration.ofMillis(500))
        .setBackoffCoefficient(2.0)
        .setMaximumInterval(Duration.ofSeconds(10))
        .setMaximumAttempts(5)
        .build();

    private RetryProfiles() {}
}
```

## Activity implementation

```java
@Component  // add @ActivityImpl(taskQueues = "payment-saga") with the starter
public class PaymentActivitiesImpl implements PaymentActivities {

    private final PaymentGateway gateway;   // the project's existing client

    public PaymentActivitiesImpl(PaymentGateway gateway) { this.gateway = gateway; }

    @Override
    public HoldResult placeHold(String key, PaymentCommand cmd) {
        return gateway.placeHold(key + ":hold", cmd);           // provider dedupes on the key
    }

    @Override
    public void releaseHold(String key) {
        gateway.findHold(key + ":hold")                         // reconcile first
            .ifPresent(hold -> gateway.releaseHold(hold.id(), key + ":release"));
    }
}
```

## Spring wiring

With `temporal-spring-boot-starter`, configure the connection and auto-discovery in application
config and annotate implementations; no manual worker beans. Confirm property names against the
installed starter version.

```yaml
spring:
  temporal:
    namespace: ${TEMPORAL_NAMESPACE}
    connection:
      target: ${TEMPORAL_TARGET}
    workers-auto-discovery:
      packages: com.example.payments.workflow
```

Without the starter, register workers explicitly and start the factory after the context is ready:

```java
@Configuration
public class TemporalConfig {

    @Bean
    WorkflowServiceStubs workflowServiceStubs(TemporalProperties props) {
        return WorkflowServiceStubs.newServiceStubs(
            WorkflowServiceStubsOptions.newBuilder().setTarget(props.target()).build());
    }

    @Bean
    WorkflowClient workflowClient(WorkflowServiceStubs stubs, TemporalProperties props) {
        return WorkflowClient.newInstance(stubs,
            WorkflowClientOptions.newBuilder().setNamespace(props.namespace()).build());
    }

    @Bean(destroyMethod = "shutdown")
    WorkerFactory workerFactory(WorkflowClient client, PaymentActivitiesImpl payments,
                                NotificationActivitiesImpl notifications) {
        var factory = WorkerFactory.newInstance(client);
        var worker = factory.newWorker("payment-saga");
        worker.registerWorkflowImplementationTypes(PaymentSagaWorkflowImpl.class);
        worker.registerActivitiesImplementations(payments, notifications);
        return factory;
    }

    @Bean
    ApplicationRunner startTemporalWorkers(WorkerFactory factory) {
        return args -> factory.start();
    }
}
```

## Test harness

`TestWorkflowEnvironment` needs no Temporal server and skips time. Mock activities with
`withoutAnnotations()`, as the Temporal testing docs recommend, so the mock registers cleanly.

```java
class PaymentSagaWorkflowTest {

    private final PaymentActivities payments =
        mock(PaymentActivities.class, withSettings().withoutAnnotations());
    private final NotificationActivities notifications =
        mock(NotificationActivities.class, withSettings().withoutAnnotations());
    private TestWorkflowEnvironment env;
    private WorkflowClient client;

    @BeforeEach
    void setUp() {
        env = TestWorkflowEnvironment.newInstance();
        var worker = env.newWorker("payment-saga");
        worker.registerWorkflowImplementationTypes(PaymentSagaWorkflowImpl.class);
        worker.registerActivitiesImplementations(payments, notifications);
        env.start();
        client = env.getWorkflowClient();
    }

    @AfterEach
    void tearDown() { env.close(); }

    @Test
    void compensates_in_reverse_order_when_capture_is_declined() {
        given(payments.placeHold(any(), any())).willReturn(new HoldResult("hold-1"));
        given(payments.authorize(any(), any())).willReturn(new AuthResult("auth-1"));
        given(payments.capture(any(), any()))
            .willThrow(ApplicationFailure.newNonRetryableFailure("declined", "CARD_DECLINED"));

        var workflow = client.newWorkflowStub(PaymentSagaWorkflow.class,
            WorkflowOptions.newBuilder().setTaskQueue("payment-saga").setWorkflowId("pay-1").build());

        assertThatThrownBy(() -> workflow.execute(aPaymentCommand()))
            .isInstanceOf(WorkflowFailedException.class);

        var order = inOrder(payments);
        order.verify(payments).capture(any(), any());
        order.verify(payments).refundCapture("pay-1");      // registered before capture; no-op here
        order.verify(payments).reverseAuthorization("pay-1");
        order.verify(payments).releaseHold("pay-1");
        verifyNoInteractions(notifications);
    }
}
```
