---
name: docs-review
description: "Use when the user wants documentation reviewed or edited for clarity, correctness, structure, or consistency: review docs, edit this doc, make this clearer."
---

# Docs review

Reviews prose documentation (guides, READMEs, runbooks, onboarding docs, references) for its
reader. A spec or PRD that is about to be implemented goes to `spec-panel` instead; this skill
judges how well a document communicates, not whether a design is ready to build.

## Workflow

1. **Reader and purpose first:** who reads this and what must they accomplish? If the audience is
   unclear, that is the first finding. Business-facing docs use plain language without technical
   jargon.
2. **Skim test:** can a reader scanning only the headings tell what the doc covers and find their
   part? Headings say what the section contains (not "Overview" or "Details").
3. **Verify correctness against the repo:** run or trace the commands, check code samples against
   the current API, confirm paths, config keys, and links exist. Mark anything you could not verify.
4. **Follow the steps as the reader would:** missing prerequisites, assumed setup, no way to confirm
   success, no troubleshooting for procedural docs.
5. **Consistency:** one name per concept, consistent capitalization and voice across the doc set.

Patterns to flag: buried lead, jargon without definition, unfilled template text or placeholder
values, "see above" without a link, internal implementation detail the reader does not need,
walls of text without structure, and examples with foo/bar where a realistic value would teach more.
Add an example where a concept or API is hard to grasp without one; do not demand one per heading.

## Style guide

Use `references/style-guide.md` unless the repository has its own style guide.

## Output format

1. **Quick summary**: what the doc covers and who it is for
2. **Suggested edits**: grouped by section, with concrete rewrite snippets
3. **Gaps and unverified claims**: what is missing, and what could not be checked against the repo
4. **Final checklist**: yes/no items (audience clear, prerequisites listed, steps verified,
   success check present, troubleshooting present where procedural)

## Workflow context

- Typically follows: `onboarding-doc`, `runbook`, `design-doc`, `release-notes` (documentation written or updated).
- Feeds into: `finalize` (docs verified before shipping).
- Related: `ux-review` (in-product copy and content clarity).

## Output contract
```yaml
produces:
  - type: "docs-review"
    format: "markdown"
    path: "claudedocs/<feature>-docs-review.md"
    sections: [clarity, correctness, structure, consistency, edits]
    handoff: "Write claudedocs/handoff-docs-review-<timestamp>.yaml - suggest: finalize"
```
