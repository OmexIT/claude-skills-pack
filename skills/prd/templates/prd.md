# PRD: <feature name>

**Status:** Draft | In Review | Approved | Superseded
**Author:** <name>
**Date:** <YYYY-MM-DD>
**Last updated:** <YYYY-MM-DD>

---

## 1. Summary

One paragraph: what it is, who it's for, and the intended outcome.

## 2. Problem

### 2.1 User pain
Describe the problem from the user's perspective. What are they struggling with today?

### 2.2 Evidence
What data supports this problem? (support tickets, analytics, user research, competitive pressure)

| Signal | Source | Data |
|---|---|---|
| <signal> | <analytics / support / research> | <specific data point> |

### 2.3 Why now
What changed that makes this urgent? New data, competitive pressure, technical enablement, or regulatory deadline?

## 3. Goals

| Goal | Metric | Target | Timeline |
|---|---|---|---|
| G1: <goal> | <metric> | <target value> | <by when> |
| G2: <goal> | <metric> | <target value> | <by when> |

## 4. Non-goals

Explicitly state what this feature will NOT do. Each non-goal prevents scope creep.

- NG1: <what we won't build and why>
- NG2: <what we won't build and why>

## 5. Users and personas

### Primary persona
- **Who:** <role, context>
- **Goal:** <what they're trying to accomplish>
- **Current behavior:** <how they do it today>
- **Pain level:** <high / medium / low>

### Secondary persona(s)
- **Who:** <role, context>
- **Relationship to primary:** <how they interact>

## 6. User stories

| ID | As a... | I want to... | So that... | Priority |
|---|---|---|---|---|
| US-001 | <persona> | <action> | <outcome> | P0 / P1 / P2 |
| US-002 | <persona> | <action> | <outcome> | P0 / P1 / P2 |

## 7. Scope

### In scope
- <feature / capability>

### Out of scope
- <explicitly excluded capability and why>

### Future considerations
- <things we may do later but NOT in this iteration>

## 8. Functional requirements

Each requirement includes acceptance criteria, edge cases, and per-feature NFRs.

### FR-001: <requirement title>

**Description:** <what the system must do>
**User story:** US-001
**Priority:** P0

**Acceptance criteria:**
```gherkin
Given <precondition>
When <action>
Then <expected result>

Given <precondition>
When <action>
Then <expected result>
```

**Edge cases and error states:**
| Scenario | Expected behavior |
|---|---|
| <edge case> | <what should happen> |
| <error condition> | <error message / recovery path> |

**Non-functional requirements (this feature):**
- **Performance:** <latency target, e.g., "< 200ms p95">
- **Security:** <auth/authz requirements, data sensitivity>
- **Accessibility:** <WCAG level, specific needs>

---

### FR-002: <requirement title>

**Description:** <what the system must do>
**User story:** US-002
**Priority:** P0

**Acceptance criteria:**
```gherkin
Given <precondition>
When <action>
Then <expected result>
```

**Edge cases and error states:**
| Scenario | Expected behavior |
|---|---|
| <edge case> | <what should happen> |

**Non-functional requirements (this feature):**
- **Performance:** <target>
- **Security:** <requirements>

---

*(Repeat for each functional requirement)*

## 9. UI requirements

### 9.1 Screens and states

For each screen referenced in the requirements:

| Screen | States | Key interactions |
|---|---|---|
| <screen name> | default, loading, empty, error, success | <primary user actions> |

### 9.2 Component specifications

For each significant UI component:

| Component | Props / inputs | States | Interactions | Accessibility |
|---|---|---|---|---|
| <component> | <key props> | <visual states> | <click, hover, keyboard> | <aria-label, role, focus> |

### 9.3 Responsive behavior
- Mobile (<768px): <behavior>
- Tablet (768-1024px): <behavior>
- Desktop (>1024px): <behavior>

## 10. Data model (sketch)

Key entities and relationships — enough for the design-doc and data-design skills to build on.

| Entity | Key fields | Relationships | Storage |
|---|---|---|---|
| <entity> | <id, name, status, ...> | <belongs to X, has many Y> | <Postgres / Mongo / Elastic> |

> This is a sketch, not a schema. The `/data-design` skill will produce the full schema.

## 11. Non-functional requirements (global)

Requirements that apply across the entire feature.

| Category | Requirement | Target | Measurement |
|---|---|---|---|
| **Performance** | Page load time | < 2s (p95) | Lighthouse / RUM |
| **Performance** | API response time | < 200ms (p95) | Server metrics |
| **Reliability** | Availability | 99.9% | Uptime monitoring |
| **Security** | Authentication | JWT + refresh token | Auth service |
| **Security** | Authorization | Role-based per endpoint | Integration tests |
| **Privacy** | PII handling | No PII in logs | Log audit |
| **Accessibility** | WCAG compliance | Level AA | Axe / manual audit |
| **Localization** | Language support | <languages> | i18n coverage |
| **Compatibility** | Browser support | <browsers> | E2E tests |

## 12. Success metrics

### Primary metric
- **Metric:** <what to measure>
- **Baseline:** <current value>
- **Target:** <target value>
- **Timeline:** <by when>

### Secondary metrics
- <metric>: <baseline> → <target>

### Guardrails (must not regress)
- <metric>: must stay above <threshold>

## 13. Dependencies

### 13.1 Dependency matrix

| Dependency | Type | Owner | Status | Risk if delayed |
|---|---|---|---|---|
| <service / team / vendor> | blocking / non-blocking | <owner> | ready / in-progress / not-started | <impact> |

### 13.2 Integration points

| Integration | Trigger | Data sent | Data received | Auth | Failure behavior |
|---|---|---|---|---|---|
| <service / API> | <when called> | <payload> | <response> | <method> | <retry / fallback / error> |

## 14. Rollout plan

### Feature flags
- Flag name: `<feature_flag_name>`
- Default: off
- Rollout: <% ramp plan>

### Staged rollout
| Stage | Audience | Duration | Success criteria | Rollback trigger |
|---|---|---|---|---|
| 1. Internal | Team only | 1 week | No P0 bugs | Any P0 bug |
| 2. Beta | 5% of users | 1 week | <metric> within 10% of target | <metric> drops below <threshold> |
| 3. GA | 100% | — | <metric> hits target | — |

### Rollback plan
- How to roll back: <flag off / revert deploy / database rollback>
- Data migration rollback: <strategy if applicable>

## 15. Analytics and instrumentation

### Events

| Event name | Trigger | Properties | Purpose |
|---|---|---|---|
| `<noun>.<verb>` | <when fired> | `{prop1, prop2}` | <what decision it informs> |

### Dashboards
- <dashboard name>: <what it shows, who uses it>

### Alerts
- <alert name>: <condition> → <notification channel>

## 16. Risks and mitigations

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| <risk> | High / Med / Low | High / Med / Low | <mitigation strategy> |

## 17. Open questions

| # | Question | Owner | Due date | Resolution |
|---|---|---|---|---|
| Q1 | <question> | <who decides> | <date> | <pending / resolved: answer> |

## 18. Definition of Ready checklist

Before this PRD moves to implementation, confirm:

- [ ] Problem validated with evidence (not just opinion)
- [ ] At least one measurable success metric with baseline and target
- [ ] All P0 functional requirements have acceptance criteria (Given/When/Then)
- [ ] All P0 requirements have edge cases and error states documented
- [ ] Non-functional requirements specified per feature (performance, security, a11y)
- [ ] UI screens listed with states (default, loading, empty, error)
- [ ] Dependencies identified with owners and status
- [ ] Rollout plan includes feature flag, staged rollout, and rollback
- [ ] Instrumentation plan covers key events and dashboards
- [ ] Open questions have owners and due dates
- [ ] Non-goals section is substantive (not empty)
- [ ] Reviewed by: engineering, design, and at least one stakeholder

## Appendix

- Mockups / wireframe links
- Research documents
- Competitive analysis references
- Related ADRs
