# API layer

Execute every `api` block selected from the test plan against the live service.

## Auth

Credentials come from the environment or the repo's gitignored verification config, never from a
committed file and never typed into the transcript. The plan's `environment.auth` block supplies
`type` and `login_path`; its `username`/`password` are placeholders that environment values override.

```bash
LOGIN_PATH=$(yq '.environment.auth.login_path' e2e/test-plan.yaml)
: "${TEST_USER:?set TEST_USER (or the repo's documented variable)}"
: "${TEST_PASS:?set TEST_PASS (or the repo's documented variable)}"

TOKEN=$(jq -n --arg u "$TEST_USER" --arg p "$TEST_PASS" '{username:$u,password:$p}' \
  | curl -s -X POST "$BASE_URL$LOGIN_PATH" -H "Content-Type: application/json" -d @- \
  | jq -r '.data.accessToken // .token // empty')
[ -z "$TOKEN" ] && { echo "FAIL auth: no token"; exit 1; }
```

Never print the token. Adapt the login body and token path to the project's real auth contract.

## Execution (test plan mode)

```python
# Pseudocode: the agent runs this step by step
for tc in selected_test_cases:
    if not tc.api: continue
    if tc.setup: run_sql(tc.setup)          # local or disposable DB only
    captured = {}
    for step in tc.api:
        path = resolve_vars(step.path, captured)
        body = resolve_vars(step.body, captured)
        response, status = http_call(step.method, BASE_URL + path, body, skip_auth=step.skip_auth)
        captured.update(extract_captures(response, step.capture))   # JSONPath
        assert_eq(status, step.expect.status)
        for field in step.expect.body_fields:  assert_present(response, field)
        for field, value in step.expect.body_values.items():  assert_eq(lookup(response, field), value)
    write_captures(tc.id, captured)            # e2e/.captures.json, keyed by test case ID
    if tc.teardown: run_sql(resolve_vars(tc.teardown, captured))
```

- Error responses: assert the RFC 9457 Problem Details shape (`type`, `title`, `status`, `detail`)
  where the project uses it, not just the status code.
- Money operations: replay the same request with the same idempotency key and assert one effect,
  not two.
- Auth: assert 401 without a token and 403 for a role that lacks permission when the change touches
  authorization.

`scripts/api-test-runner.sh` is a standalone curl template for repos without a test plan; copy it
and replace the `REPLACE_*` placeholders.

## Result skeleton

```
API - <n> test cases, <passed> passed, <failed> failed
TC-001 [P0] <title>
  step 1  POST /api/v1/<resource>        201  PASS  (captured resource_id)
  step 3  POST /api/v1/<resource> {}     400  FAIL  expected 400 got 201
          Response: <actual body, secrets redacted>
```
