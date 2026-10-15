# garage plugin (claude-skills-pack)

## Overview
Single-plugin Claude Code and Codex marketplace delivering 48 engineering skills: product
discovery, specs and design, spec-to-implementation, review, live verification, operations, and
fintech domain skills, plus 3 Claude Code lifecycle hooks. Version 2.0.0 restored the original
pack (git tag `pre-redesign`, branch `archive/v1`) in place of the 12-skill rebuild of
2026-07-07, ported to cross-client frontmatter.

## Structure
```
.claude-plugin/        Claude Code marketplace index
.agents/plugins/       Codex marketplace index
plugins/garage/        shared installable plugin
  .claude-plugin/      Claude Code plugin manifest
  .codex-plugin/       Codex plugin manifest
  skills/<name>/       SKILL.md (+ references/ for knowledge and agent personas, assets/ for
                        output templates, scripts/ for tools, agents/openai.yaml for Codex policy)
  references/          shared cross-skill references (cross-client.md)
  hooks/               Claude Code hooks + tests (not loaded by Codex)
docs/                  non-loaded knowledge: optional global-CLAUDE.md reference, ops.md,
                       mobile-defaults.md
scripts/usage-audit.py transcript miner for the quarterly usage review
```

## Skill format rules
- `name` matches directory name (kebab-case). Frontmatter is only `name` and `description`: the
  Codex validator rejects Claude-only keys (`argument-hint`, `effort`, `context`, `agent`,
  `disable-model-invocation`, `user-invocable`).
- Description starts "Use when...", states triggering conditions ONLY, and never summarizes
  the skill's workflow (an agent may follow the summary and skip the body). Under 500 chars,
  no angle brackets.
- Manual-only skills get `agents/openai.yaml` with `policy.allow_implicit_invocation: false`
  and a description that starts "Use only when the user explicitly asks...". `agents/` is
  reserved for that file; persona prompts live in `references/`.
- Skills refer to each other by bare name (`finalize`), never `/finalize`: slash commands are
  namespaced as `/garage:name` in Claude Code and `$garage:name` in Codex.
- Delegation may be written in Claude Code notation (Agent calls, worktrees, model labels) as
  long as the skill points to `../../references/cross-client.md` for other clients. No
  client-only features without a fallback there (Agent Teams was dropped for this reason).
- SKILL.md loads in full whenever the skill fires, so keep it under ~500 lines: when to use, decision
  rules, ordered steps, gates, output shape. Scaffolds, personas, per-platform detail, and report
  templates go in `references/` or `assets/` behind an explicit "read X when Y" line.
- Agent rosters are lenses: small scope runs them inline, and only large scope fans out.
- Gates judge evidence coverage, never counts ("fail if zero issues" or "at least 3 tests" are bugs).
- Skills restate house law where it applies (money BigDecimal/NUMERIC, time with zone, TSID BIGINT
  internal and UUIDv7 external, RFC 9457 errors) and detect the stack before mandating a library.
- The handoff manifest format (path, field names, status values in `handoff`) is a shared interface;
  change it only across every output contract at once.
- Every `references/` path cited in a SKILL.md must exist. Grep before committing.
- House style applies to pack files too: no em-dashes (use commas, colons, or hyphens) and no emoji, in skills, references, and docs alike.
- Hook pattern changes require `python3 plugins/garage/hooks/test_hooks.py` to pass (paired should-block / should-pass cases).

## Rules
- This repo is PUBLIC. Never commit client or employer names, credentials, internal branch
  policies, or usage analytics. Per-repo delivery policy lives in each project's own
  AGENTS.md or CLAUDE.md; the pack stays context-neutral.
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
  `quick_validate.py` from `~/.codex/skills/.system/skill-creator/scripts/` on every skill dir
  (needs PyYAML, so run it from a venv).
- After changing the repo, refresh the installed snapshots:
  `claude plugin update garage@garage` and
  `codex plugin marketplace upgrade garage && codex plugin add garage@garage`.
