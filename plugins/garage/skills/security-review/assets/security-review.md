# Security review: <feature / PR>

## Overview
- What it does:
- Who can access it:
- Data touched:

## Threat model (lightweight)
### Assets
- …

### Trust boundaries
- …

### Likely threat actors
- Anonymous user
- Authenticated user
- Malicious tenant/customer
- Compromised internal token/service

## Checklist
### AuthN/AuthZ
- [ ] Auth required where appropriate
- [ ] Authorization checked server-side (not only client-side)
- [ ] Object-level permission checks (IDs in URLs/body)

### Input handling
- [ ] Validate/sanitize inputs
- [ ] No injection vectors (SQL/NoSQL/template/command) in critical paths
- [ ] Safe file upload/download behavior (if applicable)

### Data exposure & privacy
- [ ] PII is minimized in responses
- [ ] Logs/errors do not leak secrets/PII
- [ ] Analytics events avoid sensitive payloads

### Abuse resistance
- [ ] Rate limiting / throttling (if exposed publicly)
- [ ] Anti-automation / spam considerations (if relevant)

### Dependencies & secrets
- [ ] Secrets stored in the right place (not in repo)
- [ ] Third-party calls are authenticated and time-limited
- [ ] SSRF-safe patterns if URLs are user-controlled

## Findings
### Must-fix
1. …

### Should-fix
1. …

### Nice-to-have
1. …

## Verification
- Tests to add:
- Manual checks:
- Monitoring/alerts:
