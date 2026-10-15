---
name: go-to-market
description: "Use when the user is planning a product or feature launch: go to market, GTM, launch plan, messaging, channels, enablement, or launch success criteria."
---

# Go-to-market plan

Plan how a launch reaches the right people with the right message, who gets ready inside the company first, and how we will know it worked.

Ask only what is missing: what is launching, for whom, the launch style (everyone at once, in stages, a limited preview, or quietly), the date, success measures, and constraints (budget, people, legal or regulatory review).

## Rules
- Scale the plan to the launch. A small improvement needs a short note to support and a line in the release notes; a new product needs the full plan.
- Lead with what the customer can now do, not what we built: "Get paid out the same day", not "We added instant settlement".
- Split audiences only where the message or channel really differs. Each channel earns its place: in-product for discovery, email for changes people must act on, help articles for how-to.
- Support, sales, and account teams are briefed before customers see the launch, with an FAQ and a way to escalate problems.
- Success is measured along the path: noticed, tried, got value, kept using. Set targets and dates, and watch support contacts and complaints alongside.
- Plan the bad day: serious bug, confusing message, low uptake, negative reaction. Name who decides to pause or roll back and how customers are told.
- Write in plain language for marketing, sales, support, and finance readers. No engineering jargon or internal shorthand; say who owns each item by name or team.

## Workflow context
- `go-to-market` plans the launch; `release-notes` lists what shipped; `stakeholder-update` reports progress to leadership.
- Draws on `competitive-analysis` for positioning and `experiment-design` for staged launches; feeds `stakeholder-update`.

## Output
Fill `assets/go-to-market.md`, keeping only the sections this launch needs.

## Output contract
```yaml
produces:
  - type: "launch-plan"
    format: "markdown"
    path: "claudedocs/<feature>-go-to-market.md"
    sections: [messaging, channels, enablement, success_criteria, timeline]
```
