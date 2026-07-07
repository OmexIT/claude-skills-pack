---
name: arch-review
description: >
  Use this skill whenever the user asks for an architectural review of existing code — checking clean architecture boundaries, dependency direction, transaction boundaries, business logic leakage, circuit breaker presence, and value-object/primitive discipline in a Java + Spring Boot + Modulith codebase. ALWAYS trigger on: "review architecture", "arch review", "clean architecture check", "is this well structured", "check module boundaries", "check dependencies", "dependency direction", "domain leakage", "does this follow clean architecture", "check the hexagonal", "ports and adapters check". Implicit triggers: user shows a controller with business logic inline, user shows an entity exposed directly from a REST response, user mentions "this feels messy", user asks about coupling between modules, user wants to know if a refactor is worthwhile. Complements `code-audit` (which is breadth-first code quality) by being a focused architectural-invariants check.
  Stack: Java 25 + Spring Boot 4 + Spring Modulith 2.x + Spring Data JDBC/JPA. Produces a findings report with severity, affected files, proposed fixes, and a dependency direction graph. Uses ArchUnit assertions where possible for machine-checkable invariants, otherwise file-by-file analysis. Can run in "report-only" mode (default) or "fix-plan" mode (generates a ticket-breakdown handoff for remediation).
argument-hint: "[module name or package path] OR nothing for full-module review"
context: fork
agent: general-purpose
effort: high
---

# Architectural Review: Clean Architecture Invariants Skill

Reviews a Java module against clean architecture, hexagonal, and DDD invariants. Produces a findings report with severity and concrete fix suggestions.

---

## Review Workflow

This skill is read-only. It produces a findings report, never inline fixes.

**Invoke this skill** (`arch-review`) to audit a Java module against clean architecture invariants. Produces findings with severity ratings (CRITICAL/HIGH/MEDIUM/LOW) and affected file paths.

**After findings are produced** — for each CRITICAL or HIGH finding:

1. Understand why the violation exists: shortcut, legacy constraint, missing abstraction, unclear boundary, or missing test pressure. Do not skip directly from finding to code change.
2. Turn the findings into a reviewable remediation plan with ordered tickets and dependencies. Use fix-plan mode (see Section 4) to auto-generate ticket skeletons.
3. Chain to an implementation skill for actual code changes:
   - `api-first` for controller/service/DTO restructuring
   - `temporal-workflow` for saga/orchestration extraction
   - `fintech-ledger` for money-code restructuring
   - (domain-appropriate skill per finding)
4. Request a focused code review after fixes are in place, before merging.
5. If remediation spans multiple branches, decide merge strategy (single PR vs. stacked PRs) before implementation starts.

**Hard rule**: this skill NEVER produces inline fixes in the same invocation. It produces findings. Fixes happen in a separate pass through the code-generator workflow. If the user asks "just fix it", refuse and route them through the plan → fix → review chain.

---

## 0. Scope Parsing

```
/arch-review $ARGUMENTS
```

Accepts:
- Module name: `/arch-review payment`
- Package path: `/arch-review com.company.payment`
- Nothing: review the current git-changed files OR the top-level module the user is currently working on

Confirm scope:
```
🏛️  ARCH REVIEW SCOPE
  Module:     payment
  Package:    com.payserflow.payment
  Files:      <n> Java files
  Layers:     domain, application, infrastructure, api
  Mode:       report-only | fix-plan
```

---

## 1. Invariants Checked

### 1.1 Dependency Direction (non-negotiable)

```
api / presentation
        │
        ▼
application (services, use cases)
        │
        ▼
domain (aggregates, value objects, events)
        ▲
        │
infrastructure (repos, clients, adapters)
```

**Rules**:
- `domain` imports NOTHING from `application`, `infrastructure`, `api`, or Spring
- `application` imports from `domain` only (and Spring for `@Service`, `@Transactional`)
- `infrastructure` imports `domain` and `application` ports; never referenced the other way
- `api` imports `application` only; never touches `domain` or `infrastructure` directly

### 1.2 Transaction Boundaries

- `@Transactional` only on service methods (application layer), never on repositories or controllers
- Read-only transactions marked `@Transactional(readOnly = true)`
- No `@Transactional` on private methods (Spring can't proxy them)
- Service method invoking another service method on the same class via `this.` bypasses the proxy — flag it

### 1.3 No Business Logic in Controllers

- Controllers should only: parse request, call service, map response, return HTTP status
- Controllers must NOT: loop over entities, aggregate results, make decisions based on business rules
- Max recommended lines per controller method: 15

### 1.4 No Direct Entity Exposure in API

- Response DTOs must be separate records — never return JPA entities or JDBC aggregates from a `@RestController`
- Requests must be separate DTO records — never bind directly to an entity
- MapStruct or manual mapping between domain and DTO

### 1.5 Circuit Breakers on External Calls

- Every call to an external HTTP API / external DB / external queue must be wrapped in a Resilience4j `@CircuitBreaker` or equivalent
- Fallback methods should be deterministic and safe (often "return cached" or "fail fast with 503")

### 1.6 Value Objects vs Primitive Obsession

- Money → `Money` value object (not `BigDecimal`)
- Email → `Email` value object (not `String`)
- PhoneNumber → `PhoneNumber` value object
- Tenant ID → `TenantId` value object
- IDs → typed IDs (`PaymentId`, `UserId`) — not raw `Long` / `String`

Primitives are allowed at the infrastructure boundary (DB columns, HTTP payloads) — domain should see value objects.

### 1.7 Event Publishing for State Changes

- Every aggregate state change emits a domain event
- Events use `ApplicationEventPublisher` or Spring Modulith's `DomainEvents`
- Consumers use `@ApplicationModuleListener` for cross-module, `@EventListener` for in-module

### 1.8 Module Boundary Enforcement (Spring Modulith)

If Spring Modulith is present, ensure:
- `@ApplicationModule` declares allowed dependencies
- `ApplicationModules.verify()` is in a test — failing build on violation
- `package-info.java` documents module purpose and ports

---

## 2. Execution Phases

### 2.1 Phase 1 — Inventory

```bash
find <package> -name "*.java" | head -200
grep -l "@RestController" <package> | wc -l
grep -l "@Service" <package> | wc -l
grep -l "@Repository" <package> | wc -l
```

### 2.2 Phase 2 — Static Checks via ArchUnit (if available)

```java
@AnalyzeClasses(packages = "com.payserflow.payment")
class PaymentArchTest {

    @ArchTest
    static final ArchRule domain_does_not_depend_on_application =
        classes().that().resideInAPackage("..domain..")
            .should().onlyDependOnClassesThat().resideInAnyPackage(
                "..domain..", "java..", "org.slf4j..");

    @ArchTest
    static final ArchRule controllers_only_in_api_package =
        classes().that().areAnnotatedWith(RestController.class)
            .should().resideInAPackage("..api..");

    @ArchTest
    static final ArchRule repositories_only_in_infrastructure =
        classes().that().areAssignableTo(CrudRepository.class)
            .should().resideInAPackage("..infrastructure..");

    @ArchTest
    static final ArchRule services_are_annotated_with_service =
        classes().that().haveSimpleNameEndingWith("Service")
            .and().resideInAPackage("..application..")
            .should().beAnnotatedWith(Service.class);

    @ArchTest
    static final ArchRule no_cyclic_module_dependencies =
        slices().matching("com.payserflow.(*)..").should().beFreeOfCycles();
}
```

If ArchUnit isn't in the project, propose adding it. Otherwise perform file-by-file grep analysis.

### 2.3 Phase 3 — File-by-File Analysis

For each file, check:
- Imports (does a `domain` file import Spring annotations?)
- Class annotations (controller doing service work?)
- Method bodies (controller with `for (...)` loops processing domain objects?)
- Return types (controller returning `Entity` directly?)
- Exception handling (services catching and swallowing? controllers using try/catch instead of `@ControllerAdvice`?)

---

## 3. Findings Report Format

```markdown
# Architectural Review — <module>
Reviewer: arch-review skill
Date: <timestamp>
Mode: report-only | fix-plan

## Summary

  Total findings: <n>
  🔴 CRITICAL: <n>   (must fix before merge)
  🟠 HIGH:     <n>   (should fix this sprint)
  🟡 MEDIUM:   <n>   (track as tech debt)
  🟢 LOW:      <n>   (style/cleanup)

## CRITICAL findings

### [CRIT-001] domain layer imports Spring
  **Rule**: 1.1 Dependency Direction
  **File**: src/main/java/com/payserflow/payment/domain/Payment.java:5
  **Issue**: `import org.springframework.stereotype.Component;`
  **Why it matters**: domain must be framework-agnostic; coupling to Spring prevents unit-testing domain in isolation
  **Fix**: Remove the `@Component` annotation; move any Spring-managed lifecycle into `application` or `infrastructure`.

### [CRIT-002] controller contains business logic
  **Rule**: 1.3 No Business Logic in Controllers
  **File**: src/main/java/com/payserflow/payment/api/PaymentController.java:45-78
  **Issue**: Controller loops over payments, aggregates totals by currency, and applies fee discount logic inline.
  **Fix**: Extract to `PaymentSummaryService.computeSummary(criteria)` in the application layer; controller calls once and maps the result.

## HIGH findings

### [HIGH-001] external HTTP call without circuit breaker
  **Rule**: 1.5 Circuit Breakers on External Calls
  **File**: src/main/java/com/payserflow/payment/infrastructure/PaymentGatewayClient.java:32
  **Issue**: `restClient.post().retrieve()` has no `@CircuitBreaker` annotation; a gateway outage would cascade.
  **Fix**: Add `@CircuitBreaker(name = "payment-gateway", fallbackMethod = "fallbackCharge")` and implement `fallbackCharge(...)` returning a `PaymentDeclinedResult`.

... etc ...

## Dependency Graph

```
api ──► application ──► domain ◄── infrastructure
                                 \
                                  └─► application (VIOLATION: CRIT-003)
```

## Recommendations

1. Add ArchUnit to the build so these invariants are enforced on every CI run
2. Extract `PaymentSummaryService` (addresses CRIT-002)
3. Wrap all gateway clients in circuit breakers (addresses HIGH-001..005)
4. Migrate `BigDecimal amount` to `Money` value object across the payment module (addresses MED-001..008)
```

---

## 4. Fix-Plan Mode

If invoked with `--fix-plan`, produce an ordered ticket breakdown:

```markdown
## Remediation Tickets

### Ticket 1: Remove Spring imports from domain layer
  **Severity**: CRITICAL
  **Effort**: 1 day
  **Files**: <n>
  **Dependencies**: none
  **Done when**: domain package has zero `org.springframework.*` imports; ArchUnit rule passes

### Ticket 2: Introduce ArchUnit build verification
  **Severity**: HIGH
  **Effort**: 2 days
  **Dependencies**: Ticket 1
  **Done when**: `./gradlew test` runs `PaymentArchTest` and fails on regression

...
```

---

## 5. Output Contract

```yaml
produces:
  - type: "arch-review"
    format: "markdown"
    path: "claudedocs/<module>-arch-review-<timestamp>.md"
  - type: "tickets"
    format: "markdown"
    path: "claudedocs/<module>-arch-fix-plan-<timestamp>.md"  # only in fix-plan mode
  - type: "code"
    format: "java"
    paths: ["src/test/java/.../<Module>ArchTest.java"]         # suggested ArchUnit test
  handoff: "Write claudedocs/handoff-arch-review-<timestamp>.yaml — suggest: ticket-breakdown, tech-debt-assessment"
```

---

## 6. Anti-patterns to Detect

| Pattern | Detection | Severity |
|---|---|---|
| Spring imports in `domain/` | grep `org.springframework` | CRITICAL |
| JPA/JDBC imports in `domain/` | grep `jakarta.persistence` / `org.springframework.data` | CRITICAL |
| Controller returning entities | grep for `return <entity>` in `@RestController` classes | HIGH |
| `@Transactional` on private methods | grep `private.*@Transactional` | HIGH |
| `@Transactional` on controllers | grep `@Transactional` in api package | CRITICAL |
| Missing circuit breaker on `RestClient` / `WebClient` | grep for HTTP calls without `@CircuitBreaker` | HIGH |
| `this.otherMethod()` in service when other method is `@Transactional` | static analysis | HIGH |
| `BigDecimal amount` in method signature (domain layer) | grep | MEDIUM |
| Raw `Long id` / `String id` in domain | grep | MEDIUM |
| `catch (Exception e)` in services | grep | MEDIUM |
| Static method call into another module | grep cross-module `static` calls | HIGH |
| Repository called directly from controller | grep `@Autowired.*Repository` in api package | CRITICAL |

---

## 7. Reference Files

| File | When |
|---|---|
| `references/archunit-setup.md` | How to add ArchUnit to Gradle/Maven |
| `references/clean-architecture-patterns.md` | Deep dive on each invariant with good/bad examples |
