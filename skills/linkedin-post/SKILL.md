---
name: linkedin-post
description: Draft a LinkedIn post with hook, body, and CTA optimized for engagement and professional credibility. Supports thought leadership, announcements, storytelling, and lessons learned. Triggers: "linkedin post", "linkedin", "linkedin update", "professional post", "thought leadership post".
argument-hint: "[topic / announcement / lesson]"
---

# LinkedIn post

## What I'll do
Produce a publish-ready LinkedIn post that earns attention in the feed, delivers value to the reader, and drives a clear outcome — whether that's engagement, traffic, or credibility.

## Inputs I'll use (ask only if missing)
- Topic, announcement, or story to share
- Post type: thought leadership, announcement, lesson learned, how-to, hot take, storytelling, carousel outline
- Target audience (who should stop scrolling?)
- Goal: engagement (comments), traffic (link clicks), credibility (brand building), hiring, or community building
- Tone: conversational, authoritative, vulnerable, provocative, celebratory
- Any constraints (company voice guidelines, links to include, hashtags)

## How I'll think about this
1. **Hook in the first 2 lines**: LinkedIn truncates after ~210 characters with "...see more." The hook must create enough curiosity or tension that people click to expand. No throat-clearing ("I've been thinking about..."), no preambles. Lead with a bold claim, a surprising number, a counterintuitive take, or a relatable moment.
2. **One idea per post**: Posts that try to cover 3 topics get scrolled past. Pick one clear idea and make it land. If there are multiple ideas, that's multiple posts.
3. **Write for scanners**: Short paragraphs (1-2 sentences max). Line breaks between every thought. Use white space aggressively — a wall of text dies in the feed. Numbered lists and bullet points work when they add structure, not decoration.
4. **Value before ask**: Give the reader something — an insight, a framework, a lesson, a reframe — before asking them to do anything. The CTA earns the right to exist by coming after genuine value.
5. **Authentic voice over polish**: LinkedIn rewards posts that sound like a person, not a press release. Specific details ("We lost our biggest client on a Tuesday morning") beat generic statements ("Sometimes business is tough"). Vulnerability and specificity drive engagement.
6. **Strategic CTA**: Every post needs a purpose. "Agree? Disagree? Tell me in the comments" drives engagement. A link drives traffic. A question drives conversation. No CTA means wasted attention. Match the CTA to the goal.
7. **Hashtag discipline**: 3-5 relevant hashtags maximum, placed at the end. Mix broad (#Leadership, #ProductManagement) with niche (#DevTooling, #StartupLessons). More than 5 looks spammy and doesn't improve reach.
8. **Platform-aware formatting**: No markdown (LinkedIn doesn't render it). Use Unicode symbols sparingly if needed. Emojis as bullet points work when they match the tone — don't force them on serious content. Tag people and companies only when genuinely relevant.

## Anti-patterns to flag
- Weak hooks ("I wanted to share some thoughts on...")
- Wall-of-text paragraphs (no line breaks, no scanning structure)
- Humble-brag framing ("I'm so humbled that..." — just state the achievement)
- Engagement bait without substance ("Like if you agree!")
- Corporate speak that sounds like a press release, not a person
- Posts with no clear CTA or purpose (attention with no direction)
- Overloaded with hashtags (>5) or emojis (every line starts with one)
- Multiple competing ideas in one post (pick one, save the rest)
- Starting with "I" (makes the post about you, not the reader)
- Link in the body without context (LinkedIn suppresses external links — explain the value first)

## Quality bar
- Hook creates genuine curiosity or tension (would YOU click "see more"?)
- Post delivers on the hook's promise (no bait-and-switch)
- Single clear idea, fully developed
- Every paragraph earns its place (no filler)
- Reads like a real person wrote it, not a template
- CTA matches the stated goal
- Post length fits the content (not padded, not rushed — typically 150-300 words)
- Hashtags are relevant and restrained (3-5)
- No markdown formatting (LinkedIn doesn't support it)

## Workflow context
- Typically follows: `/go-to-market` (launch announcements), `/release-notes` (shipping updates), `/stakeholder-update` (milestone sharing), `/postmortem` (lessons learned)
- Feeds into: Content calendar, social media strategy, personal branding
- Related: `/go-to-market` (launch messaging), `/competitive-analysis` (positioning takes)

## Output
Fill `templates/linkedin-post.md`.

## Output contract
```yaml
produces:
  - type: "content"
    format: "markdown"
    path: "claudedocs/<feature>-linkedin-post.md"
    sections: [hook, body, cta, hashtags]
```
