---
name: search-design
description: "Use when the user is designing search: Elasticsearch or Typesense indexes, mappings, analyzers, relevance tuning, autocomplete, faceting, full-text search, or syncing search from the source of truth."
---

# Search design

Designs the search engine side: schema, analyzers, autocomplete, facets, relevance, sync, and
reindexing. Which store owns each entity, and the source-of-truth schema, are `data-design`.

## Inputs (ask only if missing)
- Searchable entities, their source of truth, and use cases (full text, autocomplete, facets).
- Document count, query volume, and latency targets, with their source.
- What should rank higher (example queries with expected results), languages, and any fixed engine.

## Decision rules
1. **Engine**: Elasticsearch or OpenSearch for custom analyzers, complex relevance, aggregations, or
   large scale; Typesense for typo-tolerant product search with simple relevance and a small ops
   budget. Use what the repo already runs unless it cannot meet a stated need.
2. **One index or collection per entity type**, read through an alias so reindexing is a swap.
3. **Explicit schema**, no dynamic mapping in production. `keyword` for exact match, sort, and
   aggregations; `text` with a chosen analyzer for full text; multi-fields when a field needs both.
   In Typesense, set `facet`, `sort`, and `index` flags deliberately at creation.
4. **Analyzers**: character filters, tokenizer, token filters, chosen per language. Synonyms in a
   search-time synonym filter or set so they can change without reindexing.
5. **Autocomplete**: a dedicated sub-field with an `edge_ngram` index analyzer and a standard search
   analyzer (never edge n-grams at search time), or `search_as_you_type`, or the completion
   suggester for prefix-only suggestions. Typesense prefix search covers most cases natively.
6. **Facets**: `keyword` fields with `terms` aggregations (watch high-cardinality fields), or
   `facet: true` in Typesense.
7. **Relevance**: field boosts first, then recency or popularity in `function_score`, only with a
   judged query set to measure against (Elasticsearch `_rank_eval` or an offline script). Record the
   scoring formula and the judged set.
8. **Sync**: projection from the source of truth through a transactional outbox or CDC (for example
   Debezium) into an idempotent indexer keyed by entity ID and version, so replays and out-of-order
   events cannot regress a document. Track a watermark and alert on lag.
9. **Reindexing**: build a new index, bulk load in batches sized by measured throughput, catch up
   from the outbox watermark, compare counts or checksums with the source, then swap the alias.

## Anti-patterns to flag
- Breaking any decision rule above: dynamic mapping, one field for exact match and full text,
  synchronous dual writes, no reindex path, untested relevance changes, unmonitored sync lag.
- `nested` fields at scale without a measured query plan.

## Quality bar
- [ ] Every field's type and analyzer is justified; latency targets are measured on realistic volume.
- [ ] Relevance has a judged query set; sync is idempotent, versioned, and lag-alerted.
- [ ] Reindexing swaps an alias with zero downtime and verifies counts.

## Workflow context
- Follows `data-design` (store ownership) or `design-doc`; feeds `spec-to-impl`, `performance-review`.
- `api-design` shapes the search endpoint; `monitoring-plan` covers cluster and sync health.

## Output contract
```yaml
produces:
  - type: search-design
    format: markdown
    path: "claudedocs/<feature>-search-design.md"
    sections: [engine_choice, index_mapping, analyzers, autocomplete, facets, relevance, sync, operations]
    handoff: "Write claudedocs/handoff-search-design-<timestamp>.yaml - suggest: spec-to-impl, data-design"
```
