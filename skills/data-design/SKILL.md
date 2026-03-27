---
name: data-design
description: >
  Design data layer across PostgreSQL, MongoDB, Elasticsearch, and Typesense.
  Covers schema design, indexing, migrations, query patterns, consistency, and cross-store sync.
  Triggers: "data design", "database design", "schema design", "data model", "data architecture".
argument-hint: "[entity / feature / data store]"
effort: high
---

# Data design (polyglot)

## What I'll do
Design the data layer for your feature across one or more data stores: PostgreSQL, MongoDB, Elasticsearch, Typesense. Include schema, indexing strategy, migration plan, query patterns, and cross-store consistency.

## Inputs I'll use (ask only if missing)
- Entities and their relationships (or handoff from /design-doc, /prd)
- Data stores in use (check for: docker-compose services, connection configs)
- Query patterns (what reads are most frequent? what needs to be fast?)
- Data volume estimates (rows/documents, growth rate)
- Consistency requirements (strong vs eventual, cross-store sync needs)

## Parallel Store Analysis

When the feature involves multiple data stores, analyze each independently in parallel:

### Execution Pattern

```
Phase 1: Requirements analysis — identify applicable stores (sequential)
    ↓
Phase 2: Parallel store design
  ┌──────────────┬──────────────┬──────────────┬──────────────┐
  │ POSTGRES     │ MONGO        │ ELASTIC      │ TYPESENSE    │
  │ _DESIGNER    │ _DESIGNER    │ _DESIGNER    │ _DESIGNER    │
  └──────┬───────┴──────┬───────┴──────┬───────┴──────┬───────┘
         └──────────────┼──────────────┘──────────────┘
                        ↓
Phase 3: Cross-store sync strategy + consistency model (sequential)
```

**Model routing:**

| Agent | Model | Rationale |
|---|---|---|
| `POSTGRES_DESIGNER` | `opus` | Schema design + RLS + migration safety requires deep reasoning |
| `MONGO_DESIGNER` | `sonnet` | Document modeling and aggregation pipeline design |
| `ELASTIC_DESIGNER` | `sonnet` | Index mapping, analyzers, and query design |
| `TYPESENSE_DESIGNER` | `haiku` | Simpler schema, collection design |

- Only activate agents for stores the feature actually uses
- PostgreSQL agent always runs (source of truth for most features)
- Phase 3 runs after all store designs complete — it needs all schemas to design sync

## How I'll think about this

### PostgreSQL (relational, source of truth)
1. **Schema design**: 3NF by default. Denormalize only with measured query evidence. Every table: `id UUID PK DEFAULT uuidv7()`, `created_at TIMESTAMPTZ`, `updated_at TIMESTAMPTZ`.
2. **Indexing**: B-tree on all FK columns and common WHERE predicates. GIN for JSONB and full-text. Partial indexes for filtered queries. Composite indexes following leftmost-prefix rule.
3. **Migrations**: Liquibase SQL format. Every changeset has `--rollback`. Expand-migrate-contract for breaking changes. Never `ALTER TABLE ... DROP COLUMN` without migration window.
4. **Query patterns**: `EXPLAIN ANALYZE` for every new query. CTEs for readability. Window functions over self-joins. Connection pooling (PgBouncer/HikariCP).
5. **Partitioning**: Range partition on date for time-series data. Hash partition for high-cardinality tenant tables. Always partition BEFORE data grows large.
6. **RLS**: `ENABLE ROW LEVEL SECURITY` + `FORCE ROW LEVEL SECURITY` for multi-tenant tables. Policy per role. `SET LOCAL app.tenant_id` in every transaction.

### MongoDB (document, flexible schema)
7. **Document modeling**: Embed when: 1:1 or 1:few, data is read together, atomic updates needed. Reference when: 1:many, data is read independently, documents would exceed 16MB.
8. **Schema validation**: JSON Schema on every collection. Enforce required fields, types, and enums. `validationAction: "error"` in production, `"warn"` in dev.
9. **Indexing**: Compound indexes matching common query patterns. TTL indexes for expiring data. Text indexes for basic search. Wildcard indexes only if field names are truly dynamic.
10. **Aggregation pipelines**: `$match` and `$project` early to reduce data flow. `$lookup` sparingly (it's a join — if you need many, reconsider your model). `$merge` for materialized views.
11. **Migrations**: Use mongosh scripts with idempotent operations. Version track in a `_migrations` collection. Always test rollback.
12. **Change streams**: Use for real-time sync to search engines or cache invalidation. Always handle `invalidate` events (collection drop/rename).

### Elasticsearch (search and analytics)
13. **Index design**: One index per entity type. Time-based index pattern (`logs-2026.03`) for time-series. Index aliases for zero-downtime reindexing.
14. **Mapping**: Explicit mapping (never dynamic). `keyword` for exact match/aggregation. `text` with custom analyzer for search. `date` for timestamps. Disable `_source` only if you're sure.
15. **Analyzers**: Standard for general text. Language-specific for localized content. Custom with edge_ngram for autocomplete. Synonyms via synonym filter.
16. **Index lifecycle**: Hot-warm-cold architecture for time-series. `rollover` for size/age-based index management. `forcemerge` on read-only indices.
17. **Query patterns**: `bool` query with `must`/`should`/`filter` (filter doesn't score, use it). `function_score` for boosting. Aggregations for analytics dashboards.

### Typesense (fast, typo-tolerant search)
18. **Collection schema**: Define fields with explicit types. `facet: true` on filter/aggregation fields. `sort: true` on sortable fields. `optional: true` only where needed.
19. **Search parameters**: `query_by` ordered by relevance. `filter_by` for structured filtering. `sort_by` for custom ordering. `per_page` and `page` for pagination.
20. **Synonyms and curation**: One-way synonyms for acronyms. Multi-way for true synonyms. Curated results for branded/promoted content. Override rules for specific queries.

### Cross-store consistency
21. **Sync strategy**: PostgreSQL as source of truth. Outbox pattern (write to PG outbox table → CDC → Elasticsearch/Typesense). Never synchronous dual-writes.
22. **Eventual consistency**: Define maximum acceptable lag (e.g., search results may be 5s behind). Monitor sync lag. Alert if lag exceeds SLA.
23. **Reindexing**: Bulk import scripts for full reindex. Zero-downtime via index alias swap. Verify document count matches source after reindex.
24. **Which store for which query**: Exact lookups → PostgreSQL. Full-text search → Elasticsearch/Typesense. Analytics/aggregations → Elasticsearch. Transactions → PostgreSQL. Flexible schema → MongoDB.

## Anti-patterns to flag
- ⚠️ MongoDB: Unbounded arrays in documents (16MB limit)
- ⚠️ Elasticsearch: Dynamic mapping in production (mapping explosion)
- ⚠️ PostgreSQL: Missing indexes on FK columns
- ⚠️ Cross-store: Synchronous dual-writes (will diverge)
- ⚠️ No schema validation on MongoDB collections
- ⚠️ No connection pooling on PostgreSQL
- ⚠️ Elasticsearch: Nested queries at scale (performance cliff)
- ⚠️ Typesense: Not setting facet/sort flags at creation time (requires reindex)

## Quality bar
- ✅ Every entity has a clear "home" data store with justification
- ✅ Schema/mapping defined explicitly (no dynamic/inferred)
- ✅ Indexes cover all common query patterns (verified with EXPLAIN)
- ✅ Migration plan includes rollback for every step
- ✅ Cross-store sync has defined lag SLA and monitoring
- ✅ Data volume projections inform partitioning/sharding decisions
- ✅ Query patterns documented with expected performance characteristics

## Workflow context
- Typically follows: `/design-doc`, `/api-design`
- Feeds into: `/spec-to-impl` (DBA agent), `/migration-plan`, `/verify-impl` (DB checks)
- Related: `/search-design` (deep-dive on search), `/performance-review` (query performance)

## Learning & Memory

After design completes, save:
- Schema patterns that worked well for this entity type
- Index strategies that proved effective for the query patterns
- Cross-store sync configurations that were reliable
- Migration patterns that enabled safe rollback

## Output contract
```yaml
produces:
  - type: data-design
    format: markdown
    path: "claudedocs/<feature>-data-design.md"
    sections: [entity_store_map, schemas, indexes, migrations, query_patterns, sync_strategy]
    handoff: "Write claudedocs/handoff-data-design-<timestamp>.yaml — suggest: spec-to-impl, migration-plan"
```
