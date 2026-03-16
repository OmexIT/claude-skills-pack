---
name: stakeholder-update
description: Write a structured status update for leadership, cross-functional partners, or investors. Covers progress, risks, decisions needed, and next steps. Triggers: "stakeholder update", "status update", "exec update", "weekly update", "progress report".
argument-hint: "[project / initiative / sprint]"
disable-model-invocation: true
---

# Stakeholder update

## What I'll do
Produce a concise, structured status update that gives stakeholders what they need — progress, risks, blockers, and decisions — without wading through details.

## Inputs I'll use (ask only if missing)
- Project/initiative being reported on
- Audience (exec team, cross-functional partners, investors, board)
- Time period (weekly, monthly, milestone-based)
- Current status and recent progress
- Risks, blockers, or decisions needed

## How I'll think about this
1. **Lead with the headline**: Status (on track / at risk / blocked), one sentence on why, and what you need from the reader. Most stakeholders read the first 3 lines and skim the rest.
2. **Traffic light simplicity**: Green (on track), Yellow (at risk, mitigation underway), Red (blocked, need help). This is the universal language of stakeholder updates.
3. **Decisions needed, not just FYI**: If you need something from stakeholders, state it explicitly with a deadline. Don't bury asks in the middle of a progress report.
4. **Risks with mitigations**: Never present a risk without a mitigation plan. "We might miss the deadline" is alarming. "We might miss the deadline; we're cutting scope on X to de-risk" is professional.
5. **Metrics over narratives**: "Shipped 12 of 15 tickets, 2 in review, 1 blocked" beats "We made good progress this week." Numbers build trust.
6. **Consistent format**: Use the same structure every time. Stakeholders learn where to look and can process updates faster.

## Anti-patterns to flag
- Updates that are all good news (erodes trust — every project has risks)
- Buried asks (the decision you need is in paragraph 4)
- No metrics (vague "progress was made")
- Risk without mitigation (just presenting problems)
- Inconsistent format (different structure every time)
- Too long (stakeholders stop reading after 1 page)

## Quality bar
- Status is immediately clear (first line: on track / at risk / blocked)
- Progress is quantified (not just narrative)
- Risks include mitigation plans
- Decisions needed are explicit with deadlines
- Update fits in one page / one screen
- Consistent format that stakeholders can scan quickly

## Workflow context
- Typically follows: Sprint completion, milestone, weekly cadence
- Feeds into: Decision-making, resource allocation, stakeholder alignment
- Related: `/sprint-retro` (team-internal reflection), `/go-to-market` (launch updates)

## Output
Fill `templates/stakeholder-update.md`.

## Output contract
```yaml
produces:
  - type: "status-update"
    format: "markdown"
    path: "claudedocs/<feature>-stakeholder-update.md"
    sections: [progress, blockers, decisions_needed, next_steps]
```
