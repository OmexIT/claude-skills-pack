---
name: release-notes
description: "Use only when the user explicitly asks for release notes, a changelog, or a summary of what shipped from a set of PRs, commits, or features."
---

# Release notes

## Inputs
- Version number or date range
- Merged PRs or commit range (or a summary of what shipped)
- Audience: external users, internal stakeholders, or both

## Rules
1. **Source of truth is what merged.** Build the list from the actual merged PRs or `git log` for the
   range; never include unmerged or reverted work, and never invent items. Ask when the range is
   unclear.
2. **Audience-first.** External readers get outcomes in plain language ("You can now export reports
   as PDF"), no internal service names or jargon. Internal readers additionally get operations
   notes.
3. **Order by impact**: highlights, improvements, fixes, then breaking changes called out
   separately so nobody misses them.
4. **Breaking changes** state what changed, who is affected, what to do, and by when.
5. **Known issues** are listed with workarounds; shipping with them is fine, hiding them is not.
6. **Internal operations** for risky changes: migrations, flags already in use, what to monitor, and
   how to roll back.
7. Follow the repo's existing changelog format (for example `CHANGELOG.md` conventions) when one
   exists.

## Anti-patterns to flag
- "Various bug fixes and improvements"
- Breaking changes buried in a list without migration guidance
- Internal identifiers or customer names in external notes

## Output
Fill `assets/release-notes.md`; drop empty sections.

## Workflow context
- Summarizes what shipped; `stakeholder-update` reports progress and status to people, not the change list.
- Follows `finalize` or a merged release; uses `test-plan` for verified scope.

## Output contract
```yaml
produces:
  - type: "release-notes"
    format: "markdown"
    path: "claudedocs/<feature>-release-notes.md"
    sections: [highlights, breaking_changes, migration, rollback]
```
