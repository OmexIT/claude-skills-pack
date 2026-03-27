---
name: search-design
description: >
  Design search infrastructure with Elasticsearch and Typesense: index design, mapping, analyzers,
  relevance tuning, autocomplete, faceting, and sync from source of truth.
  Triggers: "search design", "elasticsearch", "typesense", "search relevance", "autocomplete", "full-text search".
argument-hint: "[search feature / entity to index]"
effort: high
---

# Search design

## What I'll do
Design the search layer: index structure, mapping, analyzers, relevance tuning, autocomplete, faceting, sync pipeline, and operational patterns for Elasticsearch and/or Typesense.

## Inputs I'll use (ask only if missing)
- What entities need to be searchable
- Source of truth data store (PostgreSQL, MongoDB)
- Search use cases (full-text, autocomplete, filtering, analytics)
- Expected document count and query volume
- Relevance requirements (what results should rank higher?)
- Multi-language requirements

## How I'll think about this

1. **Choose the right engine**: Elasticsearch for complex relevance tuning, analytics, log search, and large scale. Typesense for simple search with built-in typo tolerance, faster setup, and lower ops burden.
2. **Index-per-entity**: One index/collection per searchable entity. Don't mix products and users in one index. Use index aliases (ES) for zero-downtime operations.
3. **Mapping design**: Be explicit — never rely on dynamic mapping. Choose field types deliberately: `keyword` for exact match and aggregation, `text` for full-text search, `date` for time ranges.
4. **Analyzer pipeline**: Character filters (HTML strip, pattern replace) → Tokenizer (standard, edge_ngram, path_hierarchy) → Token filters (lowercase, stemmer, synonym, stop words).
5. **Autocomplete pattern**: Edge n-gram (2-15 chars) on a dedicated `*.autocomplete` sub-field. Separate from the main search field. Use `match_phrase_prefix` or completion suggester.
6. **Faceted search**: Mark facet fields as `keyword` (ES) or `facet: true` (Typesense). Aggregation queries for facet counts. Consider `terms` agg cardinality limits.
7. **Relevance tuning**: `function_score` with field boosting (title > description > body). Recency boost for time-sensitive content. Popularity boost for user-facing search. Document and test your scoring formula.
8. **Sync pipeline**: Outbox pattern from source DB → CDC (Debezium) or polling → indexer service → search engine. Track sync watermark. Alert on lag.
9. **Reindexing strategy**: Blue-green index swap via aliases. Bulk index API with batches of 1000-5000 docs. Verify document count post-reindex. Schedule during low-traffic window.
10. **Operational**: Monitor cluster health, shard count, JVM heap (ES). Set up index lifecycle management for time-series. Plan capacity for 2x current volume.

## Anti-patterns to flag
- ⚠️ Dynamic mapping in production (mapping explosion, type conflicts)
- ⚠️ Single field for both exact match and full-text (use multi-field mapping)
- ⚠️ Synchronous dual-write to DB and search engine (will diverge)
- ⚠️ No reindexing strategy (stuck with bad mapping forever)
- ⚠️ `nested` type at scale without testing performance
- ⚠️ Relevance tuning by guessing instead of measuring (A/B test relevance changes)
- ⚠️ No monitoring on sync lag between source and search

## Quality bar
- ✅ Explicit mapping with justification for each field type
- ✅ Autocomplete has sub-100ms p99 latency
- ✅ Facets return accurate counts for top-N values
- ✅ Relevance is testable: set of query/expected-result pairs documented
- ✅ Sync pipeline has lag monitoring and alerting
- ✅ Reindexing can run zero-downtime via alias swap
- ✅ Search works correctly with multi-language content (if applicable)

## Workflow context
- Typically follows: `/data-design`, `/design-doc`
- Feeds into: `/spec-to-impl` (search implementation), `/performance-review` (query performance)
- Related: `/api-design` (search API endpoint design), `/monitoring-plan` (search health)

## Learning & Memory

After search design completes, save:
- Search relevance tuning decisions (field boosts, scoring formulas, synonym lists) and their measured impact on result quality
- Analyzer configurations that worked for the content type and language (tokenizer, filters, edge n-gram settings)
- Sync patterns between source of truth and search engine (CDC vs polling, batch sizes, lag thresholds) and their reliability in production

## Output contract
```yaml
produces:
  - type: search-design
    format: markdown
    path: "claudedocs/<feature>-search-design.md"
    sections: [engine_choice, index_mapping, analyzers, autocomplete, facets, relevance, sync, operations]
    handoff: "Write claudedocs/handoff-search-design-<timestamp>.yaml — suggest: spec-to-impl, data-design"
```
