#!/usr/bin/env bash
# db-verify.sh - psql template for the verify-impl DB layer. Read-only checks.
# Copy it, replace REPLACE_TABLE / REPLACE_CHILD_TABLE, and run:
#   RESOURCE_ID=<captured id> DB_NAME=... DB_USER=... ./db-verify.sh
# The password comes from PGPASSWORD (or the Compose service); never commit it.

set -euo pipefail

: "${RESOURCE_ID:?set RESOURCE_ID to the id captured by the API layer}"
: "${DB_NAME:?set DB_NAME}"
: "${DB_USER:?set DB_USER}"

PASS=0
FAIL=0

if docker compose ps 2>/dev/null | grep -q "db.*running"; then
  PSQL() { docker compose exec -T db psql -U "$DB_USER" -d "$DB_NAME" -t -A "$@"; }
  echo "Connected via Docker Compose"
else
  : "${PGPASSWORD:?set PGPASSWORD}"
  export PGPASSWORD
  PSQL() { psql -h "${DB_HOST:-localhost}" -U "$DB_USER" -d "$DB_NAME" -t -A "$@"; }
  echo "Connected via direct psql"
fi

if ! PSQL -c "SELECT 1;" >/dev/null 2>&1; then
  echo "FAIL DB connection" >&2
  exit 1
fi

assert_db() {
  local label="$1" query="$2" expected="$3" actual
  actual=$(PSQL -c "$query" 2>&1 | tr -d '[:space:]')
  if [ "$actual" = "$expected" ]; then
    echo "  PASS $label"
    PASS=$((PASS + 1))
  else
    echo "  FAIL $label: expected $expected, got $actual"
    echo "       $query"
    FAIL=$((FAIL + 1))
  fi
}

echo "== Row existence"
assert_db "Resource row created" \
  "SELECT COUNT(*) FROM REPLACE_TABLE WHERE id = '$RESOURCE_ID';" "1"

echo "== Data integrity"
# NUMERIC compares as text at the column's scale.
assert_db "Amount correct" \
  "SELECT amount FROM REPLACE_TABLE WHERE id = '$RESOURCE_ID';" "1000.00"
assert_db "Status is PENDING" \
  "SELECT status FROM REPLACE_TABLE WHERE id = '$RESOURCE_ID';" "PENDING"
assert_db "Audit timestamps populated" \
  "SELECT created_at IS NOT NULL AND updated_at IS NOT NULL FROM REPLACE_TABLE WHERE id = '$RESOURCE_ID';" "t"

echo "== Referential integrity"
assert_db "No orphaned child records" \
  "SELECT COUNT(*) FROM REPLACE_CHILD_TABLE c LEFT JOIN REPLACE_TABLE p ON c.parent_id = p.id WHERE p.id IS NULL;" "0"

echo "== Ledger balance"
# Entries must exist: an unwritten ledger would otherwise pass as balanced.
assert_db "Ledger entries exist and balance" \
  "SELECT COUNT(*) >= 2 AND COALESCE(SUM(debit_amount), 0) = COALESCE(SUM(credit_amount), 0)
   FROM ledger_entries WHERE transaction_id = '$RESOURCE_ID';" "t"

echo "== Row evidence"
PSQL -x -c "SELECT * FROM REPLACE_TABLE WHERE id = '$RESOURCE_ID';"

echo "== Summary: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
