---
name: linkedin-post
description: "Use when the user wants a LinkedIn post drafted: thought leadership, an announcement, a story, or lessons learned."
---

# LinkedIn post

Draft a post that sounds like the user wrote it on a good day: one idea, told with specifics, worth reading to the end.

Ask only what is missing: the topic or story, who should read it, what the user wants to happen (conversation, clicks, credibility, hiring), and any voice samples or past posts to match.

## Rules
- Use only facts, numbers, names, and experiences the user gave. Never invent an anecdote, a metric, a quote, or a client. If the story needs a detail you do not have, ask.
- The first two lines carry the post, because the feed cuts it off there. Open with the specific moment, number, or claim. No warm-up ("I've been thinking about...", "I wanted to share...").
- One idea per post. A second idea is a second post.
- Short paragraphs with blank lines between them. Plain text only: LinkedIn does not render markdown, so no headings, bold, or bullet syntax beyond simple numbered lines.
- Concrete beats general: "we lost our largest client on a Tuesday" beats "business is hard". Show the lesson through what happened rather than stating it as a slogan.
- End with a real question or a clear next step only when it fits the goal. No engagement bait ("Agree?", "Comment YES", "Like if...").
- No emoji. No hashtags unless the user asks; then two or three relevant ones at the end, never a block.
- Sound like a person, not a press release or a model. Cut on sight: "excited to announce", "thrilled", "humbled", "game-changer", "delve", "leverage", "seamless", "robust", "in today's fast-paced world", "here's the thing", "let that sink in", one-line dramatic paragraphs stacked for effect, and em-dashes.
- Usually 120-300 words; shorter when the idea is small. LinkedIn caps posts at 3,000 characters.
- Tag people or companies only when the user says to.

## Workflow context
- Often follows `release-notes`, `go-to-market`, or `postmortem` when the user wants to share the story publicly; strip anything internal, confidential, or customer-identifying first.

## Output
Fill `assets/linkedin-post.md`.

## Output contract
```yaml
produces:
  - type: "content"
    format: "markdown"
    path: "claudedocs/<feature>-linkedin-post.md"
    sections: [hook, body, cta, hashtags]
```
