#!/usr/bin/env bash
# api-test-runner.sh — template for verify-impl API layer
# Usage: BASE_URL=http://localhost:8080 ./api-test-runner.sh

set -euo pipefail

BASE_URL="${BASE_URL:-http://localhost:8080}"
PASS=0
FAIL=0
RESULTS=()

# ── Helpers ─────────────────────────────────────────────────────────────────

assert_status() {
  local label="$1" expected="$2" actual="$3"
  if [ "$actual" = "$expected" ]; then
    echo "  ✅ $label → $actual"
    RESULTS+=("PASS|$label|$actual")
    ((PASS++))
  else
    echo "  ❌ $label → expected=$expected actual=$actual"
    RESULTS+=("FAIL|$label|expected=$expected actual=$actual")
    ((FAIL++))
  fi
}

assert_json_field() {
  local label="$1" field="$2" expected="$3" json="$4"
  local actual
  actual=$(echo "$json" | jq -r "$field" 2>/dev/null || echo "PARSE_ERROR")
  if [ "$actual" = "$expected" ]; then
    echo "  ✅ $label → $field = $actual"
    RESULTS+=("PASS|$label|$field=$actual")
    ((PASS++))
  else
    echo "  ❌ $label → $field expected=$expected actual=$actual"
    RESULTS+=("FAIL|$label|$field expected=$expected actual=$actual")
    ((FAIL++))
  fi
}

http_get() {
  curl -s -w "\n%{http_code}" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Accept: application/json" \
    "$BASE_URL$1"
}

http_post() {
  local path="$1" body="$2"
  curl -s -w "\n%{http_code}" \
    -X POST \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d "$body" \
    "$BASE_URL$path"
}

parse_response() {
  local raw="$1"
  BODY=$(echo "$raw" | head -n -1)
  STATUS=$(echo "$raw" | tail -n 1)
}

# ── 1. Auth ──────────────────────────────────────────────────────────────────

echo ""
echo "━━━ AUTH ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
RAW=$(curl -s -w "\n%{http_code}" \
  -X POST "$BASE_URL/api/v1/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"username":"test@example.com","password":"testpass123"}')
parse_response "$RAW"

assert_status "Login" "200" "$STATUS"
TOKEN=$(echo "$BODY" | jq -r '.data.accessToken // empty')

if [ -z "$TOKEN" ]; then
  echo "❌ FATAL: No token obtained. Cannot continue."
  exit 1
fi
echo "  🔑 Token obtained: ${TOKEN:0:20}..."

# ── 2. CRUD Happy Path ───────────────────────────────────────────────────────

echo ""
echo "━━━ CREATE ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
RAW=$(http_post "/api/v1/REPLACE_RESOURCE" '{
  "field1": "value1",
  "amount": 1000
}')
parse_response "$RAW"

assert_status "Create resource" "201" "$STATUS"
RESOURCE_ID=$(echo "$BODY" | jq -r '.data.id // empty')
echo "  🆔 Resource ID: $RESOURCE_ID"

echo ""
echo "━━━ READ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
RAW=$(http_get "/api/v1/REPLACE_RESOURCE/$RESOURCE_ID")
parse_response "$RAW"
assert_status "Get by ID" "200" "$STATUS"
assert_json_field "Amount persisted" ".data.amount" "1000" "$BODY"

# ── 3. Validation / Error Cases ──────────────────────────────────────────────

echo ""
echo "━━━ VALIDATION ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
RAW=$(http_post "/api/v1/REPLACE_RESOURCE" '{}')
parse_response "$RAW"
assert_status "Empty payload → 400" "400" "$STATUS"

# ── 4. Auth Enforcement ──────────────────────────────────────────────────────

echo ""
echo "━━━ AUTH ENFORCEMENT ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
STATUS_NO_TOKEN=$(curl -s -o /dev/null -w "%{http_code}" \
  "$BASE_URL/api/v1/REPLACE_RESOURCE")
assert_status "No token → 401" "401" "$STATUS_NO_TOKEN"

STATUS_BAD_TOKEN=$(curl -s -o /dev/null -w "%{http_code}" \
  -H "Authorization: Bearer invalidtoken" \
  "$BASE_URL/api/v1/REPLACE_RESOURCE")
assert_status "Bad token → 401" "401" "$STATUS_BAD_TOKEN"

# ── Summary ──────────────────────────────────────────────────────────────────

echo ""
echo "━━━ API TEST SUMMARY ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ✅ Passed: $PASS"
echo "  ❌ Failed: $FAIL"

# Write captured variables to e2e/.captures.json for consumption by DB and UI layers
mkdir -p e2e
echo "{ \"captures\": $(echo "${CAPTURES:-{}}" | jq .) }" > e2e/.captures.json
echo "  💾 Captures written to e2e/.captures.json"
echo ""
if [ "$FAIL" -gt 0 ]; then
  echo "  Failed checks:"
  for r in "${RESULTS[@]}"; do
    IFS='|' read -r status label detail <<< "$r"
    [ "$status" = "FAIL" ] && echo "    ❌ $label — $detail"
  done
  exit 1
else
  echo "  🎉 All API checks passed"
  exit 0
fi
