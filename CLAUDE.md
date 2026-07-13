# garage plugin (claude-skills-pack)

## Overview
Single-plugin Claude Code and Codex marketplace delivering a 12-skill engineering copilot: a 7-verb
workflow spine (spec, plan, build, audit, e2e, ship, debug) and 5 domain-law skills
(ledger, temporal, migrations, spring-api, igaming-ui), plus 3 Claude Code lifecycle hooks. Rebuilt
2026-07-07 from usage evidence; the previous 48-skill generation is preserved at git tag
`pre-redesign` (branch `archive/v1`).

## Structure
```
.claude-plugin/        Claude Code marketplace index
.agents/plugins/       Codex marketplace index
plugins/garage/        shared installable plugin
  .claude-plugin/      Claude Code plugin manifest
  .codex-plugin/       Codex plugin manifest
  skills/<name>/       SKILL.md (+ references/ for knowledge, assets/ for output templates,
                        scripts/ for tools)
  references/          shared cross-skill references
  hooks/               Claude Code hooks + tests (not loaded by Codex)
docs/                  non-loaded knowledge: optional global-CLAUDE.md reference, ops.md,
                       mobile-defaults.md
scripts/usage-audit.py transcript miner for the quarterly usage review
```

## Skill format rules
- `name` matches directory name (kebab-case). Cross-client frontmatter uses only `name` and
  `description`; Claude's `argument-hint` is not accepted by the Codex skill validator.
- Description starts "Use when...", states triggering conditions ONLY, and never summarizes
  the skill's workflow (an agent may follow the summary and skip the body). Under 500 chars.
- Body stays under ~60 lines. Heavy knowledge goes in `references/`, loaded on demand.
- Banned ceremony (the old pack's failure modes): output-contract YAML, handoff manifests,
  "Learning & Memory" sections, "Workflow context" webs, model-routing tables, multi-agent
  rosters, ASCII wave diagrams.
- Every `references/` path cited in a SKILL.md must exist. Grep before committing.
- House style applies to pack files too: no em-dashes (use commas, colons, or hyphens) and no emoji, in skills, references, and docs alike.
- Hook pattern changes require `python3 plugins/garage/hooks/test_hooks.py` to pass (paired should-block / should-pass cases).

## Rules
- This repo is PUBLIC. Never commit client or employer names, credentials, internal branch
  policies, or usage analytics. Per-repo delivery policy lives in each project's own
  AGENTS.md or CLAUDE.md (`## Ship policy` block); the pack stays context-neutral.
- Never commit `claudedocs/` (local working files, gitignored).
- Hooks read JSON on stdin; block = exit 2 + stderr; warn = stderr + exit 0; side-effect
  hooks exit 0 silently.
- Quarterly: run `scripts/usage-audit.py`; delete skills unused for two quarters; when an
  official plugin reaches parity with a skill, delete the skill. Raw prompt export is opt-in via
  `--corpus-dir` and its output is sensitive, local-only data.
- New domain skills require at least 3 real uses of the pattern first. No speculative skills.
- Bump both plugin manifests on every plugin change.
- Validate before shipping:
  `claude plugin validate .`,
  `claude plugin validate plugins/garage/.claude-plugin/plugin.json`, and
  `python3 ~/.codex/skills/.system/plugin-creator/scripts/validate_plugin.py plugins/garage`.
- After changing the repo, refresh the installed snapshots:
  `claude plugin update garage@garage` and
  `codex plugin marketplace upgrade garage && codex plugin add garage@garage`.
