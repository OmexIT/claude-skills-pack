# Code Audit - Review Dimensions

Per-dimension protocols for Phase 2 of `code-audit`. Each dimension is a lens: run it inline or
hand it to one subagent. A checklist item or threshold is a question to investigate, not a defect.

## Finding format and evidence

```
[SEVERITY] Finding title
├─ Location: file:line, command, endpoint, migration, or subsystem
├─ Evidence: smallest reproducible proof (see below)
├─ Issue: the violated behavior, invariant, decision, or requirement
├─ Impact: concrete user, business, operational, security, or maintenance consequence
├─ Recommendation: smallest corrective action, concrete enough to act on
├─ Blast radius: callers, tests, downstream services affected
└─ Effort: XS | S | M | L | XL, with uncertainty called out
```

Evidence can be a code or config quote, scoped search output, a failing or missing test, a runtime
log, trace, query plan, or an absence proof that names the paths and terms searched. Cite external
sources only with URLs actually fetched.

LEAD discards a finding that:
- has no locatable `Location` or no reproducible `Evidence`
- states a vague issue ("could be better") or a generic fix ("add error handling")
- rests on a line-count, complexity, duplication, or dependency-age threshold with no verified impact
- is a theoretical risk with no reachable path or violated invariant
- is style an existing formatter or linter already settles
- flags a missing artifact the repository, user, regulation, or delivery flow does not require

**Severity follows impact and likelihood, not pattern names.** A deprecated API, duplicated block, or
missing circuit breaker is not automatically HIGH.

| Level | Meaning |
|---|---|
| **CRITICAL** | Broken production behavior; money, security, privacy, tenant isolation, or data-loss risk |
| **HIGH** | Material correctness, reliability, or maintainability risk with a credible path to impact; fix before merge or release |
| **MEDIUM** | Bounded debt, testing gap, or deviation with real future cost; schedule it |
| **LOW** | Polish that reduces real friction |
| **POSITIVE** | Code worth keeping as a reference |

Before keeping any finding, look for disconfirming evidence (a guard elsewhere, a test, an ADR that
accepts the trade-off) and deduplicate by root cause.

## House law (check wherever relevant)

- Money: `BigDecimal` in Java, `NUMERIC` in SQL, never `double`/`float`.
- Time: `Instant`/`OffsetDateTime` and `TIMESTAMPTZ`, never `Date` or zone-less `TIMESTAMP`.
- IDs: TSID stored as `BIGINT` internally, UUIDv7 externally; TSIDs never exposed in APIs.
- API errors: RFC 9457 Problem Details, no stack traces or provider errors leaked.
- Simplicity: no speculative abstractions, flags, or wrappers; prefer what the framework provides.

## Dimension 1: Code Smells (`SMELL`)

Fowler catalog, used as leads. Size numbers (method over ~50 lines, class over ~500 LOC, more than
~4 parameters) only point where to look; report the smell when it makes a change, test, or bug
more likely.

- Bloaters: long method, large class, long parameter list, data clumps, primitive obsession
- Change preventers: divergent change, shotgun surgery (confirm with git history)
- Couplers: feature envy, inappropriate intimacy, message chains, middle man
- Dispensables: dead code, speculative generality, lazy element, comments explaining bad code
- OO abusers: refused bequest, temporary field, repeated `instanceof` or type switches

## Dimension 2: SOLID (`SMELL`)

Check the classes that carry business decisions; do not grind every file.

- **S**: one class changed in unrelated commits; HTTP and SQL concerns in the same class.
- **O**: type-switch chains that grow with every variant (git history proves it).
- **L**: `UnsupportedOperationException` overrides, stricter subclass preconditions, empty overrides.
- **I**: clients forced to depend on methods they never call.
- **D**: business logic constructing infrastructure collaborators directly; field injection instead
  of constructor injection. Value objects and records built with `new` are fine.

## Dimension 3: Duplication (`DUP`)

- Syntactic clones (exact, renamed, near-miss) and semantic duplicates (same rule, different code).
- Knowledge duplication: the same constant, enum, or business rule defined in several places.
- Feature duplication: overlapping endpoints, near-identical models, utilities that reimplement the
  framework or standard library.

Duplication is a signal. Extract when it repeats knowledge that can drift, or when a third use
establishes a stable abstraction. Two similar blocks can stay clearer than a premature shared
mechanism.

## Dimension 4: Algorithms and Data Structures (`ALGO`)

| Pattern | Problem | Usual fix |
|---|---|---|
| Nested loops for lookup | O(n^2) | Index into a map or set first |
| Repeated `list.contains()` | O(n) per call | Convert to a set |
| String concatenation in a loop | Repeated copies | Builder or join |
| `ArrayList.remove(0)` in a loop | O(n) shift each time | `ArrayDeque` |
| Recomputing inside loops | O(n x cost) | Hoist the computation |
| Unbounded collection or history | Memory grows with input | Bound, page, or stream |
| Shared `HashMap` across threads | Data race | Concurrent collection or confinement |

State the complexity and the realistic input size. O(n^2) over a list that is provably small is a
lead, not a finding.

## Dimension 5: Security (`SEC`)

Breadth pass. For a threat model or a deep auth review, recommend `security-review`.

- Injection: parameterized queries, no user input in shell, template, or file paths, output escaped.
- Authentication and session: modern password hashing, token signature and algorithm validation,
  server-side logout, re-auth for sensitive operations.
- Authorization: enforced server-side on every entry and persistence path, object-level checks (no
  IDOR), tenant isolation, default deny.
- Data exposure: no over-fetching, no PII or secrets in logs, errors, or URLs, no hardcoded secrets,
  internal IDs not exposed.
- Crypto: platform-provided primitives and secure randomness; never home-grown crypto.
- Vulnerable dependencies: use the resolved dependency graph and official advisories or the
  ecosystem scanner. Never infer a vulnerability from a package name or a different version.

## Dimension 6: Performance and Reliability (`PERF`)

Breadth pass. For SLO-driven analysis or a load-test plan, recommend `performance-review`.

- Start from an SLO, profile, trace, query plan, load test, or observed resource limit where one
  exists. Without one, findings are leads and say so.
- Database: N+1 access, unbounded selects, missing pagination, long transactions, row-by-row bulk
  writes. Index and N+1 claims need the query, plan, or workload evidence, not naming alone.
- Memory and resources: unclosed resources, unbounded static caches, uncleared `ThreadLocal`.
- Concurrency: check-then-act races, lost updates, pool sizing and shutdown, blocking on event loops.
- Caching: invalidation strategy, TTLs, consistency impact of stale reads.
- Remote calls: every call has a timeout. Retries only for retryable, idempotent operations, bounded,
  with backoff. Circuit breakers or bulkheads only where repeated failure would amplify load and the
  open-circuit result has safe semantics. Never return a fabricated success for a failed mutating
  call; a timed-out mutation is an unknown outcome that needs reconciliation.

## Dimension 7: Design Pattern Fitness (`PATTERN`)

For each pattern in use: does the problem match the pattern's intent, does real variation justify
the overhead, can implementations actually be swapped, can a new developer follow it quickly?

Leads: god object, golden hammer, lava flow (dead abstractions, commented-out blocks), poltergeist
or pass-through wrappers, circular dependencies, interface or factory with one implementation,
singleton used as global state, anemic model where business rules leak into many services.

## Dimension 8: Architecture Conformance (`ARCH`)

Judge against the repository's accepted architecture (ADRs, ArchUnit rules, AGENTS.md), not a
textbook layout. For a Java/Spring boundary deep dive, recommend `arch-review`.

- Dependency direction: domain logic depending on transport, persistence, or provider clients;
  controllers reaching repositories and bypassing use-case rules or authorization.
- Transaction scope: remote calls inside database transactions need an explicit consistency design.
- Module cycles, cross-module persistence access, duplicated sources of truth, static calls that
  bypass public ports.
- Events only when a real boundary, independent lifecycle, or audit requirement justifies
  asynchronous semantics. A direct call is often the simpler in-process design.
- Existing fitness functions (ArchUnit, Modulith verify, lint rules): present, passing, covering
  the boundaries that matter?

Package metrics (instability, abstractness, distance from the main sequence) are leads for where to
look, not findings.

## Dimension 9: Technology and Lifecycle (`TECH`)

1. Detect exact language, runtime, framework, and package versions from the build files and the
   resolved dependency graph.
2. Run the ecosystem's vulnerability scanner when one is available.
3. Confirm support, deprecation, and migration status with current primary sources: official
   lifecycle pages, release notes, API docs, advisories (context7 or the vendor site).
4. Distinguish vendor from community support and direct from transitive dependencies.
5. Report only reachable or policy-relevant impact. Newer is not automatically better.

Do not keep a static EOL table, and do not call an API or framework style deprecated unless its
current official documentation says so. Internal `@Deprecated` symbols still called are a lead: find
out why they were deprecated before rating them. Also note custom code that reimplements a library
the project already depends on, and technology used against its grain.

## Dimension 10: The Skeptic (`SKEPTIC`)

- What assumption, if wrong, breaks this code (ordering, uniqueness, "this call is always fast")?
- Is it solving the right problem, or the problem as first stated?
- What is the simplest thing that would work? What happens if this code is deleted?
- What is the production blast radius when it fails?

Challenge the load-bearing assumptions, including whether the code needs to exist at all. Drop
challenges the evidence answers.

## Dimension 11: Test Coverage and Quality (`TESTING`)

Read the tests; coverage numbers alone mean little. Tests should prove business behavior and the
risky failure paths, not getters, DTOs, framework wiring, logging, or private methods.

- Coverage: existing reports if present; critical paths (money movement, auth, data mutation) with
  no test that reaches production wiring; spec edge cases absent from tests.
- Smells that matter: tests with no assertions, swallowed exceptions, `@Disabled`/`skip` without a
  tracked reason, mocks that make a test pass whatever the code does, unit tests hitting real
  infrastructure or integration tests mocking the thing under test, stale tests for deleted
  behavior.
- Usually fine: several assertions describing one behavior; random data that is seeded, recorded,
  or not behaviorally significant; conditional setup that does not hide which path runs.
- Flake leads: wall-clock `now()` without an injected clock, `sleep`-based waits, ordering assumed
  on hash-based collections, shared static state, wall-clock duration assertions.
- Stack conventions: match what the project already uses. Integration tests should run against the
  production database engine (for example Testcontainers), not an in-memory substitute that hides
  migration and dialect gaps.
- UI tests: prefer role, label, and accessible-name locators. A missing `data-testid` is not a defect
  when a stable semantic locator exists.

Report the test commands actually run and their output. Do not infer that tests pass from their
presence.

## Example finding

```
[HIGH] Timed-out transfer retries with a new reference
├─ Location: src/.../TransferAdapter.java:84
├─ Evidence: retry() calls newReference() after ProviderTimeout; no test covers the timeout path
│           (grep "ProviderTimeout" src/test -> 0 matches)
├─ Issue: the second request can post a second transfer while the first outcome is unknown
├─ Impact: customer balance can be debited twice
├─ Recommendation: persist PENDING_RECONCILIATION, reuse the original reference, reconcile first
├─ Blast radius: every caller of TransferAdapter.send (3 services)
└─ Effort: M
```
