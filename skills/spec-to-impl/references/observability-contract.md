# Observability Contract Reference

This document defines the observability standards that every implementation agent must follow. The OBS agent produces a feature-specific version of this contract in Wave 1, customized to the spec's requirements.

---

## 1. Structured Logging

### Format: JSON via logstash-logback-encoder (Spring Boot) or framework equivalent

**Required fields per log line:**

| Field | Source | Example |
|---|---|---|
| `timestamp` | Auto (ISO 8601) | `2026-03-20T14:30:00.123Z` |
| `level` | Logger | `INFO`, `WARN`, `ERROR` |
| `logger` | Class name | `com.example.payment.PaymentService` |
| `message` | Developer | `Payment processing completed` |
| `traceId` | OpenTelemetry MDC | `abc123def456` |
| `spanId` | OpenTelemetry MDC | `789ghi012` |
| `service` | Config | `payment-service` |
| `version` | Config | `1.2.0` |
| `environment` | Config | `production` |

**Context fields (via MDC — added per request):**

| Field | Source | When |
|---|---|---|
| `userId` | Auth token | Every authenticated request |
| `tenantId` | Auth token / header | Every multi-tenant request |
| `requestId` | X-Request-ID header | Every HTTP request |
| `operationName` | Developer | Business operations |
| `correlationId` | Event header | Async message processing |

### Log Level Semantics (strict — no noise)

| Level | When to use | Production enabled |
|---|---|---|
| `ERROR` | Unrecoverable: data corruption, security events, payment failures, unhandled exceptions | Yes |
| `WARN` | Recoverable: SLA breach, deprecation usage, retry succeeded, circuit breaker open | Yes |
| `INFO` | State transitions and business events only: `payment.completed`, `user.created`, `order.shipped` | Yes |
| `DEBUG` | Method entry/exit, variable state, SQL parameters — development/troubleshooting only | No (disabled in prod) |

**Anti-patterns (will be flagged in review):**
- `log.info("Processing request")` — too generic, no context, no business value
- `log.debug(object.toString())` — potential PII leak, expensive string concat
- `log.error("Error occurred")` — no exception, no context, useless in investigation
- Logging inside tight loops — performance killer
- Logging sensitive data (passwords, tokens, full card numbers, PII)

### Spring Boot Configuration

```yaml
# application.yml
logging:
  level:
    root: WARN
    com.example: INFO           # application code at INFO
    org.springframework: WARN   # framework at WARN
    org.hibernate.SQL: WARN     # SQL at WARN (use traces for query details)
  pattern:
    console: "%d{ISO8601} [%thread] %-5level %logger{36} [%X{traceId},%X{spanId}] - %msg%n"
```

```xml
<!-- logback-spring.xml for JSON output -->
<configuration>
  <appender name="JSON" class="ch.qos.logback.core.ConsoleAppender">
    <encoder class="net.logstash.logback.encoder.LogstashEncoder">
      <includeMdcKeyName>traceId</includeMdcKeyName>
      <includeMdcKeyName>spanId</includeMdcKeyName>
      <includeMdcKeyName>userId</includeMdcKeyName>
      <includeMdcKeyName>tenantId</includeMdcKeyName>
      <includeMdcKeyName>requestId</includeMdcKeyName>
      <includeMdcKeyName>operationName</includeMdcKeyName>
    </encoder>
  </appender>
  <root level="WARN">
    <appender-ref ref="JSON" />
  </root>
  <logger name="com.example" level="INFO" />
</configuration>
```

---

## 2. Distributed Tracing

### Standard: OpenTelemetry with W3C Trace Context propagation

**Auto-instrumented spans (via Spring Boot Actuator + OpenTelemetry agent):**
- HTTP server requests (inbound)
- HTTP client requests (outbound via RestClient/WebClient)
- Database queries (JDBC)
- Message publish/consume (Kafka, RabbitMQ)

**Custom spans required (developer responsibility):**

| When | How | Attributes |
|---|---|---|
| Business operation >100ms | `@Observed` annotation or `Observation.start()` | `operation.name`, `operation.status` |
| External API call | Wrap in `Observation` | `peer.service`, `http.method`, `http.status_code` |
| Batch processing | Span per batch + span per item | `batch.size`, `batch.item.index` |
| Async handoff | Propagate context via `ContextPropagators` | `messaging.system`, `messaging.destination` |

**Required span attributes:**

| Attribute | Scope | Example |
|---|---|---|
| `http.method` | HTTP spans | `POST` |
| `http.route` | HTTP spans | `/api/v1/payments` |
| `http.status_code` | HTTP spans | `201` |
| `db.system` | DB spans | `postgresql` |
| `db.statement` | DB spans | `SELECT * FROM payments WHERE id = ?` (parameterized, no values) |
| `tenant.id` | All custom spans | `tenant-123` |
| `user.id` | All custom spans | `user-456` |
| `operation.name` | Business spans | `payment.process` |

### Spring Boot Configuration

```yaml
# application.yml
management:
  tracing:
    sampling:
      probability: 1.0          # 100% in dev, tune for production
  otlp:
    tracing:
      endpoint: http://tempo:4318/v1/traces
```

```java
// Custom observation example using Spring Boot 4.x Observation API (Micrometer)
@Service
public class PaymentService {
    private final ObservationRegistry observationRegistry;

    public PaymentResult processPayment(PaymentRequest request) {
        return Observation.createNotStarted("payment.process", observationRegistry)
            .lowCardinalityKeyValue("payment.type", request.type().name())
            .lowCardinalityKeyValue("tenant.id", request.tenantId())
            .observe(() -> doProcessPayment(request));
    }
}
```

---

## 3. Metrics (Micrometer + Prometheus)

### Auto-instrumented (via Spring Boot Actuator):
- `http.server.requests` — rate, errors, duration per endpoint (RED)
- `jvm.*` — memory, threads, GC
- `db.pool.*` — connection pool utilization
- `spring.kafka.*` — consumer lag, message rate

### Custom Business Metrics (developer responsibility):

| Metric Type | Naming Convention | Example | When |
|---|---|---|---|
| Counter | `<domain>.<operation>.count` | `payment.initiated.count` | Every business event |
| Timer | `<domain>.<operation>.duration` | `payment.processing.duration` | Operations with latency SLOs |
| Gauge | `<domain>.<state>.gauge` | `queue.pending.size` | Stateful resources |
| Distribution Summary | `<domain>.<measurement>` | `payment.amount` | Value distributions |

**Required tags on all custom metrics:**

| Tag | Example | Cardinality |
|---|---|---|
| `service` | `payment-service` | Low |
| `version` | `1.2.0` | Low |
| `tenant` | `tenant-123` | Medium (bounded) |
| `status` | `success`, `failure` | Low |
| `error_type` | `timeout`, `validation`, `auth` | Low |

**Anti-patterns:**
- High-cardinality tags (user IDs, request IDs, URLs with path params) — explodes Prometheus storage
- Metrics inside tight loops without sampling
- Unbounded label values (error messages as tags)

### Spring Boot Configuration

```yaml
# application.yml
management:
  endpoints:
    web:
      exposure:
        include: health,info,prometheus,metrics
  metrics:
    tags:
      service: ${spring.application.name}
      version: ${app.version:unknown}
    distribution:
      percentiles-histogram:
        http.server.requests: true
      slo:
        http.server.requests: 50ms,100ms,200ms,500ms,1s
  prometheus:
    metrics:
      export:
        enabled: true
```

```java
// Custom metric example
@Service
public class PaymentService {
    private final MeterRegistry meterRegistry;
    private final Counter paymentCounter;
    private final Timer paymentTimer;

    public PaymentService(MeterRegistry meterRegistry) {
        this.meterRegistry = meterRegistry;
        this.paymentCounter = Counter.builder("payment.initiated.count")
            .description("Number of payment initiations")
            .tag("service", "payment-service")
            .register(meterRegistry);
        this.paymentTimer = Timer.builder("payment.processing.duration")
            .description("Time to process a payment")
            .publishPercentileHistogram()
            .register(meterRegistry);
    }

    public PaymentResult processPayment(PaymentRequest request) {
        return paymentTimer.record(() -> {
            paymentCounter.increment();
            // ... business logic
        });
    }
}
```

---

## 4. Health & Readiness

```yaml
# application.yml
management:
  endpoint:
    health:
      show-details: when-authorized
      probes:
        enabled: true               # enables /health/liveness and /health/readiness
  health:
    db:
      enabled: true
    redis:
      enabled: true
```

**Custom health indicators** for external dependencies:

```java
@Component
public class PaymentGatewayHealthIndicator implements HealthIndicator {
    @Override
    public Health health() {
        // Check external service availability
        boolean reachable = checkPaymentGateway();
        return reachable
            ? Health.up().withDetail("gateway", "reachable").build()
            : Health.down().withDetail("gateway", "unreachable").build();
    }
}
```

---

## 5. Dashboard Specification

Every feature must produce a dashboard spec with these panels:

### Service Overview Dashboard
1. **Request Rate** — `rate(http_server_requests_seconds_count[5m])` by endpoint
2. **Error Rate** — `rate(http_server_requests_seconds_count{status=~"5.."}[5m])` / total
3. **Latency Percentiles** — `histogram_quantile(0.95, rate(http_server_requests_seconds_bucket[5m]))`
4. **Saturation** — JVM heap, DB pool, thread pool utilization

### Business KPI Dashboard
5. **Business Event Rate** — `rate(<domain>_<operation>_count_total[5m])` by type
6. **Business Operation Duration** — `histogram_quantile(0.99, rate(<domain>_<operation>_duration_seconds_bucket[5m]))`
7. **Error Breakdown** — `sum by (error_type) (rate(<domain>_<operation>_count_total{status="failure"}[5m]))`

### Dependency Dashboard
8. **External Service Latency** — outbound HTTP call duration by peer service
9. **External Service Error Rate** — outbound HTTP 5xx by peer service
10. **Database Query Duration** — `histogram_quantile(0.95, rate(db_query_duration_seconds_bucket[5m]))`

### Alert Rules
```yaml
# Critical: Error rate >5% for 5 minutes
- alert: HighErrorRate
  expr: rate(http_server_requests_seconds_count{status=~"5.."}[5m]) / rate(http_server_requests_seconds_count[5m]) > 0.05
  for: 5m
  labels:
    severity: critical

# Warning: p99 latency >1s for 10 minutes
- alert: HighLatency
  expr: histogram_quantile(0.99, rate(http_server_requests_seconds_bucket[5m])) > 1
  for: 10m
  labels:
    severity: warning
```

---

## 6. Framework-Specific Patterns

### Spring Boot 4.x (Java 25)
- Use `spring-boot-starter-actuator` + `micrometer-registry-prometheus`
- Use `opentelemetry-javaagent` or `micrometer-tracing-bridge-otel` for traces
- Use `logstash-logback-encoder` for structured JSON logs
- Use `@Observed` annotation (from `micrometer-observation`) for custom spans + metrics in one annotation
- Use `ObservationRegistry` for programmatic observation
- Java 25: prefer virtual threads (`spring.threads.virtual.enabled=true`) to shrink observation stacks
- Spring Boot 4: JSpecify nullability annotations work across micrometer APIs

### React / Next.js (TypeScript)
- Use `@opentelemetry/api` for browser-side tracing
- Use structured logging via `pino` or `winston` with JSON format
- Use `web-vitals` for frontend performance metrics
- Propagate trace context in API calls via `traceparent` header

### Flutter (Dart)
- Use `dart_opentelemetry` for tracing
- Use structured logging via `logger` package with JSON formatter
- Propagate trace context in HTTP headers via Dio interceptor

### Node.js Backend
- Use `@opentelemetry/sdk-node` for auto-instrumentation
- Use `pino` for structured JSON logging
- Use `prom-client` for Prometheus metrics