---
name: security-review
description: Perform a practical security review (threat-model-lite) for a feature/PR: auth, data access, injection risks, abuse cases, privacy, secrets, logging, and safe defaults. Triggers: "security review", "threat model", "is this safe".
argument-hint: "[feature / PR / endpoint]"
---

# Security review (practical)

## What I'll do
Produce a lightweight threat model and actionable security findings, prioritized by real-world exploitability.

## Inputs I'll use (ask only if missing)
- What's changing (feature/PR/endpoint)
- Data involved (PII? financial? secrets?)
- Auth model (who can do what?)
- Deployment context (public internet? internal? multi-tenant?)

## How I'll think about this
1. **Map the attack surface**: Identify every entry point — API endpoints, form inputs, file uploads, webhooks, message queues, URL parameters, headers. Each is a potential injection vector.
2. **Trace data flow**: For each input, follow it through the system. Where does it get stored? Where does it get rendered? Where does it get logged? Every transition is a trust boundary.
3. **Check authentication**: For each endpoint, verify: Is auth required? Is it enforced server-side (not just client-side)? Can auth be bypassed via direct API calls?
4. **Check authorization**: For each state-mutating operation, verify: Is there an object-level permission check? Can user A access user B's data by changing an ID in the URL? Is there privilege escalation between roles?
5. **Test injection surfaces**: For each user-controlled input, check: Is it parameterized before reaching SQL/NoSQL? Is it escaped before HTML rendering? Is it sanitized before shell execution or template rendering?
6. **Evaluate data exposure**: Check API responses for over-fetching (returning fields the client doesn't need). Check logs for PII/secrets. Check error messages for stack traces or internal details.
7. **Assess abuse potential**: Consider bulk operations, enumeration attacks, credential stuffing, spam via user-generated content, and resource exhaustion.
8. **Review defaults**: Are new features secure by default? Do they fail closed (deny) rather than open (allow)?

## Common vulnerability patterns to check (OWASP-aligned)
- **Broken access control**: IDOR, missing function-level auth, CORS misconfiguration
- **Injection**: SQL, NoSQL, command, template, LDAP, XPath
- **XSS**: Reflected, stored, DOM-based — check anywhere user input renders
- **SSRF**: Any place the server fetches a user-provided URL
- **Insecure deserialization**: Untrusted data in deserialize/unmarshal calls
- **Security misconfiguration**: Debug mode in prod, default credentials, overly permissive CORS
- **Sensitive data exposure**: Secrets in logs, PII in analytics, tokens in URLs

## Anti-patterns to flag
- Authorization checks only on the frontend
- Building SQL/queries with string concatenation
- Logging request bodies without PII filtering
- Using user-supplied filenames or paths without sanitization
- Storing secrets in code, config files, or environment variables without encryption
- "Security through obscurity" — relying on hidden endpoints instead of auth

## Quality bar
- Every finding includes: what's vulnerable, how it could be exploited, and how to fix it
- Findings are prioritized by real exploitability, not theoretical risk
- Auth and authz checks traced per endpoint, not assumed
- No false sense of security — explicitly state what was NOT reviewed
- Verification plan: how to confirm each fix works

## Workflow context
- Typically follows: `/design-doc`, `/pr-review`
- Feeds into: `/test-plan` (security test cases), `/incident-response`
- Related: `/performance-review` (rate limiting overlaps)

## Output
Use `templates/security-review.md` and return findings as:
- **Must-fix** (exploitable now, high impact)
- **Should-fix** (exploitable with effort, moderate impact)
- **Nice-to-have** (defense-in-depth, low probability)
