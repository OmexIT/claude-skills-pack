# DB layer

Execute every `db` block selected from the test plan, using values the API layer captured in
`e2e/.captures.json`. Read-only checks only; setup and teardown SQL run only against a local or
disposable database.

## PostgreSQL connection

```bash
# Docker Compose service first, then direct psql. Password comes from the environment only.
if docker compose ps 2>/dev/null | grep -q "db.*running"; then
  PSQL() { docker compose exec -T db psql -U "$DB_USER" -d "$DB_NAME" -t -A -c "$1"; }
else
  : "${PGPASSWORD:?set PGPASSWORD (or DB_PASSWORD via the repo's verification config)}"
  PSQL() { psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -t -A -c "$1"; }
fi
PSQL "SELECT 1;" >/dev/null || { echo "FAIL DB connection"; exit 1; }
```

Take host, name, and user from the plan's `environment` block or the repo's config.

## Check types (SQL)

| Check | SQL pattern | Pass when |
|---|---|---|
| `row_exists` | `SELECT COUNT(*) FROM <table> WHERE <where>` | equals `expect_count` |
| `field_value` | `SELECT <field> FROM <table> WHERE <where>` | equals `expect` (compare `NUMERIC` as text at the column's scale, for example `1000.00`) |
| `not_null` | `SELECT <field> FROM <table> WHERE <where>` per field | non-empty for every field |
| `no_orphans` | `SELECT COUNT(*) FROM <child> c LEFT JOIN <parent> p ON c.<join_key> = p.id WHERE p.id IS NULL` | `0` |
| `ledger_balanced` | see below | entries exist and net to zero |

`ledger_balanced` must prove entries exist, otherwise an unwritten ledger passes as balanced:

```sql
SELECT COUNT(*) >= 2
   AND COALESCE(SUM(<debit_field>), 0) = COALESCE(SUM(<credit_field>), 0)
FROM <table> WHERE <transaction_id_field> = '<captured id>';   -- expect t
```

For ledger changes also run the invariant queries from the `fintech-ledger` skill's references.
Time columns must be `TIMESTAMPTZ`; flag `TIMESTAMP` without zone. Money columns must be `NUMERIC`;
flag float or double.

`scripts/db-verify.sh` is a standalone psql template; copy it and replace the `REPLACE_*` names.

## MongoDB

```bash
if docker compose ps 2>/dev/null | grep -q "mongo.*running"; then
  MONGO() { docker compose exec -T mongo mongosh --quiet --eval "$1" "$DB_NAME"; }
else
  MONGO() { mongosh --quiet --eval "$1" "${MONGO_URL:?set MONGO_URL}"; }
fi
```

| Check | Query |
|---|---|
| `mongo_doc_exists` | `db.<coll>.countDocuments(<filter>)` |
| `mongo_field_value` | `db.<coll>.findOne(<filter>).<field>` |
| `mongo_not_null` | `db.<coll>.findOne(<filter>, {<field>: 1})` |
| `mongo_array_contains` | `db.<coll>.findOne({...<filter>, <array>: {$elemMatch: <cond>}})` |

## Elasticsearch

`ES_URL` from the environment (local default `http://localhost:9200`); check `_cluster/health` first.
Search indexes refresh asynchronously: call `POST <index>/_refresh` or retry briefly before failing.

| Check | Request | Pass when |
|---|---|---|
| `es_doc_exists` | `GET <index>/_doc/<id>` | `found: true` |
| `es_search` | `GET <index>/_search` with query | `hits.total.value` as expected |
| `es_index_exists` | `HEAD <index>` | 200 |
| `es_mapping_field` | `GET <index>/_mapping` | field has the expected type |

## Typesense

`TS_URL` and `TS_API_KEY` from the environment, never a literal key. Check `GET /health` first.

| Check | Request |
|---|---|
| `ts_doc_exists` | `GET /collections/<coll>/documents/<id>` |
| `ts_search` | `GET /collections/<coll>/documents/search?q=<q>&query_by=<field>` |
| `ts_collection_exists` | `GET /collections/<coll>` returns 200 |

## Result skeleton

```
DB - <n> test cases, <passed> passed, <failed> failed
TC-001 [P0] <title>
  row_exists       <table> WHERE id=<captured>   PASS  1 row
  ledger_balanced  transaction <captured>        FAIL  credit entry missing
```
