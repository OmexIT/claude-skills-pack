# Code Audit — Review Dimensions

Detailed per-dimension analysis protocols for the 10 agents dispatched during Phase 2 of `/code-audit`. Read this file when dispatching review agents or interpreting their findings.

All agents use this **structured finding format**. **Every finding MUST include an `Evidence` field** quoting the actual code — findings without evidence are rejected at the LEAD synthesis stage.

```
[SEVERITY] Finding title
├─ Location: file:line (or file:class:method)
├─ Evidence: <direct quote from the code, 1-5 lines, exact characters>
├─ Issue: What's wrong — specific, not vague
├─ Impact: What happens if not addressed (bugs, perf, security, maintenance)
├─ Recommendation: Concrete fix with code example
├─ Rationale: Why this matters (cite pattern, research, principle, or context7 doc URL)
├─ Blast radius: Which other parts of the system are affected (callers, tests, downstream services)
└─ Effort: XS | S | M | L | XL
```

**Rejection rules** — LEAD discards any finding that:
- Has no `Location` with file:line
- Has no `Evidence` quoting actual code
- Uses vague language in `Issue` ("this is bad", "needs improvement", "could be better")
- Has a generic `Recommendation` ("add error handling", "improve performance") without a concrete fix
- Cites an external source with a fabricated URL
- Is purely stylistic when the project already has a formatter/linter that would catch it

**Severity levels**:

| Level | Definition | Action |
|---|---|---|
| **CRITICAL** | Security vulnerability, data loss risk, correctness bug | Must fix immediately |
| **HIGH** | Will cause bugs, performance degradation, or significant maintenance burden | Must fix before merge/release |
| **MEDIUM** | Tech debt, testing gaps, or deviation from best practices | Should fix, schedule if time-constrained |
| **LOW** | Polish, naming, documentation, minor style | Nice-to-have |
| **POSITIVE** | Acknowledge good code — not just problems | Note and encourage |

---

## Dimension 1: Code Smells (`SMELL` agent)

**Fowler/Martin Catalog — scan for these systematically**:

**Bloaters**:
- Long Method (>50 lines or cyclomatic complexity >10)
- Large Class (>500 LOC, >20 methods, or multiple responsibilities)
- Long Parameter List (>4 parameters)
- Data Clumps (same group of fields passed together repeatedly)
- Primitive Obsession (strings/ints where domain types belong)

**Change Preventers**:
- Divergent Change (one class modified for many unrelated reasons)
- Shotgun Surgery (one change requires editing many classes)
- Parallel Inheritance Hierarchies (adding a subclass forces adding another elsewhere)

**Couplers**:
- Feature Envy (method uses more data from another class than its own)
- Inappropriate Intimacy (classes access each other's private details)
- Message Chains (`a.getB().getC().getD().doThing()`)
- Middle Man (class that only delegates)

**Dispensables**:
- Duplicated Code (see Dimension 3)
- Dead Code (unreachable code, unused methods/variables/imports)
- Speculative Generality (abstractions with only one implementation)
- Lazy Element (class/function that doesn't do enough to justify its existence)
- Comments as Deodorant (comments explaining bad code instead of fixing it)

**Object-Oriented Abusers**:
- Refused Bequest (subclass ignores inherited methods)
- Temporary Field (fields only populated in certain scenarios)
- Alternative Classes with Different Interfaces (classes doing the same thing differently)
- Switch Statements / Repeated `instanceof` checks (should be polymorphism)

## Dimension 2: SOLID Violations (`SMELL` agent)

**Every file in scope must be checked against all 5 SOLID principles.** This is the structural health check of the codebase — SOLID violations are what make code hard to change, test, and reason about. Do not skim this dimension.

For each principle, check specific measurable indicators:

**S — Single Responsibility**:
- Class has multiple reasons to change (check git history: modified in unrelated commits?)
- Class name includes "Manager", "Handler", "Processor", "Utils" (vague responsibility)
- Mixed abstraction levels (HTTP handling + SQL in same class)
- High import count (>15 imports = probable SRP violation)

**O — Open/Closed**:
- Long if/else or switch chains checking object type
- Same class modified every time a new feature variant is added (check git history)
- Missing strategy/template pattern where polymorphism would eliminate conditionals

**L — Liskov Substitution**:
- Methods throw `UnsupportedOperationException` / `NotImplementedException`
- Subclass methods enforce stricter preconditions than parent
- `instanceof` checks before calling methods on a type hierarchy
- Empty method overrides

**I — Interface Segregation**:
- Interfaces with >10 methods
- Implementing classes that leave methods unimplemented
- Clients using only a subset of interface methods

**D — Dependency Inversion**:
- `new ConcreteClass()` in business logic (not factories)
- Importing concrete implementations instead of interfaces
- Field injection (`@Autowired` on fields) instead of constructor injection
- High-level modules importing low-level modules directly

## Dimension 3: Code Duplication / DRY (`DUP` agent)

**DRY — Don't Repeat Yourself.** This dimension enforces it. DRY violations are not just aesthetic — duplicated business rules diverge silently, duplicated validation leaks when only one site is fixed, duplicated magic numbers are a guaranteed bug-breeding ground.

**Detection approach**: three levels.

1. **Syntactic clones** — the four clone types below (Fowler / Roy-Cordy CCFinder taxonomy)
2. **Semantic duplication** — same business rule expressed differently across modules
3. **Knowledge duplication** — the same constant, enum value, or magic string defined in multiple places

Detect all four clone types:

| Type | What to Look For | How to Detect |
|---|---|---|
| **Type 1** — Exact clones | Identical code blocks | Direct text comparison |
| **Type 2** — Parameterized | Same structure, different names/literals | Normalize identifiers, compare structure |
| **Type 3** — Near-miss | Similar blocks with added/removed/changed lines | AST-level structural comparison |
| **Type 4** — Semantic | Different syntax, same behavior | Functional equivalence analysis (e.g., iterative vs recursive same algorithm) |

**Also detect feature-level duplication**:
- API endpoints with overlapping functionality
- Data models with highly similar field sets
- Business rules / validation logic repeated across modules
- Utility methods that reimplement existing library/framework functions

Example finding:

```
[MEDIUM] Duplicated validation logic
├─ Location: PaymentService.java:45, RefundService.java:78
├─ Issue: Amount validation (>0, max limit, currency check) duplicated in 2 services
├─ Impact: Bug fix in one location won't propagate to the other
├─ Recommendation: Extract to AmountValidator or shared validation method
├─ Rationale: DRY — same business rule in 2+ places must be extracted (Fowler)
└─ Effort: S
```

## Dimension 4: Algorithm & Data Structure Analysis (`ALGO` agent)

**Scan for suboptimal patterns**:

| Pattern | Problem | Better Alternative |
|---|---|---|
| Nested loops for lookup | O(n²) | HashMap/Set for O(1) lookup |
| Linear search in sorted data | O(n) | Binary search O(log n) |
| Repeated `list.contains()` | O(n) per call | Convert to HashSet first |
| String concatenation in loop | O(n²) immutable copies | StringBuilder |
| `ArrayList.remove(0)` in loop | O(n) shift per removal | ArrayDeque or LinkedList |
| Sorting to find min/max | O(n log n) | Single-pass O(n) |
| Recomputing inside loops | O(n × cost) | Hoist computation outside |
| No memoization for recursive | Exponential | Add memoization/DP |

**Wrong data structure checks**:
- `LinkedList` for random access (should be `ArrayList`)
- `ArrayList` for frequent middle insertions (should be `LinkedList`)
- `List.contains()` for uniqueness (should be `Set`)
- `HashMap` where `ConcurrentHashMap` needed (thread safety)
- Unbounded collections that grow without limit

**For each hot path, state the complexity explicitly**:

```
[MEDIUM] Quadratic search in transaction matching
├─ Location: ReconciliationService.java:112
├─ Issue: Nested for-loop matching transactions by ID — O(n²)
├─ Impact: With 10K transactions, this takes ~100M comparisons
├─ Recommendation: Index transactions in HashMap<String, Transaction> first — O(n) total
├─ Rationale: n² on unbounded input is a latency bomb (currently works because n < 100)
└─ Effort: S
```

## Dimension 5: Security Review (`SEC` agent)

**OWASP-aligned checklist — check every item**:

**Injection**:
- [ ] SQL/NoSQL: All queries parameterized? No string concatenation?
- [ ] Command injection: No user input in `Runtime.exec()` / `ProcessBuilder`?
- [ ] Template injection: No user input in template rendering?
- [ ] Path traversal: No user input in file paths without validation?
- [ ] XSS: All user-generated content escaped before rendering?

**Authentication & Session**:
- [ ] Passwords hashed with BCrypt/Argon2 (not MD5/SHA)?
- [ ] Session tokens regenerated after auth?
- [ ] Logout actually invalidates the session server-side?
- [ ] JWT signatures validated with correct algorithm?
- [ ] Re-authentication for sensitive operations?

**Authorization**:
- [ ] Every endpoint has auth check (not just frontend hiding)?
- [ ] Object-level permissions verified (no IDOR)?
- [ ] Privilege escalation paths checked?
- [ ] Default-deny access policy?

**Data Exposure**:
- [ ] API responses don't over-fetch (returning unnecessary fields)?
- [ ] Error messages don't leak internal details?
- [ ] Logs don't contain PII, secrets, or tokens?
- [ ] No hardcoded secrets, API keys, or passwords?

**Cryptography**:
- [ ] Modern algorithms (AES-256, RSA-2048+, ECDSA P-256+)?
- [ ] No hardcoded keys or IVs?
- [ ] Proper random number generation for tokens?

## Dimension 6: Performance Review (`PERF` agent)

**Database**:
- [ ] No N+1 query patterns (ORM access inside loops)
- [ ] Queries use appropriate indexes (check WHERE/JOIN columns)
- [ ] Large result sets paginated (no unbounded SELECTs)
- [ ] Transactions as short as possible
- [ ] No `SELECT *` (only needed columns)
- [ ] Batch operations for bulk inserts/updates

**Memory**:
- [ ] Resources closed (try-with-resources / finally / defer)
- [ ] No static collections that grow unbounded
- [ ] Stream processing for large datasets
- [ ] ThreadLocal values cleaned up after use

**Concurrency**:
- [ ] Shared mutable state properly synchronized
- [ ] No check-then-act race conditions
- [ ] Correct concurrent collection types
- [ ] Thread pools properly sized and shut down
- [ ] No blocking operations on event loop threads

**Caching**:
- [ ] Appropriate cache invalidation strategy
- [ ] TTLs set (no unbounded caches)
- [ ] Cache-aside vs read-through pattern chosen consciously

**Network**:
- [ ] No chatty API patterns (many small calls vs. batch)
- [ ] Timeouts set on all external calls
- [ ] Retry logic with exponential backoff (not tight loops)
- [ ] Circuit breakers for external dependencies

## Dimension 7: Design Pattern Fitness (`PATTERN` agent)

**Pattern fitness evaluation — for every pattern in use, ask**:

1. **Problem-Pattern Match**: Does the actual problem match the pattern's intent?
2. **Complexity Justified**: Does the pattern's overhead earn its keep through actual variation?
3. **Single Implementation Test**: If only one concrete implementation exists, the abstraction may be premature
4. **Substitution Test**: Can implementations actually be swapped?
5. **Comprehension Cost**: Can a new developer understand it within 15 minutes?

**Common anti-patterns to detect**:

| Anti-Pattern | Detection Signal |
|---|---|
| **God Object** | Class with >20 methods, high fan-in, multiple responsibilities |
| **Spaghetti Code** | High cyclomatic complexity, deep nesting, low cohesion |
| **Golden Hammer** | Same pattern applied everywhere regardless of fit |
| **Lava Flow** | Dead code, unused abstractions, commented-out blocks |
| **Poltergeist** | Classes with only delegation methods, short lifecycle |
| **Boat Anchor** | Unused code kept "just in case" |
| **Circular Dependency** | Modules reference each other in a loop |
| **Premature Abstraction** | Interface with one implementation, factory for one type |
| **Singleton Abuse** | Singleton used as global state instead of injected dependency |
| **Anemic Domain Model** | Entities with only getters/setters, all logic in services |

## Dimension 8: Architecture Conformance (`ARCH` agent)

**Layer violation detection**:
- Controllers calling repositories directly (skipping service layer)
- Domain entities importing infrastructure code
- Shared kernel dependencies going the wrong direction
- Cross-module direct calls where events should be used

**Package metrics (Robert C. Martin)**:

| Metric | Formula | Healthy Range |
|---|---|---|
| **Instability (I)** | Ce / (Ce + Ca) | Stable packages < 0.3 |
| **Abstractness (A)** | Abstract classes / Total classes | 0.3-0.7 balanced |
| **Distance from Main Sequence** | abs(A + I - 1) | < 0.3 |

**Check for**:
- Dependency cycles between packages/modules
- "Zone of Pain" packages (concrete + stable = hard to change)
- "Zone of Uselessness" packages (abstract + unstable = nobody uses)
- Coherence: do the classes in each package belong together?

**Architecture fitness functions (verify if they exist)**:
- Are ArchUnit / dependency rules in place?
- Are they passing or being ignored?
- Are there gaps in coverage?

## Dimension 9: Technology Evaluation & Deprecation Audit (`TECH` agent)

**Dependency health check** (use `mcp__context7__query-docs` for current status):
- Age and maintenance status of key dependencies
- Known CVEs at the exact versions in use (cross-check NVD + GitHub advisories)
- Availability of newer major versions with breaking changes
- Dependencies in "Hold" status on ThoughtWorks Technology Radar
- Custom code that reimplements library functionality

**Deprecation & EOL audit (MANDATORY)** — this is where silent rot lives:

### 9.1 Language-level deprecation
- Grep for language features that are deprecated in the project's language version:
  - Java: `finalize()`, `Thread.stop()`, `Class.newInstance()`, `@SuppressWarnings("deprecation")`, `javax.*` imports on Jakarta projects, `new Integer(...)` boxing constructors
  - JavaScript/TypeScript: `var` in modern TS, `new Buffer(...)`, `substr(...)`, legacy decorators syntax, `any` where `unknown` fits
  - Python: `imp` module, `distutils`, `asyncio.coroutine`, old-style classes, `dict.iteritems()` (py2 holdovers)
  - Kotlin: `!!` overuse, `synchronized` on multiplatform, `Coroutines.launch` without scope
- Flag every instance as HIGH if the deprecation is already removed in the next language version, MEDIUM otherwise

### 9.2 Framework / library deprecation
- Grep for deprecated framework APIs using the detected framework versions:
  - Spring Boot: `WebMvcConfigurerAdapter`, `WebSecurityConfigurerAdapter`, `@EnableGlobalMethodSecurity` (now `@EnableMethodSecurity`), `RestTemplate` (now `RestClient`), `antMatchers` (now `requestMatchers`), `ResponseEntityExceptionHandler` overrides that changed
  - React: class components in new code, `componentWillMount/Receive/Update`, `React.FC<Props>` pattern, `ReactDOM.render` (now `createRoot`), legacy context API
  - Next.js: `pages/` router in Next 13+, `getInitialProps`, custom `_document.js` patterns that conflict with App Router
  - Temporal SDK: `@WorkflowMethod` on classes (should be interfaces), `WorkflowOptions.newBuilder` pre-1.20 signatures
- For every flagged API: cite the context7 result showing the replacement

### 9.3 Internal `@Deprecated` still in use
```bash
# Find declared deprecations
Grep("@Deprecated|@deprecated") → list deprecated symbols
# Check if still called
Grep("<symbol>") excluding the declaration site
```
- Every deprecated internal API still being called is a HIGH finding — someone deprecated it for a reason and nobody removed callers
- Check deprecation age via `git blame` — deprecated for >6 months and still used = debt

### 9.4 EOL framework / runtime versions
- Cross-reference detected versions against these lifecycles (verify via context7):

| Runtime/Framework | Detect | Status to flag |
|---|---|---|
| Java ≤ 11 | `sourceCompatibility` / `java.version` | HIGH (non-LTS / EOL community support) |
| Java 17 | detected | MEDIUM (still supported, but Java 21/25 available) |
| Spring Boot ≤ 2.7 | `spring-boot-starter-parent` version | CRITICAL (EOL Nov 2023) |
| Spring Boot 3.0-3.2 | detected | HIGH (out of standard support) |
| Node.js ≤ 18 | `engines.node` | HIGH (EOL April 2025) |
| Python ≤ 3.9 | `python_requires` | HIGH (EOL Oct 2025) |
| React ≤ 17 | `package.json` | MEDIUM (not EOL but stale) |
| Angular.js 1.x | detected | CRITICAL (EOL January 2022) |
| Hibernate ≤ 5 | detected | HIGH (superseded by 6+) |

- For every EOL finding, cite context7 to confirm current EOL status (training data on EOL dates is unreliable)

### 9.5 Transitive dependency rot
- Run `./gradlew dependencies --configuration runtimeClasspath` (or `mvn dependency:tree`, `npm ls`) if available and in scope
- Flag transitive dependencies ≥ 3 major versions behind latest
- Flag conflicting versions of the same library in the tree

**Technology fitness evaluation**:
- Is the chosen technology appropriate for the problem?
- Are there better-suited alternatives available now?
- Is the team using the technology idiomatically or fighting it?
- Vendor lock-in risk assessment

## Dimension 10: The Skeptic (`SKEPTIC` agent)

**Challenge assumptions**:
- What assumption, if wrong, makes this code fundamentally broken?
- Is this code solving the right problem, or the problem as stated?
- What's the simplest thing that could work? Is the current approach over-engineered?
- What would happen if we deleted this code entirely?
- What's the blast radius if this code fails in production?
- Are there hidden coupling assumptions (e.g., "this service will always be fast")?

Must produce at least 3 challenges, including at least 1 that questions whether the code should exist at all.

## Dimension 11: Test Coverage & Quality (`TESTING` agent)

The scorecard has a "Test Coverage & Quality" row. This dimension produces the findings for it. A codebase with zero tests scores 0; a codebase with 80% branch coverage AND stable assertions scores 9-10. Coverage numbers alone mean nothing — **read the tests**.

**Coverage signals**:
- Branch / line coverage from existing reports (`build/reports/jacoco/**`, `coverage/**`, `.nyc_output`)
- Untested public methods (Grep `public ` in target, cross-reference with test classes)
- Critical paths with no tests (money movement, auth, data mutation)
- Edge cases mentioned in spec but absent from tests

**Test smells** — scan the test files directly:

| Smell | Detection | Severity |
|---|---|---|
| **Assertion Roulette** | Multiple `assert` calls in one test with no message — which one failed? | MEDIUM |
| **Eager Test** | Single test method verifies 10+ things, can't tell what broke | MEDIUM |
| **Conditional Test Logic** | `if`/`for` in a test — tests should be linear | HIGH |
| **Mystery Guest** | Test depends on external file/DB/service without explicit setup | HIGH |
| **Test Code Duplication** | Same setup repeated — extract to helper or `@BeforeEach` | LOW |
| **Fragile Test** | Test breaks on unrelated refactors (over-mocking, implementation-coupled) | MEDIUM |
| **Hidden Randomness** | `UUID.randomUUID()` or `Instant.now()` without fixed seed / clock | HIGH |
| **Sleep-based tests** | `Thread.sleep(...)` instead of `Awaitility` / synchronization | HIGH |
| **Silent catch** | `try { ... } catch (Exception e) { /* ignored */ }` in a test | CRITICAL |
| **Disabled tests** | `@Disabled` / `@Ignore` / `xit(...)` / `.skip()` — tech debt in disguise | HIGH |
| **No assertions** | Test calls the code but never asserts the result | CRITICAL |
| **Wrong isolation** | Unit tests that hit real DB, or integration tests that mock the DB | MEDIUM |

**Flake signals** (do a second pass for these):
- Tests using `Instant.now()`, `LocalDateTime.now()`, `new Date()` without a clock abstraction
- Tests that assume ordering on `Set`, `HashMap`, `ConcurrentHashMap`
- Tests with hard-coded timestamps that will break on date change
- Tests depending on wall-clock duration (`assertThat(duration).isLessThan(100ms)`)
- Tests that share mutable state via static fields

**Assertion quality**:
- Prefer AssertJ `assertThat(x).isEqualTo(y)` over JUnit `assertEquals(x, y)` — better failure messages
- Prefer structural assertions (`.containsExactly`, `.hasSize`) over manual loops
- Prefer `assertThatThrownBy` over try/catch/fail
- Mock verification should use `inOrder()` when ordering matters

**Stack-specific checks**:

*Java / Spring Boot*:
- Unit tests use `@ExtendWith(MockitoExtension.class)` — no Spring context
- Integration tests use `@SpringBootTest` + Testcontainers with real Postgres
- Controller tests use `@WebMvcTest` slice, not full context
- `@MockBean` overuse is a smell — prefer constructor-injected test doubles
- Repository tests use `@DataJpaTest` or real DB via Testcontainers, never in-memory H2 if prod uses Postgres (migration compatibility gap)

*TypeScript / React*:
- Vitest + React Testing Library (not Enzyme)
- No `data-testid` means no stable E2E target — flag it
- Mocking `fetch` directly is worse than using MSW
- Snapshot tests without explicit assertions are smells

*Python*:
- pytest with fixtures, not unittest setUp
- `monkeypatch` over global mocking
- Real DB via testcontainers-python, not SQLite stub

**Output**:

```
[HIGH] Critical path untested — money movement
├─ Location: LedgerService.java:134 (postTransfer method)
├─ Evidence: `public TransferId postTransfer(PostCommand cmd) { ... }`
├─ Issue: 47-line method handles double-entry posting. No test file references postTransfer directly. Grep of test/ returned 0 matches.
├─ Impact: Money-moving code untested — balance invariants unchecked, idempotency unverified, reversal path unverified
├─ Recommendation: Add Testcontainers integration test asserting (a) balanced postings, (b) idempotency on duplicate key, (c) insufficient-funds rejection, (d) reversal correctness. See `/fintech-ledger` skill for the expected test harness.
├─ Rationale: Money code without Testcontainers tests is an uncovered invariant — the primary failure mode of ledger bugs is silent balance corruption. See `fintech-ledger` taxonomy entry.
├─ Blast radius: Every caller of postTransfer — currently 4 services
└─ Effort: M
```
