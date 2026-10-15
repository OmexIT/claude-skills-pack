---
name: onboarding-doc
description: "Use when the user wants an onboarding guide for a new team member on a service, domain, or codebase: architecture, key workflows, local setup, and tribal knowledge."
---

# Onboarding doc

Get a new team member to a first merged change as fast as possible, and write down the knowledge that usually takes months to pick up.

Ask only what is missing: the service, domain, or team; who is joining (experience level, role); and existing docs to link.

## Steps
1. Read the repo before writing: README, build and dependency files, local environment config, CI pipeline, and the main entry points. Setup steps come from what the repo actually runs; run them when you can and mark any step you could not verify.
2. Link to existing docs (READMEs, ADRs, runbooks) instead of copying them; a copy goes stale.
3. Pace it: day 1 gets the project running and tests passing; week 1 explains the system and the main flows; month 1 covers domain depth and history.
4. Explain why things are the way they are, which patterns are deliberate, and which are legacy to avoid copying.
5. End with a guided first task small enough to merge in the first week.

## Rules
- Never invent people, contacts, URLs, or credentials. Leave a clearly marked placeholder for the user to fill.
- Assume only the background stated for the reader; define domain terms where they first appear.
- Set an owner and a review date, so the doc does not quietly rot.

## Workflow context
- `onboarding-doc` teaches a newcomer; `runbook` covers operating the service; `docs-review` improves an existing doc.

## Output
Fill `assets/onboarding-doc.md`, dropping sections that have no real content.

## Output contract
```yaml
produces:
  - type: "onboarding"
    format: "markdown"
    path: "claudedocs/<feature>-onboarding-doc.md"
    sections: [architecture, workflows, local_setup, tribal_knowledge]
```
