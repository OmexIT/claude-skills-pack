---
name: repo-conventions
description: "Use when the user wants a repository's architecture, API style, or testing conventions written down or updated, or asks which conventions to follow in a repository."
---

# Repo conventions

The repository's own instructions always win. This skill finds them, and helps write them down when they are missing.

## Where conventions come from, in order
1. The repo's `AGENTS.md` and `CLAUDE.md` (root and nested) and the docs they point to. If they exist, follow them and do not load this skill's references.
2. The code: existing naming, folder layout, error handling, test style, and utilities. Match it, and reuse existing helpers before writing new ones.
3. When neither settles a question, propose one or two options grounded in the code and ask which the team prefers.

## The references are blank templates
`references/architecture.md`, `references/api-style.md`, and `references/testing.md` ship unfilled. Each begins with a `PLACEHOLDER` line; while that line is present, treat the file as absent and never present its prompts as rules. A fork of this pack that fills a file in removes that line. These files apply to every repository using the install and are replaced on plugin update, so one repository's conventions belong in that repository.

## Writing conventions down (when asked)
1. Derive each rule from the code and cite a file as the example. Mark anything you inferred but could not confirm.
2. Use the reference templates as an outline only. Write the result into the repo's `AGENTS.md`, `CLAUDE.md`, or a doc they link to; show the text first and edit an existing instruction file only with the user's approval.
3. Each rule must settle a real disagreement ("errors return RFC 9457 Problem Details", not "be consistent"). Keep each area to a page or two, and drop rules the code already contradicts.
