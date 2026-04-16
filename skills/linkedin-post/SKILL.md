---
name: linkedin-post
description: "Draft a LinkedIn post with hook, body, and CTA optimized for engagement and professional credibility. Supports thought leadership, announcements, storytelling, and lessons learned. Use when writing a linkedin post, linkedin update, professional post, or thought leadership post."
argument-hint: "[topic / announcement / lesson]"
---

# LinkedIn post

## What this skill does
Produce a publish-ready LinkedIn post that earns attention in the feed, delivers value, and drives a clear outcome (engagement, traffic, or credibility).

## Inputs (ask only if missing)
- **Topic**: The announcement, story, lesson, or idea to share
- **Post type**: thought leadership | announcement | lesson learned | how-to | hot take | storytelling | carousel outline
- **Audience**: Who should stop scrolling
- **Goal**: engagement (comments) | traffic (link clicks) | credibility (brand building) | hiring | community building
- **Tone**: conversational | authoritative | vulnerable | provocative | celebratory
- **Constraints**: Company voice guidelines, required links, hashtag preferences

## Writing checklist

Apply every item below. If a draft violates any point, revise before presenting.

### Hook (first 2 lines)
- Lead with a bold claim, surprising number, counterintuitive take, or relatable moment
- Must create enough curiosity that the reader taps "see more"
- Never open with "I wanted to share...", "I've been thinking...", or any preamble
- Do not start the first line with "I" -- make the opening about the reader or the idea

### Body
- One idea per post. Multiple ideas = multiple posts
- Use specific details ("We lost our biggest client on a Tuesday morning") over generic statements ("Sometimes business is tough")
- Each paragraph must earn its place: if it restates the hook or adds no new value, cut it
- Deliver genuine value (insight, framework, lesson, reframe) before any ask

### CTA
- Every post needs exactly one call to action matched to the stated goal
- Engagement goal: pose a question or invite disagreement
- Traffic goal: context-first, then link (or place link in first comment to avoid suppression)
- Credibility goal: invite readers to share their own experience

### Formatting and platform rules
- No markdown (LinkedIn does not render it)
- Plain text only; use Unicode symbols sparingly if needed
- 3-5 hashtags at the end, mixing broad (#Leadership) with niche (#DevTooling)
- Tag people/companies only when genuinely relevant
- Target 150-300 words; do not pad and do not rush

### Things to avoid
- Humble-brag framing ("I'm so humbled that...") -- state the achievement directly
- Engagement bait without substance ("Like if you agree!")
- Corporate press-release tone
- More than 5 hashtags or emoji-heavy formatting
- Dropping a link in the body without explaining its value first

## Example

**Input**: Topic: We just shipped a CLI tool that cuts deploy time by 40%. Audience: DevOps engineers. Goal: engagement. Tone: conversational.

**Output** (copy-paste ready):

```
Most deploy pipelines have a dirty secret.

They waste 40% of their time on steps nobody questioned.

We just shipped a CLI that strips out the dead weight:
- Parallel asset builds instead of sequential
- Cached dependency resolution (hit rate >90% after first run)
- Zero-downtime swap with automatic rollback

We tested it across 11 production services over 3 weeks.
Average deploy went from 14 minutes to 8.

The surprising part? The biggest win wasn't parallelism.
It was skipping the integrity check that re-hashed unchanged files every single time.

What's the one step in your pipeline you suspect is wasted time but nobody wants to touch?

#DevOps #CICD #DeveloperProductivity #ShipFaster
```

## Output template

The output fills `templates/linkedin-post.md` with this structure:

| Section | Content |
|---------|---------|
| **Post metadata** | Type, audience, goal, tone |
| **Hook** | First 2 lines (must work before the "see more" fold) |
| **Body** | Core content, one idea, scannable paragraphs |
| **CTA** | Single call to action matched to goal |
| **Hashtags** | 3-5 relevant hashtags |
| **Post (copy-paste ready)** | Full assembled post in plain text, no markdown |
| **Variations** (optional) | Shorter (~100 words) and longer (~400 words) versions |
| **Notes** | Character count, tagged people, link strategy, suggested posting time |

## Workflow context
- Typically follows: `/go-to-market` (launch announcements), `/release-notes` (shipping updates), `/stakeholder-update` (milestone sharing), `/postmortem` (lessons learned)
- Feeds into: Content calendar, social media strategy, personal branding
- Related: `/go-to-market` (launch messaging), `/competitive-analysis` (positioning takes)

## Output contract
```yaml
produces:
  - type: "content"
    format: "markdown"
    path: "claudedocs/<feature>-linkedin-post.md"
    sections: [hook, body, cta, hashtags]
```
