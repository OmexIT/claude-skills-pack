# E2E Test Plan Schema

Shared contract between `spec-to-impl` (producer) and `verify-impl` (consumer).

Generated during the PLAN phase. Saved to: `e2e/test-plan.yaml`

---

## Full Schema

```yaml
# e2e/test-plan.yaml
project:        "<project name>"
generated:      "<ISO timestamp>"
source_specs:   ["<spec file 1>", "<spec file 2>"]
generated_by:   "spec-to-impl / QA agent"
schema_version: "1.0"

# Global environment (overridable by env vars at runtime)
environment:
  api_url:      "http://localhost:8080"
  frontend_url: "http://localhost:3000"
  db_host:      "localhost"
  db_port:      5432
  db_name:      "<dbname>"
  db_user:      "<user>"
  auth:
    type:       "jwt"                  # jwt | basic | apikey | none
    login_path: "/api/v1/auth/login"
    username:   "test@example.com"
    password:   "testpass123"

test_cases:

  - id:        TC-001
    title:     "<human readable title>"
    fr_ref:    FR-001              # requirement this validates
    priority:  P0                  # P0 | P1 | P2
    tags:      [happy-path, auth]  # free-form tags
    setup:     |                   # optional: SQL or API calls to run before this TC
      INSERT INTO users (id, email) VALUES ('seed-uuid', 'test@example.com');

    # ── API Layer ──────────────────────────────────────────────────────────
    api:
      - step:          1
        description:   "Create resource"
        method:        POST
        path:          "/api/v1/<resource>"
        headers:
          Content-Type: "application/json"
        body:
          field1:      "value1"
          amount:      1000
        expect:
          status:      201
          body_fields: ["id", "status", "amount"]   # fields that must exist
          body_values:                               # exact values to assert
            status:    "PENDING"
        capture:                                     # save response fields for later steps
          resource_id: "$.data.id"

      - step:          2
        description:   "Retrieve created resource"
        method:        GET
        path:          "/api/v1/<resource>/{resource_id}"  # {var} uses captured values
        expect:
          status:      200
          body_values:
            amount:    1000

      - step:          3
        description:   "Validation — empty body returns 400"
        method:        POST
        path:          "/api/v1/<resource>"
        body:          {}
        expect:
          status:      400

      - step:          4
        description:   "Auth enforcement — no token returns 401"
        method:        GET
        path:          "/api/v1/<resource>"
        skip_auth:     true
        expect:
          status:      401

    # ── DB Layer ───────────────────────────────────────────────────────────
    db:
      - check:         "row_exists"
        description:   "Record persisted to DB"
        table:         "<table_name>"
        where:
          id:          "{resource_id}"           # {var} uses captured API values
        expect_count:  1

      - check:         "field_value"
        description:   "Amount stored correctly"
        table:         "<table_name>"
        where:
          id:          "{resource_id}"
        field:         "amount"
        expect:        "1000.00"

      - check:         "field_value"
        description:   "Status is PENDING"
        table:         "<table_name>"
        where:
          id:          "{resource_id}"
        field:         "status"
        expect:        "PENDING"

      - check:         "not_null"
        description:   "Audit fields populated"
        table:         "<table_name>"
        where:
          id:          "{resource_id}"
        fields:        ["created_at", "updated_at"]

      - check:         "no_orphans"
        description:   "No orphaned child records"
        parent_table:  "<parent_table>"
        child_table:   "<child_table>"
        join_key:      "parent_id"
        expect_count:  0

      - check:         "ledger_balanced"       # fintech-specific
        description:   "Double-entry ledger balanced"
        table:         "ledger_entries"
        transaction_id_field: "transaction_id"
        transaction_id_value: "{resource_id}"
        debit_field:   "debit_amount"
        credit_field:  "credit_amount"

    # ── UI Layer ───────────────────────────────────────────────────────────
    ui:
      - flow:          "happy_path"
        description:   "User completes primary flow end-to-end"
        steps:
          - action:    goto
            url:       "/<route>"
          - action:    fill
            selector:  "[data-testid='amount']"
            value:     "1000"
          - action:    select
            selector:  "[data-testid='currency']"
            value:     "KES"
          - action:    click
            selector:  "[data-testid='submit-btn']"
          - action:    assert_visible
            selector:  "[data-testid='success-message']"
            timeout_ms: 5000
          - action:    assert_text
            selector:  "[data-testid='success-message']"
            contains:  "submitted successfully"
          - action:    screenshot
            name:      "tc001-success"

      - flow:          "validation"
        description:   "Empty form shows required field errors"
        steps:
          - action:    goto
            url:       "/<route>"
          - action:    click
            selector:  "[data-testid='submit-btn']"
          - action:    assert_visible
            selector:  "[data-testid='amount-error']"
          - action:    screenshot
            name:      "tc001-validation"

    teardown: |                        # optional: cleanup after test case
      DELETE FROM <table> WHERE id = '{resource_id}';
```

---

## Minimal Test Case (API only)

```yaml
- id:       TC-010
  title:    "Health check endpoint returns 200"
  fr_ref:   NFR-001
  priority: P0
  api:
    - step:     1
      method:   GET
      path:     "/actuator/health"
      skip_auth: true
      expect:
        status: 200
        body_values:
          status: "UP"
```

---

## Variable Capture and Reference

Variables captured in one step are referenced in later steps using `{var_name}` syntax.

```yaml
# Step 1 captures:
capture:
  resource_id: "$.data.id"    # JSONPath into response body
  token:       "$.data.token"

# Step 2 uses:
path: "/api/v1/resource/{resource_id}"

# DB checks use:
where:
  id: "{resource_id}"

# UI steps use:
value: "{resource_id}"
```

---

## File Location Convention

```
<project-root>/
└── e2e/
    ├── test-plan.yaml          ← generated by spec-to-impl, consumed by verify-impl
    ├── screenshots/            ← written by verify-impl during UI tests
    └── reports/
        └── verify-<timestamp>.log
```
