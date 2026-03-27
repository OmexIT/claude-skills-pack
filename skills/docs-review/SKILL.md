---
name: docs-review
description: Review documentation for clarity, correctness, structure, and consistency. Produces actionable edits and a checklist. Triggers: "review docs", "edit this doc", "make this clearer", "docs quality".
argument-hint: "[file path | doc text]"
effort: medium
---

# Docs review

## What I optimize for
- Clear audience and purpose
- Skimmability (headings, bullets, examples)
- Correctness and completeness
- Consistent terminology and voice

## How I'll think about this
1. **Reader's perspective first**: Who is reading this and what do they need to accomplish? If the audience isn't clear, the doc can't be good. A tutorial for beginners reads differently than an API reference for experts.
2. **The 5-second test**: Can a reader scanning headings understand what this doc covers and find what they need? If not, the structure needs work.
3. **Show, don't just tell**: Every concept should have at least one example. Abstract descriptions without concrete examples are documentation debt.
4. **Test the instructions**: Can someone actually follow the steps and succeed? Untested docs are a leading cause of developer frustration and support tickets.
5. **Consistency compounds**: Inconsistent terminology, capitalization, or formatting creates cognitive overhead that accumulates across a doc set.

## Specific patterns to check
- **Missing prerequisites**: Steps that assume setup or context the reader might not have
- **Outdated information**: Code samples that don't match the current API, screenshots of old UI
- **Buried lead**: The most important information is hidden deep in the doc instead of upfront
- **Jargon without definition**: Terms that aren't obvious to the target audience
- **Dead links**: References to pages, repos, or tools that no longer exist
- **Copy-paste errors**: Template text that wasn't filled in, placeholder values in examples

## Anti-patterns to flag
- Wall of text without headings or visual structure
- "See above" or "as mentioned" without links (forces reader to scroll)
- Documenting internal implementation that the reader doesn't need to know
- Missing error/troubleshooting section for how-to guides
- Examples with foo/bar instead of realistic values

## Quality bar
- A reader from the target audience can accomplish their goal without outside help
- Every heading is descriptive (not "Overview" or "Details" — what overview? what details?)
- At least one working code example per API or concept
- Prerequisites are listed before instructions
- Troubleshooting section exists for procedural docs

## Style guide
Use `references/style-guide.md` as the default style guide unless the repo has its own.

## Workflow context
- Typically follows: `/onboarding-doc`, `/runbook`, `/design-doc` (documentation created or updated)
- Feeds into: `/finalize` (docs quality verified before shipping)
- Related: `/ux-review` (content clarity overlaps)

## Output format
1. **Quick summary** (what the doc covers and who it's for)
2. **Suggested edits** (grouped by section, concrete rewrite snippets)
3. **Gaps / missing info** (what's not answered but should be)
4. **Final checklist** (yes/no items)

## Learning & Memory
After completing this skill, store reusable insights in memory:
- **Documentation style patterns**: Effective heading structures, bullet-point density, and example-to-explanation ratios that improved readability
- **Common clarity issues**: Recurring ambiguities, jargon traps, and structural problems found across documentation sets
- **Structure improvements**: Reusable document organization patterns, information hierarchy templates, and navigation aids that reduced reader friction

## Output contract
```yaml
produces:
  - type: "docs-review"
    format: "markdown"
    path: "claudedocs/<feature>-docs-review.md"
    sections: [clarity, correctness, structure, consistency, edits]
    handoff: "Write claudedocs/handoff-docs-review-<timestamp>.yaml — suggest: finalize"
```
