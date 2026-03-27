---
name: onboarding-doc
description: Generate a new team member onboarding guide for a service, domain, or codebase. Covers architecture, key workflows, local setup, and tribal knowledge. Triggers: "onboarding doc", "onboarding guide", "new hire guide", "getting started", "team wiki".
argument-hint: "[service / domain / team]"
effort: medium
---

# Onboarding doc

## What I'll do
Produce an onboarding guide that gets a new team member productive in the shortest time possible, capturing the tribal knowledge that usually takes months to absorb.

## Inputs I'll use (ask only if missing)
- Service/domain/team to onboard for
- Target audience (junior engineer? senior hire? contractor?)
- Existing documentation (links to wikis, READMEs, design docs)
- Common "first week" questions from past hires

## How I'll think about this
1. **Optimize for time-to-first-contribution**: The goal isn't comprehensive knowledge — it's getting someone to their first meaningful PR as fast as possible. Everything else can come later.
2. **Capture tribal knowledge**: The most valuable onboarding content is the stuff that isn't written down — why things are the way they are, which patterns are intentional vs accidental, who to ask about what.
3. **Layered learning**: Day 1 basics → Week 1 context → Month 1 depth. Don't front-load everything. People absorb more when learning is paced.
4. **Working > reading**: A guided exercise (set up the project, make a small change, deploy to staging) teaches more than 10 pages of architecture description.
5. **Keep it maintained**: The onboarding doc should have an owner and a review schedule. Stale onboarding docs waste new hires' time and erode trust.

## Anti-patterns to flag
- Architecture dump without "why should I care" context
- No local setup instructions (or broken ones)
- Assuming background knowledge the reader doesn't have
- No pointers to key people (who knows what)
- Documentation that requires reading 15 other docs first

## Quality bar
- A new hire can set up the project and run tests within the first day
- Key architecture decisions are explained with context (why, not just what)
- Common pitfalls and "things I wish I'd known" are captured
- People directory exists (who to ask about what)
- Guided first task is included (not just reading)
- Review date and owner are set

## Workflow context
- Typically follows: Team growth, new hire starting
- Feeds into: Faster onboarding, reduced knowledge silos
- Related: `/docs-review` (documentation quality), `/runbook` (operational knowledge)

## Output
Fill `templates/onboarding-doc.md`.

## Learning & Memory

After completing an onboarding doc, persist the following to project memory for future skill invocations:

- **Onboarding gaps**: Areas where documentation was missing or outdated, to check in future iterations
- **Tribal knowledge discovered**: Undocumented conventions, decisions, and gotchas captured during this pass
- **Common new-hire questions**: Frequently asked questions surfaced during onboarding that should be addressed proactively

Store in: `claudedocs/memory/onboarding-doc.md`

## Output contract
```yaml
produces:
  - type: "onboarding"
    format: "markdown"
    path: "claudedocs/<feature>-onboarding-doc.md"
    sections: [architecture, workflows, local_setup, tribal_knowledge]
```
