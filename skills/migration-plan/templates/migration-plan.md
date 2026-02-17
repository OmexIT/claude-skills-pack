# Migration Plan: <what's being migrated>

## Overview
- **What**: Current state → Target state
- **Why**: Reason for migration
- **Scope**: What's affected (tables, endpoints, services, consumers)
- **Data volume**: Approximate size
- **Downtime tolerance**: Zero-downtime / Maintenance window / Acceptable degradation

## Pre-migration checklist
- [ ] Backup taken and verified
- [ ] Rollback procedure tested
- [ ] All consumers identified and notified
- [ ] Monitoring and alerts configured
- [ ] Batch size and checkpoint strategy confirmed
- [ ] Performance impact estimated and accepted
- [ ] Staging migration completed successfully

## Migration stages

### Stage 1: Expand
**Goal**: Add new schema/endpoints alongside existing ones
- Changes:
- Backwards compatible: Yes / No
- Rollback: Drop new columns/endpoints
- Validation: New paths work, old paths unaffected

### Stage 2: Migrate
**Goal**: Move data/traffic from old to new
- Approach: Batch backfill / Dual-write / Shadow traffic
- Batch size:
- Checkpoint strategy:
- Estimated duration:
- Rollback: Stop migration, old data is still primary
- Validation:
  - Row counts match:
  - Data integrity checks:
  - Consumer behavior verified:

### Stage 3: Contract
**Goal**: Remove old schema/endpoints
- Changes:
- Prerequisites: All consumers migrated, validation passing for X days
- Rollback: Re-add old columns/endpoints from backup
- Validation: No references to old paths remain

## Rollback plan
| Stage | Trigger | Rollback action | Data impact | Estimated time |
| --- | --- | --- | --- | --- |
| Expand | ... | Drop new additions | None | ... |
| Migrate | ... | Stop migration, revert flag | None (old data untouched) | ... |
| Contract | ... | Re-add from backup | Potential loss of new-format data | ... |

## Validation checks
| Check | When | How | Pass criteria |
| --- | --- | --- | --- |
| Row count match | After batch | Automated script | Old count == new count |
| Data integrity | After batch | Checksums / spot checks | 100% match |
| Consumer health | Continuous | Monitoring dashboard | Error rate < baseline |
| Performance | Continuous | Latency metrics | p95 < SLO |

## Monitoring during migration
- Dashboard:
- Key metrics to watch:
- Alert thresholds:
- On-call contact:

## Communication plan
| When | Who | What |
| --- | --- | --- |
| Before start | ... | Migration scheduled, expected impact |
| During | ... | Progress updates |
| On completion | ... | Migration complete, verification results |
| If rollback | ... | Issue encountered, reverting, impact |

## Timeline
| Date | Stage | Action |
| --- | --- | --- |
| ... | Pre-migration | Backup, staging test |
| ... | Stage 1 | Expand (deploy new schema) |
| ... | Stage 2 | Migrate (run backfill) |
| ... | Validation | Monitor for X days |
| ... | Stage 3 | Contract (remove old schema) |

## Open questions
- ...
