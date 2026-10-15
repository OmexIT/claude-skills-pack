---
name: security-review
description: "Use when a feature or PR needs a security review or lightweight threat model: auth, data access, injection, abuse cases, privacy, secrets, logging, or is this safe."
---

# Security review (practical)

> Delegation, model labels, and task tracking below use Claude Code notation. In Codex or another client, follow `../../references/cross-client.md`.

A lightweight threat model and findings for one feature, PR, or endpoint set, prioritized by real
exploitability. This is the security deep dive; `code-audit` covers security only as one breadth
dimension, and `arch-review` covers structural boundaries.

## Inputs (ask only if missing)

- What is changing (feature, PR, endpoints)
- Data involved (PII, financial, secrets) and the auth model (who can do what)
- Deployment context (public, internal, multi-tenant)

## Lenses and fan-out

| Lens | Label | Focus |
|---|---|---|
| `AUTH` | `opus` | Authentication, session, server-side authorization, object-level access, tenant isolation, roles |
| `INJECTION` | `sonnet` | SQL/NoSQL, command, template, path traversal, XSS, SSRF, unsafe deserialization |
| `PRIVACY` | `opus` | PII minimization, retention, logs and errors, analytics payloads, secrets handling |
| `ABUSE` | `sonnet` | Rate limits, enumeration, credential stuffing, resource exhaustion, bulk operations |

Map the attack surface first, in one pass. **Fan-out is conditional:** a single endpoint, PR, or
module runs the four lenses inline. Fan out only for a large surface (many services or entry
points): dispatch the lenses as parallel Agent calls in one message with the attack-surface map,
then synthesize one risk-ranked list.

## Workflow

1. **Attack surface:** every entry point (endpoints, forms, uploads, webhooks, consumers, jobs,
   headers, URL parameters) and the trust boundary each crosses.
2. **Trace data flow:** for each input, where it is stored, rendered, logged, and forwarded.
3. **Authentication and authorization:** per endpoint and per persistence path, enforced
   server-side; object-level checks (can user A reach user B's record by changing an ID?); tenant
   isolation; privilege escalation between roles; default deny.
4. **Injection and parsing:** parameterized queries, escaped output, no user input in shell,
   templates, file paths, or fetched URLs without validation.
5. **Exposure:** response over-fetching; PII, tokens, or secrets in logs, errors, analytics, or URLs;
   errors returned as RFC 9457 Problem Details without stack traces or provider internals; internal
   IDs (TSIDs) never exposed, external IDs are UUIDv7.
6. **Secrets and dependencies:** no secrets in code, committed config, logs, or URLs; secrets come
   from the platform's secret store or injected environment. Check vulnerable dependencies against
   the resolved dependency graph with official advisories or the ecosystem scanner; never infer a
   vulnerability from a package name or a different version.
7. **Abuse:** enumeration, credential stuffing, spam through user content, unbounded bulk requests,
   expensive operations without limits.
8. **Defaults:** new features fail closed; debug endpoints, permissive CORS, and default
   credentials are off in production.

Every finding states what is vulnerable, the exploit path (who, from where, with what access), the
evidence (code, config, request, or scoped search), and the fix. Theoretical risk with no reachable
path is a note, not a finding. Never propose home-grown cryptography.

## Output

Fill `assets/security-review.md`. Group findings as **Must-fix** (exploitable now, high impact),
**Should-fix** (exploitable with effort, moderate impact), **Nice-to-have** (defense in depth).
State explicitly what was not reviewed, and give a verification step for each fix.

## Workflow context

- Typically follows: `design-doc`, `code-audit` (security leads), `code-review:code-review` (official plugin).
- Feeds into: `test-plan` (security test cases), `finalize`.
- Related: `performance-review` (rate limiting and resource exhaustion overlap).

## Output contract
```yaml
produces:
  - type: "security-review"
    format: "markdown"
    path: "claudedocs/<feature>-security-review.md"
    sections: [threat_model, findings, owasp_checklist, remediation]
    handoff: "Write claudedocs/handoff-security-review-<timestamp>.yaml - suggest: finalize, test-plan"
```
