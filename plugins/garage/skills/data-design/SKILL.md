---
name: data-design
description: "Use when the user is designing a data layer or schema across PostgreSQL, MongoDB, Elasticsearch, or Typesense: data model, indexing, query patterns, consistency, or keeping several stores in sync."
---

# Data design (polyglot)

> Delegation, model labels, and task tracking below use Claude Code notation. In Codex or another client, follow `../../references/cross-client.md`.

Designs the data layer for a feature: which store owns each entity, schemas, indexes, query
patterns, and cross-store consistency. Search mappings, analyzers, and relevance are `search-design`;
concrete changesets are `db-migration`; multi-deploy rollout of a schema change is `migration-plan`.

## Inputs (ask only if missing)
- Entities and relationships (or a handoff from `design-doc` or `prd`).
- Stores in use: check docker-compose services, connection config, and dependencies.
- Hot query patterns and their latency needs.
- Volume and growth estimates, with their source.
- Consistency needs: strong vs eventual, acceptable sync lag.

## Process
1. Map each entity to one home store and justify it. PostgreSQL is the source of truth unless there
   is a stated reason otherwise.
2. Design each store involved. Each store is a review lens: for one or two stores, do them inline in
   one pass. Fan out one agent per store (`opus` for PostgreSQL, `sonnet` for the others) only when
   three or more stores each need substantial design; never fan out by default.
3. Design cross-store sync and the consistency model once all store designs exist.

## PostgreSQL
- **Keys follow `db-migration`**: `id BIGINT PRIMARY KEY` holding an application-generated TSID;
  entities exposed outside the service add `public_id UUID NOT NULL UNIQUE` holding a UUIDv7. Never a
  UUID primary key, never `SERIAL` or `IDENTITY`, and the TSID never leaves the service.
- **Types**: money `NUMERIC` with scale from the currency or asset contract; instants `TIMESTAMPTZ`;
  closed enums `TEXT` plus `CHECK`.
- **Normalize by default**; denormalize only with measured query evidence.
- **Indexes** on every foreign key column and on the predicates of hot queries; composite indexes in
  leftmost-prefix order; partial indexes for filtered hot paths; GIN for JSONB containment. Check
  plans with `EXPLAIN (ANALYZE, BUFFERS)` on realistic volume for queries on large or hot tables.
- **Partitioning** only when volume evidence shows retention or scan problems (time-range for
  time-series, hash for very large tenant tables), decided before the table is large.
- **Tenant isolation** with RLS when the service relies on the database for it (see `db-migration`),
  and the tenant set per transaction with `SET LOCAL`.

## MongoDB
- **Embed** for 1:1 or 1:few data read and updated together; **reference** for 1:many, independently
  read data, or anything that could approach the 16MB document limit. No unbounded arrays.
- **JSON Schema validation** on every collection (`validationAction: "error"` in production).
- **Compound indexes** matching query shape (equality, sort, range); TTL indexes for expiring data.
- **Aggregations**: `$match` and `$project` early; heavy `$lookup` use signals a modeling problem.
- **Migrations** are idempotent scripts tracked in a migrations collection.
- **Change streams** for downstream sync, resuming from a stored resume token and handling
  `invalidate` events.
- **Money** as `Decimal128`, never double.

## Search stores (Elasticsearch, Typesense)
Here decide only what is indexed, from which source, and the acceptable lag. Mappings, analyzers,
autocomplete, facets, and relevance belong to `search-design`.

## Cross-store consistency
- **Source of truth** writes first; other stores are projections.
- **No synchronous dual writes.** Use a transactional outbox in PostgreSQL (or change streams from
  MongoDB) feeding an idempotent indexer keyed by entity ID and version.
- **Lag budget** stated per projection, monitored, and alerted.
- **Rebuild path**: every projection can be rebuilt from the source of truth, with a count or
  checksum comparison afterwards.
- **Routing**: exact lookups and transactions in PostgreSQL, full-text and faceted search in the
  search store, flexible per-tenant documents in MongoDB when the domain needs them.

## Anti-patterns to flag
- UUID or sequence primary keys, or internal IDs exposed outside the service.
- Floating-point money in any store.
- Synchronous dual writes across stores.
- Missing foreign key indexes; MongoDB collections without validation; unbounded arrays.
- Partitioning or sharding without volume evidence.

## Quality bar
- [ ] Every entity has one home store with justification.
- [ ] Schemas defined explicitly, with keys and types following house law.
- [ ] Indexes cover the stated hot queries, checked against plans on realistic data.
- [ ] Each projection has a sync path, lag budget, monitoring, and rebuild path.
- [ ] Volume projections and their source are stated where they drive partitioning or sharding.

## Workflow context
- Follows `design-doc` or `api-design`; feeds `spec-to-impl`, `migration-plan`, `verify-impl`.
- `search-design` owns search-engine internals; `db-migration` writes the changesets.

## Output contract
```yaml
produces:
  - type: data-design
    format: markdown
    path: "claudedocs/<feature>-data-design.md"
    sections: [entity_store_map, schemas, indexes, migrations, query_patterns, sync_strategy]
    handoff: "Write claudedocs/handoff-data-design-<timestamp>.yaml - suggest: spec-to-impl, migration-plan"
```
