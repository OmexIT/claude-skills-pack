---
name: go-to-market
description: Plan a product or feature launch with messaging, channels, enablement, success criteria, and timeline. Triggers: "go to market", "GTM", "launch plan", "product launch", "feature launch".
argument-hint: "[product / feature]"
---

# Go-to-market plan

## What I'll do
Produce a launch plan that coordinates messaging, channels, enablement, and measurement so the product reaches users effectively.

## Inputs I'll use (ask only if missing)
- What's launching (feature, product, major update)
- Target audience (who needs to know?)
- Launch type: big-bang, phased rollout, silent launch, beta
- Success criteria (what does a successful launch look like?)
- Constraints (timeline, budget, team availability)

## How I'll think about this
1. **Audience segmentation**: Different audiences need different messages through different channels. Internal teams (support, sales, engineering) need different enablement than external users.
2. **Message hierarchy**: Lead with the user benefit, not the feature. "Find answers 3x faster" not "We added vector search." The feature is the mechanism; the benefit is the message.
3. **Channel-message fit**: Blog posts for announcements, in-app for feature discovery, email for breaking changes, docs for how-to. Don't blast every message through every channel.
4. **Enablement before launch**: Support team, sales team, and customer success must be trained before users encounter the new feature. They should never learn about a launch from a customer.
5. **Measure what matters**: Awareness (did people notice?), adoption (did they try it?), activation (did they get value?), retention (did they keep using it?). Track the full funnel.
6. **Plan for things going wrong**: Negative feedback, bugs at scale, misunderstood messaging, unexpected load. Have a response plan.

## Anti-patterns to flag
- Feature-focused messaging ("We built X") instead of benefit-focused ("You can now do Y")
- Launching without support team enablement
- No measurement plan (how will you know if the launch succeeded?)
- Big-bang launch for high-risk features (use phased rollout)
- No rollback plan for feature launches
- Assuming launch day = finish line (adoption takes weeks/months)

## Quality bar
- Target audience is segmented with per-segment messaging
- Internal enablement (support, sales) is scheduled before external launch
- Success criteria are specific and measurable (not "positive reception")
- Timeline includes pre-launch, launch day, and post-launch phases
- Contingency plan exists for negative scenarios (bugs, backlash, low adoption)
- Channel strategy matches audience habits

## Workflow context
- Typically follows: `/prd`, `/experiment-design`, `/release-notes`
- Feeds into: `/stakeholder-update`, post-launch measurement
- Related: `/competitive-analysis` (positioning), `/docs-review` (user-facing documentation)

## Output
Fill `templates/go-to-market.md`.

## Output contract
```yaml
produces:
  - type: "launch-plan"
    format: "markdown"
    path: "claudedocs/<feature>-go-to-market.md"
    sections: [messaging, channels, enablement, success_criteria, timeline]
```
