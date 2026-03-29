---
name: release-notes
description: Draft release notes from a set of PRs/commits or a feature description. Produces user-facing notes, internal notes, known issues, and rollout steps. Triggers: "release notes", "changelog", "what shipped".
argument-hint: "[version | date range | PR list]"
disable-model-invocation: true
---

# Release notes

## Inputs
- Version number or date range
- List of merged PRs or commit range (or a summary of what shipped)
- Audience: external users, internal stakeholders, or both

## How I'll think about this
1. **Audience-first writing**: External users care about what changed for them. Internal teams care about what might break, what to monitor, and what to tell support. Write different sections for different readers.
2. **Outcomes over implementation**: "You can now export reports as PDF" not "Added PDFExportService with async rendering pipeline." Users don't care how — they care what and why.
3. **Breaking changes need migration paths**: Every breaking change must include: what broke, who's affected, what to do about it, and a timeline. Never just say "Breaking: API v2 removed."
4. **Be honest about known issues**: Shipping with known issues is fine. Shipping without telling anyone is not.
5. **Group by impact**: Highlights (big features) → Improvements (enhancements) → Fixes (bugs) → Breaking changes. Most readers stop after highlights.

## Anti-patterns to flag
- Jargon-heavy notes that only engineers understand
- "Various bug fixes and improvements" (uninformative)
- Breaking changes buried in a list without migration guidance
- Missing rollback/rollforward instructions for operators
- No mention of monitoring or alerts for high-risk changes

## Quality bar
- A non-technical user can understand the highlights section
- Breaking changes include specific migration instructions
- Internal operations section has rollback plan and monitoring guidance
- Known issues are listed with workarounds (if any)
- Links to PRs, dashboards, and runbooks are included for internal audience

## Workflow context
- Typically follows: `code-review:code-review` (official plugin), `/test-plan`
- Feeds into: `/stakeholder-update`, customer communications
- Related: `/experiment-design` (staged rollout notes), `/incident-response` (if rollout causes issues)

## Output
Fill `templates/release-notes.md`.

## Output contract
```yaml
produces:
  - type: "release-notes"
    format: "markdown"
    path: "claudedocs/<feature>-release-notes.md"
    sections: [highlights, breaking_changes, migration, rollback]
```
