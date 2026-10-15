# Tech Debt Assessment: <codebase / area>

## Summary
- **Overall health**: Good / Moderate / Poor
- **Items identified**: X (critical: X, quick wins: X)
- **Estimated total remediation**: X person-weeks
- **Evidence sources**: churn analysis, CI data, incidents, prior audits, team input

## Debt inventory

Type is one of: code, architecture, testing, infrastructure, documentation.

| Item | Type | Location | Evidence | Cost of delay | Blast radius | Effort | Priority | Compounding? |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ... | code | file/module | churn 40 commits/6mo | High/Med/Low | ... | S/M/L | P0-P3 | Yes/No |

## Quick wins (high value, low effort)
1. **Item**: What to fix - **Effort**: hours/days - **Impact**: What improves

## Roadmap connection
| Upcoming feature | Blocked/slowed by debt item | Impact if not addressed |
| --- | --- | --- |
| ... | ... | Slower delivery / higher risk / ... |

## Compounding debt (getting worse over time)
1. **Item**: Why it compounds - **Current cost**: X - **Cost in 6 months**: Y

## Repayment plan

- Ongoing allocation: X% of capacity alongside feature work
- Quick wins: items to take in the next iteration

| Phase | Item | Owner | Effort | Done criteria |
| --- | --- | --- | --- | --- |
| Next 2 weeks: quick wins | ... | ... | ... | ... |
| Next quarter: critical debt | ... | ... | ... | ... |
| Next half: strategic debt | ... | ... | ... | ... |

## Success metrics
Pick the ones the debt actually affects, with current value and target: build time, flaky-test
rate, deploy frequency, change failure rate, time to implement a typical change in the affected area.

## Open questions
- ...
