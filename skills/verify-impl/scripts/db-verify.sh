#!/usr/bin/env bash
# db-verify.sh — template for verify-impl DB layer
# Usage: RESOURCE_ID=<uuid> ./db-verify.sh

set -euo pipefail

PASS=0
FAIL=0

# ── Connection ───────────────────────────────────────────────────────────────

# Try Docker Compose first, fall back to direct psql
if docker compose ps 2>/dev/null | grep -q "db.*running"; then
  PSQL() { docker compose exec -T db psql -U "${DB_USER:-postgres}" -d "${DB_NAME:-appdb}" -t -A -c "$1"; }
  echo "🔌 Connected via Docker Compose"
else
  export PGPASSWORD="${DB_PASSWORD:-postgres}"
  PSQL() { psql -h "${DB_HOST:-localhost}" -U "${DB_USER:-postgres}" -d "${DB_NAME:-appdb}" -t -A -c "$1"; }
  echo "🔌 Connected via direct psql"
fi

# Test connection
VERSION=$(PSQL "SELECT version();" 2>&1)
if echo "$VERSION" | grep -q "PostgreSQL"; then
  echo "✅ DB connection OK"
else
  echo "❌ DB connection FAILED: $VERSION"
  exit 1
fi

# ── Helpers ──────────────────────────────────────────────────────────────────

assert_db() {
  local label="$1" query="$2" expected="$3"
  local actual
  actual=$(PSQL "$query" 2>&1 | tr -d '[:space:]')
  if [ "$actual" = "$expected" ]; then
    echo "  ✅ $label"
    ((PASS++))
  else
    echo "  ❌ $label"
    echo "     Query:    $query"
    echo "     Expected: $expected"
    echo "     Actual:   $actual"
    ((FAIL++))
  fi
}

assert_not_null() {
  local label="$1" query="$2"
  local actual
  actual=$(PSQL "$query" 2>&1 | tr -d '[:space:]')
  if [ -n "$actual" ] && [ "$actual" != "" ] && [ "$actual" != "NULL" ]; then
    echo "  ✅ $label → $actual"
    ((PASS++))
  else
    echo "  ❌ $label — value is NULL or empty"
    ((FAIL++))
  fi
}

# ── Row Existence ─────────────────────────────────────────────────────────────

echo ""
echo "━━━ ROW EXISTENCE ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
assert_db \
  "Resource row created" \
  "SELECT COUNT(*) FROM REPLACE_TABLE WHERE id = '$RESOURCE_ID';" \
  "1"

# ── Data Integrity ────────────────────────────────────────────────────────────

echo ""
echo "━━━ DATA INTEGRITY ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
assert_db \
  "Amount correct" \
  "SELECT amount FROM REPLACE_TABLE WHERE id = '$RESOURCE_ID';" \
  "1000.00"

assert_db \
  "Status = PENDING" \
  "SELECT status FROM REPLACE_TABLE WHERE id = '$RESOURCE_ID';" \
  "PENDING"

# ── Audit Fields ──────────────────────────────────────────────────────────────

echo ""
echo "━━━ AUDIT FIELDS ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
assert_not_null \
  "created_at populated" \
  "SELECT created_at FROM REPLACE_TABLE WHERE id = '$RESOURCE_ID';"

assert_not_null \
  "updated_at populated" \
  "SELECT updated_at FROM REPLACE_TABLE WHERE id = '$RESOURCE_ID';"

# ── Referential Integrity ─────────────────────────────────────────────────────

echo ""
echo "━━━ REFERENTIAL INTEGRITY ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
assert_db \
  "No orphaned child records" \
  "SELECT COUNT(*) FROM REPLACE_CHILD_TABLE c
   LEFT JOIN REPLACE_TABLE p ON c.parent_id = p.id
   WHERE p.id IS NULL;" \
  "0"

# ── Ledger Balance (fintech double-entry) ─────────────────────────────────────

echo ""
echo "━━━ LEDGER BALANCE ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
IMBALANCE=$(PSQL "
  SELECT ABS(
    SUM(CASE WHEN entry_type='DEBIT'  THEN amount ELSE 0 END) -
    SUM(CASE WHEN entry_type='CREDIT' THEN amount ELSE 0 END)
  )
  FROM ledger_entries
  WHERE transaction_id = '$RESOURCE_ID';" 2>&1 | tr -d '[:space:]')

if [ "$IMBALANCE" = "0" ] || [ "$IMBALANCE" = "0.00" ]; then
  echo "  ✅ Ledger balanced (debits = credits)"
  ((PASS++))
else
  echo "  ❌ Ledger IMBALANCED — difference: $IMBALANCE"
  ((FAIL++))
fi

# ── Full Row Dump (for evidence) ──────────────────────────────────────────────

echo ""
echo "━━━ RAW ROW DATA ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
PSQL "\x on \n SELECT * FROM REPLACE_TABLE WHERE id = '$RESOURCE_ID';" 2>&1

# ── Summary ───────────────────────────────────────────────────────────────────

echo ""
echo "━━━ DB VERIFY SUMMARY ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ✅ Passed: $PASS"
echo "  ❌ Failed: $FAIL"

[ "$FAIL" -gt 0 ] && exit 1 || exit 0
