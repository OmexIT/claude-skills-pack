---
name: spec-to-impl
description: "Use when the user provides a spec, PRD, BRD, API spec, or analysis document and wants it implemented end to end: implement this spec, build this from the PRD, or produce code, tests, migrations, and docs together. Tracker tickets for a team belong to ticket-breakdown."
---

# Spec-to-Impl

> Delegation, model labels, and task tracking below use Claude Code notation. In Codex or another client, follow `../../references/cross-client.md`.

Turns one or more spec documents into working code, tests, migrations, and docs: parse the spec,
plan tasks in waves, implement with test gates between waves, then run an integration review.
Roles (ARCH, BE, FE, QA, ...) are lenses on the work; they become parallel agents only when the
scope justifies it.

## Size the run first

Decide after Phase 1 (PARSE), and tell the user which mode you chose and why.

| Scope | Mode |
|---|---|
| One module, a handful of files, one stack | **Inline.** Plan, implement, and test in this session. Apply the relevant role lenses yourself. No worktrees, no task agents. Phases and gates still apply, compressed. |
| Two or three areas (for example BE + DB, or BE + FE) in one repo | **Few roles.** ARCH stays with you; dispatch at most the roles that write in parallel, or run them sequentially. Worktrees only if two writers overlap in time. |
| Several services or stacks, many independent tasks | **Full fan-out.** Waves of parallel agents in worktrees, per the rest of this file. |

Contracts (API standards, observability, patterns) scale the same way: a one-endpoint change
states its contract in a few lines inside the plan; it does not need separate Wave 1 documents.

## Step 0: Inputs

1. Read project instructions first (AGENTS.md, CLAUDE.md, nested copies in touched directories).
   They set conventions, the stack, and the delivery policy (branching, commits, PRs). They
   override every default in this skill.
2. Discover upstream handoff manifests (protocol in the `handoff` skill):
   `ls -t claudedocs/handoff-*.yaml 2>/dev/null | head -10`. For each manifest whose
   `suggested_next[].skill` includes `spec-to-impl`: read its `context`, read the files in
   `reads[]`, and record the manifest path for `consumed_from[]`. If `quality.status` is
   `blocked`, stop and report the blockers. If `partial`, use artifacts with `status: "ready"`
   and skip `in-progress` ones.
3. Read every spec file named in the request, plus the discovered artifacts. If a path is missing
   or unreadable, say so and ask for the right path.
4. Treat multiple files as complementary sections of one project: find shared entities, flows,
   and integration points. Never implement them as separate projects.
5. Detect the stack and versions from the repo before assuming anything. Read
   `references/stack-defaults.md` when the user names no stack and the repo does not settle it.
6. Confirm to the user: files loaded (one line each), upstream artifacts used, what the combined
   spec covers, and how many ambiguities you will surface.

Routing: a request for "status", "report", or "what's done" goes to Status reporting. "Add task",
"re-assign", "skip", or "re-plan" goes to Plan mutations. A request only to break the spec into
tasks stops after Phase 2 with the plan. Everything else runs the phases below.

## Roles

Include a role only when the spec needs it. Model labels mark reasoning depth.

| Role | Include when | Model | Persona |
|---|---|---|---|
| `ARCH` | Always (leads, owns contracts and integration review) | opus | `references/arch.md` |
| `DESIGN` | UI screens plus a raw Figma URL or selection, and no `figma:figma-generate-design` handoff | opus | `references/design.md` |
| `BE` | APIs, business logic, services, integrations | sonnet | `references/be-fe-qa-dba-devops.md` |
| `FE` / `FLUTTER` / `RN` / `ANDROID` / `ANGULARJS` | The matching UI stack is in scope | sonnet | same file |
| `DBA` | Schema or migration changes (follow `db-migration`) | opus | same file |
| `QA` | Always for the test plan; test code may be written by the implementing role | sonnet | same file |
| `OBS` | A new service, a new external integration, or SLO-bound operations | sonnet | same file |
| `SEC` | Auth flows, money movement, PII, new public endpoints | opus | same file |
| `DEVOPS` | CI/CD, container, or deployment changes | sonnet | same file |
| `TECH_WRITER` | New or changed public API, or docs the spec asks for | haiku | same file |

When no OBS role is included, implementation follows the repo's existing logging and metrics
conventions, and the observability gate items below do not apply.

## Phase 0: Design source (only when the spec has UI)

Runs as Wave 0, once PARSE confirms UI scope. Check, in this order, and use the first that exists:

1. `claudedocs/handoff-figma:figma-generate-design-*.yaml`: its `figma:` block (file key, screen
   node IDs, component map, variable bindings) replaces the DESIGN agent. FE uses variant B of
   `assets/fe-dispatch-with-design.md`.
2. Raw Figma URL or selection (in the request or the spec): add `TASK-000` (DESIGN). Read
   `references/design.md` for the extraction protocol and the Design Context Package format. FE
   uses variant A of `assets/fe-dispatch-with-design.md`. If Figma MCP is not connected, show the
   setup command and offer code-only mode.
3. `ui-design` handoff (`claudedocs/handoff-ui-design-*.yaml`, `design/DESIGN.md`,
   `design/components/`, `design/stitch-screens/`): FE uses the standard dispatch template with
   these artifacts.
4. Nothing: suggest running `ui-design` (or `figma:figma-generate-design`) first, or proceed from
   the spec text if the user prefers.

**Gate:** any blocking design ambiguity pauses FE work until the user resolves it. TASK-000
completes before any FE task that has a `figma_ref`.

## Phase 1: PARSE

ARCH extracts, from the spec and upstream artifacts:

- Functional requirements (FR-001...) with priority and acceptance criteria
- Non-functional requirements (NFR-001...) with measurable targets
- Entities and data models; API endpoints and contracts; UI screens and components
- Integration points (external services, webhooks, queues); business rules and validations
- Test scenarios (explicit or implied); observability needs; pattern candidates
- API style, detected from the codebase first, then the spec

Mark anything unclear `[AMBIGUOUS]` as critical or non-critical. Output the Spec Manifest using
`references/spec-manifest-template.md` (inline mode: a short list in the same order is enough).

**Gate:** pause and ask the user when any critical ambiguity blocks a P0 requirement.
Non-critical ones proceed with the assumption written into the manifest.

### Runability check (before planning)

Confirm the base builds, using the repo's own build command (project instructions, CI config,
`package.json` scripts, Gradle or Maven wrapper). Bring the stack up (for example
`docker compose up -d`, then poll the health endpoint instead of sleeping) only when a compose
file exists and the plan needs runtime verification; bring it down afterwards.

```
RUNABILITY  Build: PASS (<command>, 0 errors) | Startup: PASS / skipped (<reason>) | Migrations: PASS / n/a
```

**Gate:** if the build fails, halt and report the error. Do not plan on a broken base.

## Phase 2: PLAN

### Tasks

```
TASK-<ID>
  title / agent / type (design|implement|test|instrument|document|review) / priority (P0|P1|P2)
  depends_on: [TASK-IDs]   input / output   est_effort: XS..XL
  patterns: [...]   observability: [...] (if OBS)   figma_ref: <frame> (FE with a Figma source)
  definition_of_done: TC-xxx must pass
```

Planning rules:
- P0 blocks everything else, P1 is the core deliverable, P2 is post-MVP.
- Tasks with no unmet `depends_on` can run in parallel.
- ARCH owns system design, shared contracts, and the final integration review.
- QA test tasks depend on the implementation they test. TECH_WRITER tasks depend on the finished
  API, and the OpenAPI/AsyncAPI/proto spec must match the implementation.
- FE tasks with a `figma_ref` depend on TASK-000 when it exists. A Figma update mid-run re-runs
  Phase 0 and re-dispatches only FE tasks whose frames changed.
- Every task names the test cases that define its "done".

### Test plan (Wave 1)

QA writes `e2e/test-plan.yaml` before implementation starts, using the schema owned by
`verify-impl`: `../verify-impl/references/test-plan-schema.md`. Coverage judged by requirement:

- Every P0 FR: happy path, validation failure, authorization (when protected), and the boundary
  cases that carry business rules.
- Every P1 FR: at least its happy path.
- Every endpoint: one success and one error case. Every table written: an existence check and a
  field-value check.
- Populate only the layers that apply (API-only specs skip UI; read-only flows skip DB writes).
  Chain captured variables between cases; include setup and teardown for isolation.
- UI steps locate elements by role, label, and accessible name; test IDs only as a justified
  fallback.

### Wave 1 contracts

ARCH writes these before any implementation; implementing roles receive them in their prompts.

- **API standards contract**: style, versioning, response shape, RFC 9457 errors, pagination,
  idempotency for commands whose retry could duplicate an effect, naming, auth per endpoint.
  Match the existing API first. Read `references/api-standards.md` when writing it.
  House law: money as a decimal string plus currency (BigDecimal / NUMERIC), time as ISO 8601 UTC
  (Instant / OffsetDateTime / TIMESTAMPTZ), public IDs UUIDv7, internal TSID BIGINT never exposed.
- **Pattern selection**: per major component, the pattern, the FR/NFR that drives it, and the
  rejected alternative. Choose resilience controls from the failure mode (timeouts and bounded
  retries for transient faults, idempotency for duplicate risk, a circuit breaker only where a
  failing dependency would exhaust resources). Never add a fallback that fabricates success.
  Extract an abstraction only when a second implementation exists.
- **Observability contract** (OBS only): log events, metrics, spans, readiness scope, dashboard.
  Read `references/observability-contract.md` when writing it.

### Waves

```
WAVE 0  Design source (Phase 0), when the spec has UI
WAVE 1  ARCH: design + contracts | QA: test plan | DBA: schema | OBS: contract
WAVE 2  BE services | FE components | DEVOPS config
WAVE 3  QA tests | SEC review | OBS instrumentation check
WAVE 4  ARCH integration review | TECH_WRITER docs and API spec
```

Collapse waves that have no tasks. For more than a handful of tasks, ARCH also draws the
dependency graph (Mermaid or ASCII).

## Phase 3: EXECUTE

For each task, build the prompt from `assets/dispatch-prompt.md` (FE with a Figma source:
`assets/fe-dispatch-with-design.md`) with the role's persona, only the relevant spec sections, the
contracts, and the task's test cases. In inline mode, apply the same checklist yourself.

When agents write in parallel, read `references/execution.md` for the dispatch notation, worktree
rules, merge-back, and per-stack test commands.

### Task board

Track tasks in the client's task tool (Claude Code: TaskCreate/TaskUpdate; Codex: plan tool).
Status vocabulary, used by the gate:

```
Impl:  Done | WIP | Waiting | Blocked
Tests: n/n pass | n FAILING | n ERRORS | Not run | No tests written | N/A
OBS:   Verified | Partial | Missing | Pending | N/A
```

A task is not Done until its tests ran and passed. Board layout: `assets/status-report.md`.

### Intra-wave review

After a wave's tasks finish and before its gate, review the wave's diff against the contracts,
the selected patterns, the test plan, and existing code (duplicated utilities, parallel patterns).
Small waves: review inline. Large waves: one general-purpose review agent with the diff and
contracts. CRITICAL findings re-dispatch the owner (counts as a retry); HIGH re-dispatch if the
retry budget allows, otherwise flag to the user; MEDIUM goes on the tech-debt list.

### Wave gate

Advance only when every item has evidence:

```
[ ] Every task in the wave: Impl Done, tests written, TEST REPORT with real runner output
[ ] Build output shows zero errors; no compiler warnings on new code
[ ] Zero failing tests
[ ] ARCH reviewed outputs for contract compliance (API shape, errors, pagination, idempotency)
[ ] OBS (when present) verified events, metrics, spans, readiness scope against its contract
[ ] Evidence saved under .spec-to-impl/evidence/wave-<n>/
```

"Tests should pass" without output fails the gate. On failure, halt and report per failing task:
what failed (test names or missing items), likely root cause, and the fix required.

### Retries

1. Re-dispatch with the exact errors and failing test names (continue the agent when the client
   supports it).
2. Narrow the scope: split the task, add an example from the existing codebase.
3. Give a skeleton of the expected structure and the minimum viable output.

After three failed attempts, escalate with one of: reassign (for example ARCH assists), decompose
into smaller sequential tasks, revise the requirement with the user, or defer to P2 with a
recorded follow-up. Never retry without new information.

### Spec drift

Every two waves, ARCH re-reads the spec: no silently dropped FR, no scope creep, NFRs still
reachable.

## Phase 4: Integration review

After the last wave (and after merging agent branches, if any):

1. **Contracts**: BE APIs match what FE consumes; schemas align across services.
2. **API standards**: run the checklist in `references/api-standards.md` (section 6.5).
3. **Design compliance** (Figma source only): per screen PASS/WARN/FAIL against its frame, plus
   token and component-map coverage.
4. **Test coverage**: every P0/P1 FR has passing tests; no spec requirement without an output.
5. **Cross-cutting**: auth, error handling, and logging applied consistently.
6. **Observability** (OBS only): the OBS verification checklist in
   `references/be-fe-qa-dba-devops.md`.
7. **Duplicates**: new classes or utilities that reimplement existing ones. Replace with the
   existing one before finishing.
8. **Live verification**: run `verify-impl` against the running system. Its failures are
   integration blockers; the review is not complete until it reports ready.

Report: passed checks, warnings, failures, duplicates resolved, and observability status.

## Wrap-up and delivery

- Merge agent branches into the working branch only (see `references/execution.md`); record the
  pre-merge SHA as the rollback point. Clean up merged worktrees.
- Keep `e2e/` and `.spec-to-impl/evidence/`; downstream skills read them.
- Do not push, open a PR, merge to the default branch, or tag unless the user asked and the repo
  delivery policy allows it. Commits and PRs follow the repo's policy, with no AI attribution
  unless that policy requires it. Hand delivery to `finalize`.
- Write the handoff manifest (Output contract below), then tell the user: what was built, gate
  and verification results, the pre-merge SHA, and the suggested next skills.

## Status reporting

On request, after each wave, and immediately when a blocker appears, send the report in
`assets/status-report.md`. Honor a cadence the user sets ("report every N tasks").

## Plan mutations

| Request | Action |
|---|---|
| Add task | Create TASK-N+1, assign a role, insert into the graph, recompute waves |
| Re-assign TASK-X to Y | Update the role, re-dispatch Y with full context |
| Mark TASK-X done / skip | Update status; unblock or re-route dependents |
| Reprioritize to P0 | Move to the earliest wave its dependencies allow |
| What depends on TASK-X | Walk the graph forward |
| Add Figma source | Run Phase 0, insert TASK-000, pause FE tasks until it completes |
| Update design | Re-run Phase 0; re-dispatch only FE tasks whose frames changed |
| Mark design approved / skip extraction | Unblock FE with the current package, or mark TASK-000 SKIP and go code-only |

## Failure handling

| Failure | Recovery |
|---|---|
| Contract mismatch between roles | ARCH issues an updated contract and re-dispatches the affected roles |
| Ambiguous spec section mid-run | Pause dependent tasks, ask the user; if unavailable, record the assumption |
| Context or token limit | Split the task and run the parts sequentially |
| Circular dependency | ARCH extracts the shared interface into its own task |
| Instrumentation or API-standard gaps at the gate | Fix in place before the gate; no re-implementation needed |
| OpenAPI drift | Regenerate from the implementation or fix the implementation to match the contract |
| Figma access denied or rate limited | Surface the auth or permission issue; reuse the cached package for tasks in the same wave |

## Workflow context

- Takes input from `prd`, `design-doc`, `api-design`, `data-design`, `ui-design`, `ticket-breakdown`; for a single concern (one endpoint, one migration, one workflow) use `api-first`, `db-migration`, or `temporal-workflow` instead.
- `ticket-breakdown` only plans tickets; this skill implements.
- Hands off to `verify-impl` (live checks against `e2e/test-plan.yaml`) and then `finalize` (commit, PR, archive).

## Output contract

Write `claudedocs/handoff-spec-to-impl-<feature>-<timestamp>.yaml` (schema in the `handoff` skill):

```yaml
schema_version: "2.0"
source_skill: "spec-to-impl"
feature: "<feature-name>"
timestamp: "<ISO 8601 UTC>"
artifacts:
  - path: "e2e/test-plan.yaml"
    type: "test-plan"
    status: "ready"
    summary: "<N> test cases across API, DB, and UI layers"
    consumed_by: ["verify-impl"]
  - path: "<each produced source directory>"
    type: "code"
    status: "ready"
    summary: "<what was implemented>"
    consumed_by: ["verify-impl", "code-review", "code-audit"]
  - path: "claudedocs/<feature>-observability-contract.md"   # only when OBS ran
    type: "architecture"
    status: "ready"
    summary: "Logging, metrics, and tracing requirements"
    consumed_by: ["monitoring-plan"]
quality:
  status: "complete"
  ambiguities: []
consumed_from:
  - "<each upstream handoff manifest read in Step 0>"
suggested_next:
  - skill: "verify-impl"
    reason: "Implementation complete, ready for live verification"
    context: "e2e/test-plan.yaml has N test cases"
    reads: ["e2e/test-plan.yaml"]
  - skill: "finalize"
    reason: "After verification, commit and deliver per repo policy"
    context: "<branch name, pre-merge SHA>"
    reads: []
  - skill: "monitoring-plan"   # only when OBS ran
    reason: "Observability contract ready to operationalize"
    context: "Contract and dashboard spec ready"
    reads: ["claudedocs/<feature>-observability-contract.md"]
lifecycle:
  archivable_after: ["verify-impl", "finalize"]
  archive_policy: "after-finalize"
```
