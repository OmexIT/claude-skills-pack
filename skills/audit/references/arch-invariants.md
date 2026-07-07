# Clean-architecture invariants (Java + Spring + Modulith)

## Invariants

**1. Dependency direction (non-negotiable)**
`api → application → domain ← infrastructure`
- `domain` imports NOTHING from application/infrastructure/api/Spring.
- `application` imports domain only (plus Spring for `@Service`, `@Transactional`).
- `infrastructure` implements domain/application ports; never referenced the other way.
- `api` imports application only; never touches domain or infrastructure directly.

**2. Transaction boundaries**
- `@Transactional` only on application-layer service methods — never repositories or controllers.
- Reads marked `@Transactional(readOnly = true)`.
- Never on private methods (Spring can't proxy them).
- `this.otherMethod()` where the callee is `@Transactional` bypasses the proxy — flag it.

**3. Thin controllers** — parse request, call service, map response. No loops over entities,
no aggregation, no business decisions. ~15 lines max per handler.

**4. No entity exposure** — request/response DTOs are separate records; never bind to or
return an entity/aggregate from a `@RestController`. MapStruct or manual mapping.

**5. Circuit breakers on external calls** — every external HTTP/queue/DB call wrapped in
Resilience4j `@CircuitBreaker` with a deterministic fallback (cached value or fast 503).

**6. Value objects over primitives** — Money, Email, PhoneNumber, TenantId, typed IDs
(`PaymentId` not raw `Long`). Primitives allowed only at the infrastructure boundary.

**7. Domain events for state changes** — aggregate changes emit events; cross-module
consumers use `@ApplicationModuleListener`, in-module use `@EventListener`.

**8. Modulith boundaries enforced** — `@ApplicationModule` declares dependencies;
`ApplicationModules.verify()` runs in a test that fails the build; `package-info.java`
documents each module's purpose and ports.

## Greppable anti-pattern table

| Pattern | Detection | Severity |
|---|---|---|
| Spring imports in `domain/` | grep `org.springframework` | CRITICAL |
| JPA/JDBC imports in `domain/` | grep `jakarta.persistence` / `org.springframework.data` | CRITICAL |
| `@Transactional` on controllers | grep in api package | CRITICAL |
| Repository injected in controller | grep `Repository` in api package | CRITICAL |
| Controller returning entities | grep `return <entity>` in `@RestController` classes | HIGH |
| `@Transactional` on private methods | grep `private.*@Transactional` (adjacent lines) | HIGH |
| Proxy bypass via `this.` to transactional method | static read | HIGH |
| Missing circuit breaker on `RestClient`/`WebClient` | HTTP call without `@CircuitBreaker` | HIGH |
| Cross-module static calls | grep static calls across module packages | HIGH |
| `BigDecimal amount` in domain signatures | grep | MEDIUM |
| Raw `Long id`/`String id` in domain | grep | MEDIUM |
| `catch (Exception e)` in services | grep | MEDIUM |

## ArchUnit starter (adapt package root)

```java
@AnalyzeClasses(packages = "<root-package>")
class ArchitectureTest {
    @ArchTest
    static final ArchRule domain_is_framework_free =
        classes().that().resideInAPackage("..domain..")
            .should().onlyDependOnClassesThat().resideInAnyPackage(
                "..domain..", "java..", "org.slf4j..");

    @ArchTest
    static final ArchRule controllers_only_in_api =
        classes().that().areAnnotatedWith(RestController.class)
            .should().resideInAPackage("..api..");

    @ArchTest
    static final ArchRule no_module_cycles =
        slices().matching("<root-package>.(*)..").should().beFreeOfCycles();
}
```

Setup: see `archunit-setup.md`. Per-invariant good/bad examples: `clean-architecture-patterns.md`.
Repeat offenders → propose the matching ArchUnit rule so CI enforces the invariant permanently.
