# Metrics Review: <feature / area>

## Overview
- **Feature**: What's being reviewed
- **Data consumers**: Who uses this data and for what
- **Key questions this data should answer**:
  1. ...
  2. ...
  3. ...

## Event inventory
| Event name | Trigger | Key properties | Purpose | Status |
| --- | --- | --- | --- | --- |
| ... | When does it fire | ... | What question it answers | Active / Missing / Broken |

## Taxonomy check
- [ ] Events follow consistent naming convention: `<noun>_<verb>`
- [ ] Properties use consistent types (string vs enum vs number)
- [ ] Timestamps are in consistent format (UTC ISO 8601)
- [ ] User identifiers are consistent across events
- [ ] Event versions are tracked (if schema changes)

## Funnel coverage
| Step | Event | Properties | Coverage |
| --- | --- | --- | --- |
| Entry | ... | ... | Full / Partial / Missing |
| Step 2 | ... | ... | ... |
| Conversion | ... | ... | ... |
| ... | ... | ... | ... |

**Gaps identified**: Steps where tracking is missing or incomplete

## Data accuracy validation
| Check | Method | Result |
| --- | --- | --- |
| Event count vs server logs | Compare daily totals | Match / Off by X% |
| Unique users vs DB count | Cross-reference | Match / Off by X% |
| Funnel math (step N <= step N-1) | Check monotonicity | Pass / Fail |
| Timestamp accuracy | Compare client vs server | Within Xms |

## Dashboard review
| Dashboard | Purpose | Audience | Actionable? | Issues |
| --- | --- | --- | --- | --- |
| ... | ... | ... | Yes / No | ... |

## Privacy and compliance
- [ ] No PII in event properties
- [ ] User consent is checked before tracking
- [ ] Data retention policy is defined
- [ ] Opt-out mechanism works correctly
- [ ] Third-party analytics comply with privacy policy

## Findings

### Must-fix (data integrity issues)
1. ...

### Should-fix (gaps or inconsistencies)
1. ...

### Nice-to-have (improvements)
1. ...

## Recommendations
- Events to add:
- Events to remove (dead instrumentation):
- Properties to enrich:
- Dashboards to create/update:

## Open questions
- ...
