---
name: code-audit
description: >
  Comprehensive multi-agent code review and audit: design patterns, code smells, SOLID violations,
  duplication detection, algorithm analysis, architecture conformance, technology evaluation, security,
  and performance — with expert panel and internet research. Triggers: "code audit", "code review",
  "review this code", "code quality", "code smells", "design patterns review", "architecture review",
  "is this code good", "review the implementation", "audit this module".
argument-hint: "[file, module, directory, or feature path]"
context: fork
agent: general-purpose
effort: high
---

# Code Audit: Multi-Agent Implementation Review

Orchestrates a **multi-agent expert panel** to conduct a comprehensive review of implemented code — combining static analysis, internet research, expert perspectives, and quantified quality scoring across 10 review dimensions.

This skill reviews **code that exists** (implementation). For reviewing **specs before implementation**, use `/spec-panel`.

---

## 0. Input Handling

```
/code-audit $ARGUMENTS
```

**Step 1 — Parse target:**
- File path(s): `src/payment/PaymentService.java`
- Directory: `src/payment/`
- Feature scope: `"the payment processing module"`
- PR reference: `#123` or branch name

**Step 2 — Scope determination.** Ask only if unclear:
- What's the review scope? (single file, module, feature, full codebase)
- What's the primary concern? (general quality, security, performance, architecture, all)
- What's the context? (pre-merge review, tech debt audit, incident investigation, onboarding)

**Step 3 — Codebase scan:**
```bash
# Map the target
find <target> -type f -name "*.java" -o -name "*.ts" -o -name "*.tsx" -o -name "*.py" -o -name "*.go" -o -name "*.dart" | head -50
wc -l <target files>

# Identify test coverage
find <target> -path "*/test*" -type f | head -20

# Check git activity
git log --oneline -20 -- <target>
git shortlog -sn -- <target>
```

**Step 4 — Confirm:**
```
🔍 CODE AUDIT TARGET
  Scope:     <n> files, ~<n> lines
  Language:  <detected>
  Framework: <detected>
  Tests:     <n> test files found
  Recent activity: <n> commits in last 30 days, <n> contributors

  Review dimensions activating: [list based on scope]
  Proceeding to Phase 1: Research...
```

---

## 1. Agent Roster

| Agent ID | Role | Review Dimension | Activated When |
|----------|------|------------------|----------------|
| `LEAD` | Lead Reviewer / Orchestrator | Overall quality, coordination | Always |
| `ARCH` | Architecture Analyst | Architecture conformance, coupling, modularity | Module+ scope |
| `SMELL` | Code Quality Analyst | Code smells, SOLID violations, clean code | Always |
| `DUP` | Duplication Detective | Code clones (Types 1-4), feature duplication | Always |
| `ALGO` | Algorithm Analyst | Complexity, data structures, optimization | Always |
| `SEC` | Security Reviewer | OWASP, auth, injection, secrets, crypto | Always |
| `PERF` | Performance Analyst | N+1 queries, memory, concurrency, caching | Always |
| `PATTERN` | Design Pattern Evaluator | Pattern fitness, anti-patterns, over-engineering | Module+ scope |
| `TECH` | Technology Evaluator | Stack fitness, dependency health, alternatives | Feature/codebase scope |
| `SKEPTIC` | Devil's Advocate | Challenges design decisions, finds hidden assumptions | Always |

**`LEAD` always orchestrates.** Other agents activate based on scope — single file reviews skip `ARCH` and `TECH`.

### Agent Model Routing

Route agents to optimal models for cost-efficiency:

| Agent | Model | Rationale |
|---|---|---|
| `LEAD` | `opus` | Orchestration and synthesis requires deepest reasoning |
| `ARCH` | `opus` | Architecture analysis requires deep structural reasoning |
| `SEC` | `opus` | Security analysis requires careful vulnerability reasoning |
| `SKEPTIC` | `opus` | Devil's advocate requires independent deep thinking |
| `SMELL`, `DUP`, `ALGO` | `sonnet` | Code pattern analysis — best coding model |
| `PERF`, `PATTERN` | `sonnet` | Implementation-focused analysis |
| `TECH` | `sonnet` | Dependency and technology evaluation |

### Parallel Execution Strategy

All 10 agents execute their analysis dimensions **in parallel** during Phase 2:
- Launch agents in a single message with multiple Agent calls
- Each agent operates on the same codebase snapshot independently
- Use `run_in_background: true` for lower-priority dimensions (TECH, PATTERN)
- LEAD synthesizes results only after ALL agents complete

```
Phase 1: LEAD reads codebase + internet research (sequential)
    ↓
Phase 2: ALL 9 analysis agents run in parallel
    ↓
Phase 3: LEAD synthesizes scorecard + roadmap (sequential)
```

### Agent Teams Mode (Experimental)

For large codebases (1000+ files), enable Agent Teams for competing-hypothesis investigation:
- `SMELL` and `SKEPTIC` can challenge each other's findings
- `SEC` and `PERF` can identify tradeoffs between security and performance
- Set `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` for this mode
- Higher token cost but better finding quality for complex audits

---

## 2. Phase 1 — Deep Research

### 2A: Codebase Investigation

**`LEAD` reads all target files and builds context:**
- Read every file in scope — don't sample, read all
- Map class/module dependencies (imports, inheritance, composition)
- Identify the public API surface (what other code calls into this)
- Check git blame for recent changes and ownership
- Read existing tests and understand what's covered vs. what's not
- Identify related code outside the target that this code depends on

### 2B: Internet Research

**Research the specific patterns and technologies in use:**
- Best practices for the frameworks/libraries detected (e.g., "Spring Boot repository pattern best practices", "React Query cache invalidation patterns")
- Known issues or CVEs for dependencies at the versions in use
- Idiomatic patterns for the language version detected
- Reference implementations from established open-source projects solving similar problems

Cite all sources. Synthesize into actionable insights, not link dumps.

### 2C: Existing Standards Check

- Read project's CLAUDE.md, .editorconfig, linter configs, ArchUnit rules
- Check for existing coding standards documentation
- Identify conventions already established in the codebase (naming, structure, error handling)
- Verify the code under review follows these — deviation from project conventions is a finding

---

## 3. Phase 2 — Multi-Dimensional Analysis

All agents use this **structured finding format:**

```
[SEVERITY] Finding title
├─ Location: file:line (or file:class:method)
├─ Issue: What's wrong — specific, not vague
├─ Impact: What happens if not addressed (bugs, perf, security, maintenance)
├─ Recommendation: Concrete fix with code example
├─ Rationale: Why this matters (cite pattern, research, or principle)
└─ Effort: XS | S | M | L | XL
```

**Severity levels:**

| Level | Definition | Action |
|-------|-----------|--------|
| **CRITICAL** | Security vulnerability, data loss risk, correctness bug | Must fix immediately |
| **HIGH** | Will cause bugs, performance degradation, or significant maintenance burden | Must fix before merge/release |
| **MEDIUM** | Tech debt, testing gaps, or deviation from best practices | Should fix, schedule if time-constrained |
| **LOW** | Polish, naming, documentation, minor style | Nice-to-have |
| **POSITIVE** | Acknowledge good code — not just problems | Note and encourage |

### Dimension 1: Code Smells (`SMELL` agent)

**Fowler/Martin Catalog — scan for these systematically:**

**Bloaters:**
- Long Method (>50 lines or cyclomatic complexity >10)
- Large Class (>500 LOC, >20 methods, or multiple responsibilities)
- Long Parameter List (>4 parameters)
- Data Clumps (same group of fields passed together repeatedly)
- Primitive Obsession (strings/ints where domain types belong)

**Change Preventers:**
- Divergent Change (one class modified for many unrelated reasons)
- Shotgun Surgery (one change requires editing many classes)
- Parallel Inheritance Hierarchies (adding a subclass forces adding another elsewhere)

**Couplers:**
- Feature Envy (method uses more data from another class than its own)
- Inappropriate Intimacy (classes access each other's private details)
- Message Chains (a.getB().getC().getD().doThing())
- Middle Man (class that only delegates)

**Dispensables:**
- Duplicated Code (see Dimension 3)
- Dead Code (unreachable code, unused methods/variables/imports)
- Speculative Generality (abstractions with only one implementation)
- Lazy Element (class/function that doesn't do enough to justify its existence)
- Comments as Deodorant (comments explaining bad code instead of fixing it)

**Object-Oriented Abusers:**
- Refused Bequest (subclass ignores inherited methods)
- Temporary Field (fields only populated in certain scenarios)
- Alternative Classes with Different Interfaces (classes doing the same thing differently)
- Switch Statements / Repeated `instanceof` checks (should be polymorphism)

### Dimension 2: SOLID Violations (`SMELL` agent)

For each principle, check specific measurable indicators:

**S — Single Responsibility:**
- Class has multiple reasons to change (check git history: modified in unrelated commits?)
- Class name includes "Manager", "Handler", "Processor", "Utils" (vague responsibility)
- Mixed abstraction levels (HTTP handling + SQL in same class)
- High import count (>15 imports = probable SRP violation)

**O — Open/Closed:**
- Long if/else or switch chains checking object type
- Same class modified every time a new feature variant is added (check git history)
- Missing strategy/template pattern where polymorphism would eliminate conditionals

**L — Liskov Substitution:**
- Methods throw `UnsupportedOperationException` / `NotImplementedException`
- Subclass methods enforce stricter preconditions than parent
- `instanceof` checks before calling methods on a type hierarchy
- Empty method overrides

**I — Interface Segregation:**
- Interfaces with >10 methods
- Implementing classes that leave methods unimplemented
- Clients using only a subset of interface methods

**D — Dependency Inversion:**
- `new ConcreteClass()` in business logic (not factories)
- Importing concrete implementations instead of interfaces
- Field injection (`@Autowired` on fields) instead of constructor injection
- High-level modules importing low-level modules directly

### Dimension 3: Code Duplication (`DUP` agent)

Detect all four clone types:

| Type | What to Look For | How to Detect |
|------|-----------------|--------------|
| **Type 1** — Exact clones | Identical code blocks | Direct text comparison |
| **Type 2** — Parameterized | Same structure, different names/literals | Normalize identifiers, compare structure |
| **Type 3** — Near-miss | Similar blocks with added/removed/changed lines | AST-level structural comparison |
| **Type 4** — Semantic | Different syntax, same behavior | Functional equivalence analysis (e.g., iterative vs recursive same algorithm) |

**Also detect feature-level duplication:**
- API endpoints with overlapping functionality
- Data models with highly similar field sets
- Business rules / validation logic repeated across modules
- Utility methods that reimplement existing library/framework functions

For each duplicate found:
```
[MEDIUM] Duplicated validation logic
├─ Location: PaymentService.java:45, RefundService.java:78
├─ Issue: Amount validation (>0, max limit, currency check) duplicated in 2 services
├─ Impact: Bug fix in one location won't propagate to the other
├─ Recommendation: Extract to AmountValidator or shared validation method
├─ Rationale: DRY — same business rule in 2+ places must be extracted (Fowler)
└─ Effort: S
```

### Dimension 4: Algorithm & Data Structure Analysis (`ALGO` agent)

**Scan for suboptimal patterns:**

| Pattern | Problem | Better Alternative |
|---------|---------|-------------------|
| Nested loops for lookup | O(n²) | HashMap/Set for O(1) lookup |
| Linear search in sorted data | O(n) | Binary search O(log n) |
| Repeated `list.contains()` | O(n) per call | Convert to HashSet first |
| String concatenation in loop | O(n²) immutable copies | StringBuilder |
| `ArrayList.remove(0)` in loop | O(n) shift per removal | ArrayDeque or LinkedList |
| Sorting to find min/max | O(n log n) | Single-pass O(n) |
| Recomputing inside loops | O(n × cost) | Hoist computation outside |
| No memoization for recursive | Exponential | Add memoization/DP |

**Wrong data structure checks:**
- `LinkedList` for random access (should be `ArrayList`)
- `ArrayList` for frequent middle insertions (should be `LinkedList`)
- `List.contains()` for uniqueness (should be `Set`)
- `HashMap` where `ConcurrentHashMap` needed (thread safety)
- Unbounded collections that grow without limit

**For each hot path, state the complexity:**
```
[MEDIUM] Quadratic search in transaction matching
├─ Location: ReconciliationService.java:112
├─ Issue: Nested for-loop matching transactions by ID — O(n²)
├─ Impact: With 10K transactions, this takes ~100M comparisons
├─ Recommendation: Index transactions in HashMap<String, Transaction> first — O(n) total
├─ Rationale: n² on unbounded input is a latency bomb (currently works because n < 100)
└─ Effort: S
```

### Dimension 5: Security Review (`SEC` agent)

**OWASP-aligned checklist — check every item:**

**Injection:**
- [ ] SQL/NoSQL: All queries parameterized? No string concatenation?
- [ ] Command injection: No user input in `Runtime.exec()` / `ProcessBuilder`?
- [ ] Template injection: No user input in template rendering?
- [ ] Path traversal: No user input in file paths without validation?
- [ ] XSS: All user-generated content escaped before rendering?

**Authentication & Session:**
- [ ] Passwords hashed with BCrypt/Argon2 (not MD5/SHA)?
- [ ] Session tokens regenerated after auth?
- [ ] Logout actually invalidates the session server-side?
- [ ] JWT signatures validated with correct algorithm?
- [ ] Re-authentication for sensitive operations?

**Authorization:**
- [ ] Every endpoint has auth check (not just frontend hiding)?
- [ ] Object-level permissions verified (no IDOR)?
- [ ] Privilege escalation paths checked?
- [ ] Default-deny access policy?

**Data Exposure:**
- [ ] API responses don't over-fetch (returning unnecessary fields)?
- [ ] Error messages don't leak internal details?
- [ ] Logs don't contain PII, secrets, or tokens?
- [ ] No hardcoded secrets, API keys, or passwords?

**Cryptography:**
- [ ] Modern algorithms (AES-256, RSA-2048+, ECDSA P-256+)?
- [ ] No hardcoded keys or IVs?
- [ ] Proper random number generation for tokens?

### Dimension 6: Performance Review (`PERF` agent)

**Database:**
- [ ] No N+1 query patterns (ORM access inside loops)
- [ ] Queries use appropriate indexes (check WHERE/JOIN columns)
- [ ] Large result sets paginated (no unbounded SELECTs)
- [ ] Transactions as short as possible
- [ ] No `SELECT *` (only needed columns)
- [ ] Batch operations for bulk inserts/updates

**Memory:**
- [ ] Resources closed (try-with-resources / finally / defer)
- [ ] No static collections that grow unbounded
- [ ] Stream processing for large datasets
- [ ] ThreadLocal values cleaned up after use

**Concurrency:**
- [ ] Shared mutable state properly synchronized
- [ ] No check-then-act race conditions
- [ ] Correct concurrent collection types
- [ ] Thread pools properly sized and shut down
- [ ] No blocking operations on event loop threads

**Caching:**
- [ ] Appropriate cache invalidation strategy
- [ ] TTLs set (no unbounded caches)
- [ ] Cache-aside vs read-through pattern chosen consciously

**Network:**
- [ ] No chatty API patterns (many small calls vs. batch)
- [ ] Timeouts set on all external calls
- [ ] Retry logic with exponential backoff (not tight loops)
- [ ] Circuit breakers for external dependencies

### Dimension 7: Design Pattern Fitness (`PATTERN` agent)

**Pattern fitness evaluation — for every pattern in use, ask:**

1. **Problem-Pattern Match**: Does the actual problem match the pattern's intent?
2. **Complexity Justified**: Does the pattern's overhead earn its keep through actual variation?
3. **Single Implementation Test**: If only one concrete implementation exists, the abstraction may be premature
4. **Substitution Test**: Can implementations actually be swapped?
5. **Comprehension Cost**: Can a new developer understand it within 15 minutes?

**Common anti-patterns to detect:**

| Anti-Pattern | Detection Signal |
|-------------|-----------------|
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

### Dimension 8: Architecture Conformance (`ARCH` agent)

**Layer violation detection:**
- Controllers calling repositories directly (skipping service layer)
- Domain entities importing infrastructure code
- Shared kernel dependencies going the wrong direction
- Cross-module direct calls where events should be used

**Package metrics (Robert C. Martin):**

| Metric | Formula | Healthy Range |
|--------|---------|--------------|
| **Instability (I)** | Ce / (Ce + Ca) | Stable packages < 0.3 |
| **Abstractness (A)** | Abstract classes / Total classes | 0.3-0.7 balanced |
| **Distance from Main Sequence** | abs(A + I - 1) | < 0.3 |

**Check for:**
- Dependency cycles between packages/modules
- "Zone of Pain" packages (concrete + stable = hard to change)
- "Zone of Uselessness" packages (abstract + unstable = nobody uses)
- Coherence: do the classes in each package belong together?

**Architecture fitness functions (verify if they exist):**
- Are ArchUnit / dependency rules in place?
- Are they passing or being ignored?
- Are there gaps in coverage?

### Dimension 9: Technology Evaluation (`TECH` agent)

**Dependency health check:**
- Age and maintenance status of key dependencies
- Known CVEs at current versions
- Availability of newer major versions with breaking changes
- Dependencies in "Hold" status on ThoughtWorks Technology Radar
- Custom code that reimplements library functionality

**Technology fitness evaluation:**
- Is the chosen technology appropriate for the problem?
- Are there better-suited alternatives available now?
- Is the team using the technology idiomatically or fighting it?
- Vendor lock-in risk assessment

### Dimension 10: The Skeptic (`SKEPTIC` agent)

**Challenge assumptions:**
- What assumption, if wrong, makes this code fundamentally broken?
- Is this code solving the right problem, or the problem as stated?
- What's the simplest thing that could work? Is the current approach over-engineered?
- What would happen if we deleted this code entirely?
- What's the blast radius if this code fails in production?
- Are there hidden coupling assumptions (e.g., "this service will always be fast")?

Must produce at least 3 challenges, including at least 1 that questions whether the code should exist at all.

---

## 4. Phase 3 — Quality Scorecard

| Dimension | Score (1-10) | Findings (C/H/M/L) | Key Issue |
|-----------|-------------|---------------------|-----------|
| **Code Smells & Clean Code** | | | |
| **SOLID Compliance** | | | |
| **Duplication** | | | |
| **Algorithm Efficiency** | | | |
| **Security** | | | |
| **Performance** | | | |
| **Design Pattern Fitness** | | | |
| **Architecture Conformance** | | | |
| **Technology Fitness** | | | |
| **Test Coverage & Quality** | | | |
| **Overall** | | | |

**Scoring guide:**
- **9-10**: Exemplary — use as reference implementation for the team
- **7-8**: Solid — minor issues, safe to ship
- **5-6**: Concerning — address HIGH findings before merging
- **3-4**: Significant problems — rework required
- **1-2**: Fundamentally unsound — major redesign needed

**Findings summary:**
```
FINDINGS SUMMARY
================
CRITICAL: <n>  ← must fix immediately
HIGH:     <n>  ← must fix before merge
MEDIUM:   <n>  ← should fix
LOW:      <n>  ← nice to have
POSITIVE: <n>  ← good practices to keep

Top 3 risks:
1. <highest impact finding>
2. <second highest>
3. <third highest>
```

---

## 5. Phase 4 — Improvement Roadmap

### 5A: Prioritized Findings

Group all findings into action tiers:

**Tier 1 — Fix Now (blocks merge/release):**
All CRITICAL + HIGH findings, ordered by effort (quick wins first).

| # | Finding | Dimension | File:Line | Effort | Fix Description |
|---|---------|-----------|-----------|--------|-----------------|

**Tier 2 — Fix This Sprint:**
MEDIUM findings that reduce tech debt or prevent future bugs.

| # | Finding | Dimension | File:Line | Effort | Fix Description |
|---|---------|-----------|-----------|--------|-----------------|

**Tier 3 — Schedule for Later:**
LOW findings and structural improvements.

| # | Finding | Dimension | File:Line | Effort | Fix Description |
|---|---------|-----------|-----------|--------|-----------------|

### 5B: Refactoring Plan

For each Tier 1 finding, provide a concrete refactoring plan:
```
REFACTORING: <Finding title>
  Current:     <what the code does now, with file:line>
  Target:      <what it should do>
  Steps:
    1. <step with specific file and change>
    2. <step>
    3. <step>
  Tests:       <what tests to add/modify to verify the refactoring>
  Risk:        <what could break>
  Verify:      <how to confirm the refactoring is correct>
```

### 5C: Recommended Reading

Based on internet research from Phase 1:
- Documentation, articles, and reference implementations relevant to the findings
- Patterns and practices the team should adopt

---

## 6. Phase 5 — Save Report

Save the full analysis to:
```
claudedocs/<target-name>-code-audit.md
```

Include at the top:
```markdown
# Code Audit: <target name>
**Date:** <today>
**Scope:** <files/modules reviewed>
**Quality Score:** <overall>/10
**Findings:** <n> CRITICAL, <n> HIGH, <n> MEDIUM, <n> LOW, <n> POSITIVE

## Action Tracker
| # | Finding | Severity | Dimension | Status | Owner | Notes |
|---|---------|----------|-----------|--------|-------|-------|
```

Set all statuses to `PENDING`.

Tell the user: "Audit saved to claudedocs/<name>-code-audit.md. Next steps: fix Tier 1 findings, then run /finalize to commit."

---

## Anti-patterns

- **Surface-level review** — Checking only naming and formatting while ignoring architecture, security, and performance. Style is the least important dimension.
- **Trusting tests exist** — A test file existing does not mean coverage is adequate. Read the tests. Check what they actually verify.
- **Generic advice** — "Add error handling" is useless. "Add try-catch in PaymentService.processRefund():47 — unhandled NPE when refund amount exceeds original" is useful.
- **Reviewing without context** — Not reading git history, related modules, or project conventions before judging code.
- **Bikeshedding** — Spending review time on variable names while a SQL injection sits three lines below.
- **Rubber-stamping** — Large PRs / complex modules need more scrutiny, not less. Complexity should increase thoroughness.
- **Pattern worship** — Flagging code for not using a design pattern when the simple approach is correct. Three similar lines are better than a premature abstraction.
- **Ignoring what's good** — Only reporting problems creates a hostile review. Acknowledge well-written code (POSITIVE findings).
- **Reviewing to your style, not the project's** — The project's conventions win. Flag deviations from project style, not from your personal preference.
- **Missing the forest for the trees** — 50 LOW findings about naming but missing the one CRITICAL architectural flaw.

---

## Quality bar

- Every finding uses the structured format with Location, Issue, Impact, Recommendation, Rationale, Effort
- All 10 dimensions were evaluated (or explicitly marked N/A with reason)
- Internet research was conducted and cited for the specific technologies in use
- Project conventions were checked and deviations flagged
- POSITIVE findings included — good code was acknowledged
- The Skeptic challenged at least 3 assumptions
- Quality scorecard was produced with per-dimension scores
- Tier 1 findings have concrete refactoring plans with steps
- Security checklist was completed (no unchecked items — mark N/A or flag)
- Performance checklist was completed

---

## Workflow context

**Upstream skills that feed into this:**
- `/spec-to-impl` — Code produced from spec implementation
- `/finalize` — Code ready for final review before commit
- Any implementation work that needs quality verification

**Downstream skills that consume this output:**
- `/finalize` — Commit after fixing Tier 1 findings
- `/test-plan` — Test planning informed by coverage gaps found
- `/tech-debt-assessment` — Tier 2/3 findings feed debt inventory
- `/performance-review` — Deep-dive on performance findings
- `/security-review` — Deep-dive on security findings

---

### Learning & Memory

After audit completes, save reusable patterns:
- Code quality patterns specific to this project's stack
- Common anti-patterns found that should inform future reviews
- Effective review checklist items for this technology combination
- Architecture conformance rules that should be codified as ArchUnit/lint rules

---

## Output contract

```yaml
produces:
  - type: "code-audit"
    format: "markdown"
    path: "claudedocs/<target-name>-code-audit.md"
    sections:
      - scope-and-context
      - codebase-investigation
      - internet-research
      - code-smells-findings
      - solid-violations
      - duplication-report
      - algorithm-analysis
      - security-checklist
      - performance-checklist
      - design-pattern-fitness
      - architecture-conformance
      - technology-evaluation
      - skeptic-challenges
      - quality-scorecard
      - findings-summary
      - improvement-roadmap-tier-1
      - improvement-roadmap-tier-2
      - improvement-roadmap-tier-3
      - refactoring-plans
      - recommended-reading
      - action-tracker
```
