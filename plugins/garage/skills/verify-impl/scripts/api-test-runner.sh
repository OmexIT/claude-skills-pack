#!/usr/bin/env bash
# api-test-runner.sh - curl template for the verify-impl API layer when no test plan exists.
# Copy it, replace the REPLACE_* values, and run from the project root:
#   BASE_URL=http://localhost:8080 TEST_USER=... TEST_PASS=... ./api-test-runner.sh
# Credentials come only from the environment; never commit them.

set -euo pipefail

BASE_URL="${BASE_URL:-http://localhost:8080}"
LOGIN_PATH="${LOGIN_PATH:-/api/v1/auth/login}"
: "${TEST_USER:?set TEST_USER}"
: "${TEST_PASS:?set TEST_PASS}"

PASS=0
FAIL=0
FAILED=()

pass() { echo "  PASS $1"; PASS=$((PASS + 1)); }
fail() { echo "  FAIL $1"; FAILED+=("$1"); FAIL=$((FAIL + 1)); }

assert_status() {
  local label="$1" expected="$2" actual="$3"
  if [ "$actual" = "$expected" ]; then pass "$label -> $actual"; else fail "$label -> expected $expected, got $actual"; fi
}

assert_json_field() {
  local label="$1" field="$2" expected="$3" json="$4" actual
  actual=$(printf '%s' "$json" | jq -r "$field" 2>/dev/null || echo "PARSE_ERROR")
  if [ "$actual" = "$expected" ]; then pass "$label -> $field = $actual"; else fail "$label -> $field expected $expected, got $actual"; fi
}

# Sets BODY and STATUS from a curl call that appended the status code as the last line.
request() {
  local raw
  raw=$(curl -s -w "\n%{http_code}" "$@")
  BODY=$(printf '%s\n' "$raw" | sed '$d')
  STATUS=$(printf '%s\n' "$raw" | tail -n 1)
}

auth_get() { request -H "Authorization: Bearer $TOKEN" -H "Accept: application/json" "$BASE_URL$1"; }
auth_post() {
  request -X POST -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" -d "$2" "$BASE_URL$1"
}

echo "== Auth"
request -X POST "$BASE_URL$LOGIN_PATH" -H "Content-Type: application/json" \
  -d "$(jq -n --arg u "$TEST_USER" --arg p "$TEST_PASS" '{username: $u, password: $p}')"
assert_status "Login" "200" "$STATUS"
TOKEN=$(printf '%s' "$BODY" | jq -r '.data.accessToken // .token // empty')
if [ -z "$TOKEN" ]; then
  echo "FAIL no token obtained; cannot continue" >&2
  exit 1
fi

echo "== Create"
auth_post "/api/v1/REPLACE_RESOURCE" '{"field1": "value1", "amount": "1000.00"}'
assert_status "Create resource" "201" "$STATUS"
RESOURCE_ID=$(printf '%s' "$BODY" | jq -r '.data.id // .id // empty')
echo "  resource id: $RESOURCE_ID"

echo "== Read"
auth_get "/api/v1/REPLACE_RESOURCE/$RESOURCE_ID"
assert_status "Get by ID" "200" "$STATUS"
assert_json_field "Amount persisted" ".data.amount" "1000.00" "$BODY"

echo "== Validation"
auth_post "/api/v1/REPLACE_RESOURCE" '{}'
assert_status "Empty payload" "400" "$STATUS"
assert_json_field "Problem Details status" ".status" "400" "$BODY"

echo "== Auth enforcement"
request "$BASE_URL/api/v1/REPLACE_RESOURCE"
assert_status "No token" "401" "$STATUS"
request -H "Authorization: Bearer invalid" "$BASE_URL/api/v1/REPLACE_RESOURCE"
assert_status "Bad token" "401" "$STATUS"

# Captures keyed by test case ID, read by the DB and UI layers.
mkdir -p e2e
jq -n --arg id "$RESOURCE_ID" '{"MANUAL": {resource_id: $id}}' > e2e/.captures.json

echo "== Summary: $PASS passed, $FAIL failed"
if [ "$FAIL" -gt 0 ]; then
  printf '  FAIL %s\n' "${FAILED[@]}"
  exit 1
fi
