# Endpoint scaffold (new resource, house default layout)

Use only when the repo has no neighbouring resource to copy. Adapt names, persistence style, and
test annotations to the detected versions. Shown for Spring Data JDBC on Spring Boot 3.x+.

```text
paymentlink/
  api/             PaymentLinkController, CreatePaymentLinkRequest, PatchPaymentLinkRequest,
                   PaymentLinkResponse
  application/     PaymentLinkService, PaymentLinkNotFoundException
  domain/          PaymentLink
  infrastructure/  PaymentLinkRepository
```

## Controller

The OpenAPI file is the contract; springdoc annotations are optional and must not clash with the
envelope type name.

```java
@RestController
@RequestMapping("/api/v1/payment-links")
public class PaymentLinkController {

    private final PaymentLinkService service;

    public PaymentLinkController(PaymentLinkService service) { this.service = service; }

    @PostMapping
    public ResponseEntity<ApiEnvelope<PaymentLinkResponse>> create(
            @RequestHeader("Idempotency-Key") String idempotencyKey,
            @RequestBody @Valid CreatePaymentLinkRequest request) {
        var created = PaymentLinkResponse.from(service.create(request, idempotencyKey));
        return ResponseEntity.created(URI.create("/api/v1/payment-links/" + created.id()))
            .body(ApiEnvelope.of(created));
    }

    @GetMapping("/{id}")
    public ApiEnvelope<PaymentLinkResponse> get(@PathVariable UUID id) {
        return ApiEnvelope.of(PaymentLinkResponse.from(service.get(id)));
    }

    @GetMapping
    public ApiEnvelope<List<PaymentLinkResponse>> list(
            @RequestParam(required = false) String cursor,
            @RequestParam(defaultValue = "20") @Min(1) @Max(100) int pageSize) {
        var page = service.list(cursor, pageSize);
        return ApiEnvelope.page(page.items().stream().map(PaymentLinkResponse::from).toList(),
            page.nextCursor(), page.hasMore(), pageSize);
    }

    @PatchMapping("/{id}")
    public ApiEnvelope<PaymentLinkResponse> patch(@PathVariable UUID id,
                                                  @RequestBody @Valid PatchPaymentLinkRequest patch) {
        return ApiEnvelope.of(PaymentLinkResponse.from(service.patch(id, patch)));
    }
}
```

## Requests and response

```java
public record CreatePaymentLinkRequest(
    @NotNull @Positive @Digits(integer = 18, fraction = 2) BigDecimal amount,  // scale per currency
    @NotBlank @Size(min = 3, max = 3) String currency,
    @NotBlank @Size(max = 255) String description,
    @NotNull @Future Instant expiresAt) {}

public record PatchPaymentLinkRequest(            // every field optional; null means unchanged
    @Size(max = 255) String description,
    @Future Instant expiresAt) {}

public record PaymentLinkResponse(UUID id, Money amount, String description, Instant expiresAt,
                                  String status, Instant createdAt, Instant updatedAt) {
    public record Money(String amount, String currency) {}

    static PaymentLinkResponse from(PaymentLink link) {
        return new PaymentLinkResponse(link.publicId(),
            new Money(link.amount().toPlainString(), link.currency()),
            link.description(), link.expiresAt(), link.status().name(),
            link.createdAt(), link.updatedAt());
    }
}
```

## Service

`IdempotencyStore` stands for the repo's existing mechanism; it compares a hash of the request and
returns the stored result on an identical replay (see `api-conventions.md`).

```java
@Service
public class PaymentLinkService {

    // repository, idempotency store, TSID and UUIDv7 generators, clock: constructor-injected

    @Transactional
    public PaymentLink create(CreatePaymentLinkRequest request, String idempotencyKey) {
        return idempotency.executeOnce("payment-link:create:" + idempotencyKey, request, () -> {
            var now = clock.instant();
            return repository.save(PaymentLink.create(tsids.next(), uuidV7.next(), request, now));
        });
    }

    @Transactional(readOnly = true)
    public PaymentLink get(UUID publicId) {
        return repository.findByPublicId(publicId)
            .orElseThrow(() -> new PaymentLinkNotFoundException(publicId));
    }

    @Transactional(readOnly = true)
    public CursorPage<PaymentLink> list(String cursor, int pageSize) {
        var after = PageCursor.decode(cursor);          // versioned, signed if clients could tamper
        var rows = repository.findPageAfter(after, pageSize + 1);
        var hasMore = rows.size() > pageSize;
        var items = hasMore ? rows.subList(0, pageSize) : rows;
        var next = hasMore ? PageCursor.encode(items.get(items.size() - 1).publicId()) : null;
        return new CursorPage<>(items, next, hasMore);
    }

    @Transactional
    public PaymentLink patch(UUID publicId, PatchPaymentLinkRequest patch) {
        return repository.save(get(publicId).apply(patch, clock.instant()));
    }
}
```

## Repository

UUIDv7 sorts by creation time and is already public, so it can drive the cursor without leaking the
TSID. Add tenant predicates when the table is tenant-scoped.

```java
public interface PaymentLinkRepository extends ListCrudRepository<PaymentLink, Long> {

    Optional<PaymentLink> findByPublicId(UUID publicId);

    @Query("""
        SELECT * FROM payment_links
         WHERE (CAST(:after AS uuid) IS NULL OR public_id < :after)
         ORDER BY public_id DESC
         LIMIT :limit
        """)
    List<PaymentLink> findPageAfter(@Param("after") UUID after, @Param("limit") int limit);
}
```

## Error handling

Add to the existing `@RestControllerAdvice`; create one only if none exists.

```java
@ExceptionHandler(PaymentLinkNotFoundException.class)
ProblemDetail notFound(PaymentLinkNotFoundException e) {
    var problem = ProblemDetail.forStatusAndDetail(HttpStatus.NOT_FOUND, e.getMessage());
    problem.setType(URI.create("https://errors.example.com/payment-link-not-found"));
    problem.setTitle("Payment link not found");
    return problem;
}
```

Validation failures map `MethodArgumentNotValidException` field errors into the `errors[]`
extension with stable codes (for example `@Positive` to `NEGATIVE`).

## Controller slice test

`@MockitoBean` on Spring Framework 6.2+; `@MockBean` on older Boot versions.

```java
@WebMvcTest(PaymentLinkController.class)
class PaymentLinkControllerTest {

    @Autowired MockMvc mvc;
    @MockitoBean PaymentLinkService service;

    @Test
    void create_returns_201_with_public_id_and_location() throws Exception {
        given(service.create(any(), eq("key-1"))).willReturn(aPaymentLink());

        mvc.perform(post("/api/v1/payment-links").header("Idempotency-Key", "key-1")
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    {"amount":"150.00","currency":"USD","description":"Test","expiresAt":"2099-01-01T00:00:00Z"}
                    """))
            .andExpect(status().isCreated())
            .andExpect(jsonPath("$.data.id").value(aPaymentLink().publicId().toString()))
            .andExpect(header().string("Location", endsWith(aPaymentLink().publicId().toString())));
    }

    @Test
    void negative_amount_returns_problem_details_with_field_error() throws Exception {
        mvc.perform(post("/api/v1/payment-links").header("Idempotency-Key", "key-2")
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    {"amount":"-10","currency":"USD","description":"x","expiresAt":"2099-01-01T00:00:00Z"}
                    """))
            .andExpect(status().isBadRequest())
            .andExpect(jsonPath("$.errors[?(@.field=='amount')].code").value("NEGATIVE"));
    }
}
```

Idempotent replay (same key twice yields one row and the same response) belongs in the
Testcontainers integration test, since it depends on the real store.
