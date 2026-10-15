# Runbook: <service name>

**Last verified**: <date>  **Owner**: <team>  **On-call channel**: <link>

## Service overview
- **Purpose**: one sentence
- **Dependencies** / **Dependents**:
- **SLOs**:

## Quick reference
| Action | Command / link |
| --- | --- |
| Health check | |
| Logs / dashboard | |
| Deploy / rollback | |
| On-call schedule | |

## Deployment
### Standard deploy
1. Command: `...`
   Verify: ...

### Rollback
1. Command: `...`
   Verify: ...
- **When to roll back**: <error rate, latency, or business signal>
- **Schema changes**: rollback is safe only if the running migration is backward compatible; otherwise
  <restore or forward-fix procedure>
- **Escalate if**: not resolved within <minutes> -> <contact>

## Alerts and symptoms
### <Alert name or symptom>
- **Likely causes**: ...
- **Check**: `...` -> look for ...
- **Fix**: `...` -> verify ...
- **Escalate if**: <condition> -> <contact, method>

_(one section per paging alert)_

## Scaling
- **Symptoms**: ...
- **Action**: `...` -> verify ...
- **Limits**: minimum safe configuration, maximum before cost or downstream impact

## Data operations
- Read-only diagnostics: `...`
- Write or destructive operations: blast radius, approver, backup taken first, undo or restore
  procedure, estimated restore time

## Maintenance tasks
### <Task, e.g. rotate credentials>
- **Frequency**: ...
- **Steps**: ... -> verify ...

## Escalation
| Situation | Contact | Method | Response expectation |
| --- | --- | --- | --- |
| | | | |

## Links
- Architecture / design doc / incident history:
