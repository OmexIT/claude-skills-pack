# Experiment plan: <change>

Owner: <name> | Planned start: YYYY-MM-DD

## Hypothesis
If we <change>, then <primary metric> moves by about <effect>, because <reason>.

## Metrics
| Role | Metric | Exact definition | Source | Threshold |
|---|---|---|---|---|
| Primary | | | | <smallest effect worth acting on> |
| Guardrail | | | | <stop if worse than> |
| Secondary (optional) | | | | |

## Population and assignment
- Included / excluded:
- Randomization unit and split:
- Pre-named segments:

## Size and duration
- Baseline rate, minimum effect, required sample per group:
- Planned duration (at least one weekly cycle) and stop conditions:

## Decision rule
- Ship if:
- Iterate if:
- Revert if (including any guardrail breach):

## Instrumentation
- Events and properties needed, and where they are verified before launch:

## Risks and rollback (when relevant)
- <risk>: <mitigation>; how exposure is turned off.
