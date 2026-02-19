# Runbook: <service name>

**Last verified**: <date>
**Review cadence**: Monthly / Quarterly
**Owner**: <team>
**On-call channel**: <link>

## Service overview
- **Purpose**: What this service does in one sentence
- **Dependencies**: What it depends on (databases, APIs, queues)
- **Dependents**: What depends on it
- **SLOs**: Availability, latency, error rate targets

## Quick reference
| Action | Command / Link |
| --- | --- |
| Health check | `curl https://...` |
| Logs | <link to log viewer> |
| Metrics dashboard | <link> |
| Deploy | <link or command> |
| Rollback | <link or command> |
| Feature flags | <link> |
| On-call schedule | <link> |

## Deployment

### Standard deploy
1. Step:
   - Command: `...`
   - Verify: ...
2. Step:
   - Command: `...`
   - Verify: ...

### Rollback
1. Step:
   - Command: `...`
   - Verify: ...
- **When to rollback**: Error rate > X%, latency > Xms, or customer reports
- **Escalate if**: Rollback doesn't resolve within X minutes

### Hotfix deploy
1. ...
- **Approval required**: Yes / No
- **Escalate to**: <name/team>

## Scaling

### Scale up (increased load)
- **Symptoms**: High CPU, queue depth growing, latency increasing
- **Action**: ...
- **Verify**: ...
- **Escalate if**: Scaling doesn't reduce latency within X minutes

### Scale down (cost optimization)
- **When**: Off-peak hours, reduced traffic
- **Action**: ...
- **Minimum safe configuration**: ...

## Common issues

### Issue: <symptom — e.g., "High error rate on /api/users">
- **Likely cause**: ...
- **Check**:
  1. Command: `...`
  2. Look for: ...
- **Fix**:
  1. ...
  2. Verify: ...
- **Escalate if**: Fix doesn't resolve within X minutes → Contact <team>

### Issue: <symptom — e.g., "Database connection timeouts">
_(repeat structure)_

### Issue: <symptom — e.g., "Queue messages backing up">
_(repeat structure)_

## Database operations

### Emergency queries
- Check connection pool: `...`
- Kill long-running queries: `...`
- Check replication lag: `...`
- **Warning**: Never run write queries in production without approval from <team>

### Backup and restore
- Backup location: ...
- Restore procedure: ...
- Estimated restore time: ...

## Maintenance tasks

### Task: <e.g., "Rotate API keys">
- **Frequency**: Monthly / Quarterly / As needed
- **Steps**: ...
- **Verify**: ...

### Task: <e.g., "Clean up old data">
- **Frequency**: ...
- **Steps**: ...
- **Verify**: ...

## Escalation paths
| Situation | Contact | Method | SLA |
| --- | --- | --- | --- |
| Service won't start | Platform team | Slack #platform-oncall | 15 min |
| Data integrity issue | Data team | Page via PagerDuty | Immediate |
| Security concern | Security team | Slack #security-urgent | Immediate |
| Unknown / everything tried | Engineering manager | Phone | 30 min |

## Appendix
- Architecture diagram: <link>
- Design doc: <link>
- Incident history: <link>
