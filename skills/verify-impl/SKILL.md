---
name: verify-impl
description: >
  Use this skill to verify a completed implementation through live testing — API calls, database state checks, and UI automation with Playwright. Triggers include: "test the implementation", "verify this works", "run API tests", "check the database", "test the UI", "end-to-end verify", "smoke test", "sanity check the implementation", "manually test", or any time an implementation needs post-build validation beyond unit tests. Also triggered automatically by spec-to-impl during the integration review phase. Use this when you want real evidence the system works — not just that tests compile. Can consume a pre-generated e2e/test-plan.yaml from spec-to-impl for fully automated test execution.
arguments: >
  Optional flags and/or a path to a test plan file.
  Examples:
    /verify-impl                             → auto-discover test-plan.yaml, run all layers
    /verify-impl --api                       → API layer only
    /verify-impl --db                        → DB layer only
    /verify-impl --ui                        → Playwright UI layer only
    /verify-impl --api --db                  → API + DB, skip UI
    /verify-impl e2e/test-plan.yaml          → consume specific test plan, run all layers
    /verify-impl e2e/test-plan.yaml --api    → consume test plan, API layer only
    /verify-impl --tc TC-001 TC-003          → run specific test cases only
    /verify-impl path/to/spec.md             → no test plan exists yet, derive from spec
---

# Verify-Impl: Live Implementation Verification Skill

Validates a completed implementation through three verification layers:
**API testing → Database state verification → UI automation (Playwright)**

Driven by a pre-generated `e2e/test-plan.yaml` when available (produced by `spec-to-impl`).
Falls back to spec-derived or auto-discovered scenarios when no test plan exists.

Each layer produces real evidence: actual HTTP responses, real DB rows, real browser screenshots.

---

## 0. Quick Decision Tree

```
$ARGUMENTS parsed:
  ├─ path ending in .yaml/.yml     → LOAD TEST PLAN (Section 0.1) → run selected layers
  ├─ path ending in .md            → READ SPEC → derive test plan inline → run all layers
  ├─ --tc TC-001 TC-002 ...        → LOAD TEST PLAN → filter to named TCs → run
  ├─ --api / --db / --ui flags     → LOAD TEST PLAN (or discover) → run flagged layers only
  └─ (no args)
       ├─ e2e/test-plan.yaml exists?  → LOAD IT → run all layers
       └─ not found                  → Section 1: discover from codebase → run all layers
```

---

## 0.1 Test Plan Loading

**This is the preferred execution mode** — driven by the YAML contract generated during `spec-to-impl` planning.

### Auto-discover:
```bash
# Check default location first
ls -la e2e/test-plan.yaml 2>/dev/null && echo "✅ Found" || echo "⚠️  Not found"
```

### Load and parse:
```bash
# Show summary of what's in the plan
cat e2e/test-plan.yaml | python3 -c "
import sys, yaml
plan = yaml.safe_load(sys.stdin)
tcs = plan.get('test_cases', [])
print(f'Project:     {plan[\"project\"]}')
print(f'Generated:   {plan[\"generated\"]}')
print(f'Test Cases:  {len(tcs)}')
for tc in tcs:
    layers = [l for l in [\"api\",\"db\",\"ui\"] if tc.get(l)]
    print(f'  {tc[\"id\"]} [{tc[\"priority\"]}] {tc[\"title\"]} — layers: {layers}')
"
```

### Report what was loaded:
```
📋 TEST PLAN LOADED
  Source:      e2e/test-plan.yaml
  Project:     <project name>
  Generated:   <timestamp> by spec-to-impl
  Test Cases:  <n>
    P0:  <n>  (must all pass)
    P1:  <n>
    P2:  <n>

  Layers present:
    API:  <n> test cases with API steps
    DB:   <n> test cases with DB checks
    UI:   <n> test cases with UI flows

  Running: <all | --tc filter | --api/--db/--ui>
```

### Filter by --tc flag:
```bash
# If --tc TC-001 TC-003 was passed, only run those IDs
# Otherwise run all (or all matching --api/--db/--ui scope)
```

> If test plan not found AND no spec file provided: fall through to Section 1 (codebase discovery). Warn the user that test coverage will be best-effort.

---

Before any testing, establish what's running and what to test.

### 1.1 Environment Discovery

```bash
# Confirm services are up
docker compose ps                          # check all containers running
curl -sf http://localhost:8080/actuator/health | jq .   # Spring Boot health
curl -sf http://localhost:3000             # Frontend health

# Grab base URLs and credentials from env
cat .env | grep -E 'API_URL|DB_|APP_PORT|JWT|SECRET'
```

Report what's found:
```
🔍 ENVIRONMENT
  API:      http://localhost:8080   ✅ UP
  Frontend: http://localhost:3000   ✅ UP
  Database: localhost:5432/appdb    ✅ UP
  Auth:     JWT (secret from .env)  ✅ Found
```

If any service is DOWN → stop and report. Do not proceed with that layer.

### 1.2 Test Scenario Derivation

If a spec file was passed as argument, read it and extract:
- Key user flows to exercise (happy path per FR)
- Edge cases flagged in the spec
- Data states that must exist after each flow

If no spec file, infer from the codebase:
```bash
# Find controllers/routes to derive API surface
find . -name "*Controller*" -o -name "*Router*" -o -name "routes.ts" | head -20
# Find DB tables to derive verification queries
grep -r "CREATE TABLE\|@Entity\|@Table" --include="*.sql" --include="*.java" -l
# Find Playwright test files if any exist
find . -name "*.spec.ts" -o -name "*.e2e.ts" | head -10
```

---

## 2. API Verification Layer

**Goal**: Execute every `api` block from the test plan against the live service.

### 2.1 Auth Setup

```bash
# Read auth config from test plan environment block
LOGIN_PATH=$(yq '.environment.auth.login_path' e2e/test-plan.yaml)
USERNAME=$(yq '.environment.auth.username'   e2e/test-plan.yaml)
PASSWORD=$(yq '.environment.auth.password'   e2e/test-plan.yaml)

TOKEN=$(curl -s -X POST "$BASE_URL$LOGIN_PATH" \
  -H "Content-Type: application/json" \
  -d "{\"username\":\"$USERNAME\",\"password\":\"$PASSWORD\"}" \
  | jq -r '.data.accessToken // .token // empty')

[ -z "$TOKEN" ] && echo "❌ FATAL: auth failed" && exit 1
echo "🔑 Token: ${TOKEN:0:20}..."
```

### 2.2 Test Case Execution (Test Plan Mode)

For each test case with an `api` block, execute steps in sequence. Capture variables and thread them through subsequent steps.

```python
# Pseudocode — Claude executes this logic step by step

for tc in test_plan.test_cases:
    if tc has no api block: skip
    if tc.id not in selected_tcs: skip

    print(f"\n── TC {tc.id}: {tc.title} ──")

    # Run setup SQL if present
    if tc.setup: run_sql(tc.setup)

    captured = {}   # variable store across steps

    for step in tc.api.steps:
        path = resolve_vars(step.path, captured)  # replace {resource_id} etc.
        body = resolve_vars(step.body, captured)

        response, status = http_call(step.method, BASE_URL + path, body,
                                     skip_auth=step.skip_auth)
        captured.update(extract_captures(response, step.capture))

        # Assert status
        assert_eq(f"TC {tc.id} step {step.step} status",
                  expected=step.expect.status, actual=status)

        # Assert body fields exist
        for field in step.expect.body_fields:
            assert_not_null(f"  field '{field}' present", response[field])

        # Assert exact body values
        for field, value in step.expect.body_values.items():
            assert_eq(f"  {field}", expected=value, actual=response['data'][field])

    # Run teardown SQL if present
    if tc.teardown: run_sql(resolve_vars(tc.teardown, captured))
```

### 2.3 API Test Result Format

```
API VERIFICATION — TEST PLAN MODE
===================================
Test Cases Run: <n>
  ✅ Passed: <n>
  ❌ Failed: <n>

TC-001 [P0] User submits money request
  step 1  POST /api/v1/money-requests      201  ✅  (captured: resource_id=abc-123)
  step 2  GET  /api/v1/money-requests/abc  200  ✅
  step 3  POST /api/v1/money-requests {}   400  ✅  (validation enforced)
  step 4  GET  /api/v1/money-requests      401  ✅  (auth enforced)

TC-002 [P0] Payment link generation
  step 1  POST /api/v1/payment-links       201  ✅  (captured: link_id=def-456)
  step 2  GET  /api/v1/payment-links/def   200  ✅
  step 3  GET  /api/v1/payment-links/bad   404  ✅
  step 4  POST /api/v1/payment-links {}    400  ❌  FAIL — expected 400 got 201
          Response: {"data":{"id":"xyz","status":"ACTIVE"}}
          → Missing validation for empty payload on payment-links endpoint
```

---

## 3. Database Verification Layer

**Goal**: Execute every `db` block from the test plan against the live database, using variable values captured during the API layer.

### 3.1 Connection Setup

```bash
# Read connection from test plan environment block
DB_HOST=$(yq '.environment.db_host' e2e/test-plan.yaml)
DB_NAME=$(yq '.environment.db_name' e2e/test-plan.yaml)
DB_USER=$(yq '.environment.db_user' e2e/test-plan.yaml)

# Docker Compose preferred; fall back to direct psql
if docker compose ps 2>/dev/null | grep -q "db.*running"; then
  PSQL() { docker compose exec -T db psql -U $DB_USER -d $DB_NAME -t -A -c "$1"; }
else
  export PGPASSWORD=$DB_PASSWORD
  PSQL() { psql -h $DB_HOST -U $DB_USER -d $DB_NAME -t -A -c "$1"; }
fi
PSQL "SELECT 1;" > /dev/null && echo "✅ DB connected" || { echo "❌ DB connection failed"; exit 1; }
```

### 3.2 Test Case Execution (Test Plan Mode)

For each test case with a `db` block, run checks using captured API values:

```python
# Pseudocode — each check type maps to a SQL pattern

for tc in test_plan.test_cases:
    if tc has no db block: skip

    for check in tc.db.checks:
        where_clause = resolve_vars(check.where, captured_from_api[tc.id])

        if check.type == "row_exists":
            sql = f"SELECT COUNT(*) FROM {check.table} WHERE {where_clause};"
            assert_eq(check.description, expected=check.expect_count, actual=run_sql(sql))

        elif check.type == "field_value":
            sql = f"SELECT {check.field} FROM {check.table} WHERE {where_clause};"
            assert_eq(check.description, expected=check.expect, actual=run_sql(sql))

        elif check.type == "not_null":
            for field in check.fields:
                sql = f"SELECT {field} FROM {check.table} WHERE {where_clause};"
                assert_not_null(f"{check.description} — {field}", run_sql(sql))

        elif check.type == "no_orphans":
            sql = f"""SELECT COUNT(*) FROM {check.child_table} c
                      LEFT JOIN {check.parent_table} p ON c.{check.join_key} = p.id
                      WHERE p.id IS NULL;"""
            assert_eq(check.description, expected=0, actual=run_sql(sql))

        elif check.type == "ledger_balanced":
            sql = f"""SELECT ABS(
                        SUM(CASE WHEN entry_type='DEBIT'  THEN {check.debit_field}  ELSE 0 END) -
                        SUM(CASE WHEN entry_type='CREDIT' THEN {check.credit_field} ELSE 0 END)
                      ) FROM {check.table}
                      WHERE {check.transaction_id_field} = '{captured[check.transaction_id_value]}';"""
            assert_eq(check.description, expected="0", actual=run_sql(sql))
```

### 3.2.1 MongoDB Verification

For projects using MongoDB, connect via `mongosh` or Docker:

```bash
if docker compose ps 2>/dev/null | grep -q "mongo.*running"; then
  MONGO() { docker compose exec -T mongo mongosh --quiet --eval "$1" $DB_NAME; }
else
  MONGO() { mongosh --quiet --eval "$1" "mongodb://$DB_HOST:27017/$DB_NAME"; }
fi
```

Supported check types for MongoDB:

| Check type | Query pattern |
|---|---|
| `mongo_doc_exists` | `db.<collection>.countDocuments({<filter>})` |
| `mongo_field_value` | `db.<collection>.findOne({<filter>}).<field>` |
| `mongo_not_null` | `db.<collection>.findOne({<filter>}, {<field>: 1})` |
| `mongo_array_contains` | `db.<collection>.findOne({<filter>, <array_field>: {$elemMatch: {<condition>}}})` |

### 3.2.2 Elasticsearch Verification

For projects using Elasticsearch, connect via `curl`:

```bash
ES_URL="${ES_URL:-http://localhost:9200}"
curl -sf "$ES_URL/_cluster/health" | jq .status
```

Supported check types:

| Check type | Query pattern |
|---|---|
| `es_doc_exists` | `curl "$ES_URL/<index>/_doc/<id>"` — check `found: true` |
| `es_search` | `curl "$ES_URL/<index>/_search" -d '{"query": ...}'` — check `hits.total.value` |
| `es_index_exists` | `curl "$ES_URL/_cat/indices/<index>"` — check 200 status |
| `es_mapping_field` | `curl "$ES_URL/<index>/_mapping"` — verify field type |

### 3.2.3 Typesense Verification

For projects using Typesense:

```bash
TS_URL="${TS_URL:-http://localhost:8108}"
TS_KEY="${TS_API_KEY:-xyz}"
curl -sf -H "X-TYPESENSE-API-KEY: $TS_KEY" "$TS_URL/health"
```

Supported check types:

| Check type | Query pattern |
|---|---|
| `ts_doc_exists` | `GET /collections/<coll>/documents/<id>` |
| `ts_search` | `GET /collections/<coll>/documents/search?q=<query>&query_by=<field>` |
| `ts_collection_exists` | `GET /collections/<coll>` — check 200 status |

### 3.3 DB Verification Result Format

```
DATABASE VERIFICATION — TEST PLAN MODE
========================================
Test Cases Run: <n>
  ✅ Passed: <n>
  ❌ Failed: <n>

TC-001 [P0] User submits money request
  row_exists      money_requests WHERE id=abc-123          ✅  1 row
  field_value     amount = 1000.00                         ✅
  field_value     status = PENDING                         ✅
  not_null        created_at, updated_at                   ✅
  no_orphans      money_request_items → money_requests     ✅  0 orphans
  ledger_balanced transaction_id=abc-123                   ❌  imbalance=1000.00
                  → credit entry not created: check MoneyRequestService.postLedger()
```

---

## 4. UI Verification Layer (Playwright)

**Goal**: Execute every `ui` block from the test plan in a real browser. Capture screenshots as evidence per test case.

### 4.1 Playwright Setup Check

```bash
npx playwright --version 2>/dev/null || npm install -D @playwright/test
npx playwright install chromium --with-deps
curl -sf http://localhost:3000 > /dev/null && echo "✅ Frontend UP" || echo "❌ Frontend DOWN — cannot run UI tests"
```

### 4.2 Generate Playwright Spec from Test Plan

Convert the test plan `ui` blocks into a Playwright spec file, then run it:

```typescript
// Generated: e2e/verify-impl/test-plan.spec.ts
// Auto-generated by verify-impl from e2e/test-plan.yaml — do not edit manually

import { test, expect, Page } from '@playwright/test';
import * as yaml from 'js-yaml';
import * as fs from 'fs';
import * as path from 'path';

const plan   = yaml.load(fs.readFileSync('e2e/test-plan.yaml', 'utf8')) as any;
const BASE   = plan.environment.frontend_url || 'http://localhost:3000';
const SHOTS  = path.join(__dirname, 'screenshots');
if (!fs.existsSync(SHOTS)) fs.mkdirSync(SHOTS, { recursive: true });

// Load captured API values (written by API layer to e2e/.captures.json)
const captures: Record<string, Record<string, string>> = (() => {
  try { return JSON.parse(fs.readFileSync('e2e/.captures.json', 'utf8')); }
  catch { return {}; }
})();

async function resolveVar(val: string, tcId: string): Promise<string> {
  return val.replace(/\{(\w+)\}/g, (_, k) => captures[tcId]?.[k] ?? val);
}

// Login helper
async function login(page: Page) {
  const auth = plan.environment.auth;
  await page.goto(`${BASE}/login`);
  await page.fill('[data-testid="email"]',    auth.username);
  await page.fill('[data-testid="password"]', auth.password);
  await page.click('[data-testid="login-btn"]');
  await expect(page).toHaveURL(/dashboard|home/, { timeout: 5000 });
}

// Dynamically generate one test per UI flow per test case
for (const tc of plan.test_cases) {
  if (!tc.ui) continue;

  for (const flow of tc.ui) {
    test(`${tc.id} [${tc.priority}] ${tc.title} — ${flow.flow}`, async ({ page }) => {
      await login(page);

      for (const step of flow.steps) {
        const val = step.value ? await resolveVar(step.value, tc.id) : undefined;
        const sel = step.selector ? await resolveVar(step.selector, tc.id) : undefined;

        switch (step.action) {
          case 'goto':
            await page.goto(`${BASE}${step.url}`); break;
          case 'fill':
            await page.fill(sel!, val!); break;
          case 'click':
            await page.click(sel!); break;
          case 'select':
            await page.selectOption(sel!, val!); break;
          case 'assert_visible':
            await expect(page.locator(sel!)).toBeVisible({ timeout: step.timeout_ms ?? 5000 }); break;
          case 'assert_text':
            await expect(page.locator(sel!)).toContainText(step.contains!); break;
          case 'assert_url':
            await expect(page).toHaveURL(new RegExp(step.pattern!)); break;
          case 'screenshot':
            await page.screenshot({ path: path.join(SHOTS, `${step.name}.png`), fullPage: true });
            console.log(`  📸 ${step.name}.png`); break;
        }
      }
    });
  }
}
```

### 4.3 Execution

```bash
# Write captures from API layer so UI tests can use captured IDs
# (API layer writes to e2e/.captures.json automatically)

# Run the generated spec
npx playwright test e2e/verify-impl/test-plan.spec.ts \
  --reporter=list --retries=1 2>&1

# On failure, show traces
npx playwright test e2e/verify-impl/test-plan.spec.ts \
  --reporter=list --trace on 2>&1
```

### 4.4 UI Verification Result Format

```
UI VERIFICATION — TEST PLAN MODE (Playwright)
===============================================
Browser:  Chromium
Base URL: http://localhost:3000
Test Cases Run: <n>  |  Flows: <n>
  ✅ Passed: <n>
  ❌ Failed: <n>

TC-001 [P0] User submits money request
  ✅  happy_path   — payment submission              1.4s
  ✅  validation   — empty form errors shown         0.5s

TC-002 [P0] Payment link generation
  ✅  happy_path   — link generated and displayed    2.1s
  ❌  edge_case    — duplicate link warning          1.8s
     Timeout: [data-testid="duplicate-warning"] not visible within 5000ms
     Screenshot: tc002-edge-case-failure.png

Screenshots:
  e2e/verify-impl/screenshots/tc001-success.png
  e2e/verify-impl/screenshots/tc001-validation.png
  e2e/verify-impl/screenshots/tc002-success.png
  e2e/verify-impl/screenshots/tc002-edge-case-failure.png  ← failure evidence
```

---

## 4.5 Mobile Verification Layer

**Goal**: Verify Flutter, React Native, or Android implementations through unit tests, widget/component tests, and device emulation.

### 4.5.1 Flutter Verification

```bash
# Check Flutter is available
flutter --version 2>/dev/null || echo "❌ Flutter not installed"

# Run widget tests
flutter test --coverage 2>&1

# Run integration tests (requires device/emulator)
flutter test integration_test/ 2>&1

# Generate coverage report
genhtml coverage/lcov.info -o coverage/html 2>/dev/null
```

### 4.5.2 React Native Verification

```bash
# Run component tests
npx jest --ci --coverage 2>&1

# Run E2E tests with Detox (requires emulator)
npx detox test --configuration android.emu.debug 2>&1
```

### 4.5.3 Android Verification

```bash
# Run unit tests
./gradlew testDebugUnitTest 2>&1

# Run instrumented tests (requires device/emulator)
./gradlew connectedAndroidTest 2>&1

# Run Compose UI tests
./gradlew testDebugUnitTest --tests "*ComposeTest*" 2>&1
```

### 4.5.4 Device Emulation (Chrome DevTools)

For responsive web verification without a physical device:

```bash
# Use Chrome DevTools MCP to emulate mobile viewports
# iPhone 14: 390x844
# Pixel 7: 412x915
# iPad: 820x1180
```

### 4.5.5 Mobile Verification Result Format

```
MOBILE VERIFICATION
====================
Platform: <Flutter | React Native | Android>
  ✅ Passed: <n>
  ❌ Failed: <n>

Flutter Widget Tests:
  ✅ 24/24 passed (coverage: 87%)

React Native Component Tests:
  ✅ 18/18 passed

Android Unit Tests:
  ✅ 31/31 passed
  ❌ 2 instrumented tests failing
     LoginScreenTest.should_show_error_on_invalid_credentials
     PaymentFormTest.should_validate_amount_field
```

---

## 5. Final Verification Report

After all layers complete, produce a consolidated report:

```
╔══════════════════════════════════════════════════════════╗
║          VERIFY-IMPL REPORT — <Project/Feature>          ║
║          <Timestamp>                                     ║
╠══════════════════════════════════════════════════════════╣
║  Layer          │ Checks │ Passed │ Failed │ Status      ║
╠══════════════════════════════════════════════════════════╣
║  API            │   12   │   11   │   1    │ ❌ ISSUES   ║
║  Database       │    8   │    8   │   0    │ ✅ CLEAN    ║
║  UI (Playwright)│    5   │    4   │   1    │ ❌ ISSUES   ║
║  Mobile         │    3   │    3   │   0    │ ✅ CLEAN    ║
╠══════════════════════════════════════════════════════════╣
║  OVERALL        │   28   │   26   │   2    │ ❌ NOT READY║
╚══════════════════════════════════════════════════════════╝

❌ FAILURES REQUIRING ATTENTION

  [API] PUT /api/v1/payments/:id → 500
    Root cause: NullPointerException at PaymentService:142
    Fix: Check null guard before calling paymentRepository.update()

  [UI] Duplicate payment warning not appearing
    Root cause: Missing [data-testid="duplicate-warning"] on DuplicateAlert component
    Fix: Add data-testid attribute to the alert component

✅ VERIFIED WORKING
  - Auth flow (login / token / protected routes)
  - Payment creation (POST + DB persist + UI feedback)
  - Input validation (400s enforced at API + UI errors shown)
  - Ledger double-entry balance (DB check passed)
  - Audit trail (created_at, updated_at populated)

📸 EVIDENCE
  Screenshots: e2e/verify-impl/screenshots/
  Logs:        verify-impl-<timestamp>.log

📋 EVIDENCE INVENTORY (definition of done)
  Every P0 requirement must have ALL of these evidence types:
  | Requirement | Test Output | Screenshot | DB Check | API Response |
  |---|---|---|---|---|
  | FR-001 | ✅ | ✅ | ✅ | ✅ |
  | FR-002 | ✅ | ❌ missing | ✅ | ✅ |

  Evidence without actual command output = NOT ACCEPTED.
  "Tests pass" without pasted stdout = AUTOMATIC FAIL.

🎯 VERDICT
  ❌ NOT READY — 2 failures must be resolved before merge
  (or)
  ✅ READY TO MERGE — all checks passed, all evidence collected

📂 PERSIST RESULTS
  Save report to: e2e/reports/verify-<timestamp>.log
  Compare against previous: e2e/reports/verify-*.log | diff for regressions
```

---

## 6. Failure → Fix → Re-verify Loop

When failures are found, don't just report — drive the fix:

1. **Identify** the failure layer (API / DB / UI)
2. **Trace** to the root cause (check logs, stack traces, DB state)
3. **Fix** in the relevant worktree branch
4. **Re-run** only the failing checks (don't re-run the full suite unless needed)
5. **Update** the verification report with new results
6. **Repeat** until all checks pass

```bash
# Re-run only failing API test
curl -s -X PUT http://localhost:8080/api/v1/payments/$ID ...

# Re-run only failing Playwright test
npx playwright test --grep "duplicate payment" 2>&1
```

---

## 7. Reference Files

| File | When to Read |
|---|---|
| `scripts/api-test-runner.sh` | Template shell script for API verification |
| `scripts/db-verify.sh` | Template DB verification queries |
| `scripts/playwright-setup.sh` | Playwright install + browser setup |
| `templates/playwright-test.ts` | Playwright test file template |
| `references/data-testid-conventions.md` | Conventions for UI test selectors |
