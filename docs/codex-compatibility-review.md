# Codex compatibility review

Date: 2026-07-13

## Outcome

The 12 skills are suitable for a shared Claude Code and Codex plugin after the packaging and
frontmatter changes recorded below. Claude Code keeps its three lifecycle hooks. Codex installs
the same skills, references, and skill scripts without advertising unsupported hook behavior.

## Findings and disposition

| Severity | Finding | Evidence | Disposition |
|---|---|---|---|
| P1 | The repository was not installable as a Codex plugin. | No `.codex-plugin/plugin.json` or `.agents/plugins/marketplace.json` existed; the Codex validator failed on the missing manifest. | Added a Codex manifest and marketplace index. |
| P1 | All 12 skills failed Codex skill validation. | Every SKILL.md used the unsupported `argument-hint` frontmatter key. | Removed the key and kept invocation guidance in each skill's description/body. |
| P1 | A single-root layout could not satisfy both marketplace conventions cleanly. | Codex marketplace entries resolve `./plugins/<name>`; the Claude marketplace previously pointed at the repository root. | Moved the shared plugin under `plugins/garage`; both marketplaces now point there. |
| P2 | Several skills assumed Claude-specific repository files and delegation controls. | `build`, `plan`, `e2e`, and `ship` hardcoded CLAUDE.md/`.claude`; `build` named Claude-specific agent options. | Generalized instructions to AGENTS.md/CLAUDE.md and capability-based delegation. |
| P2 | Documentation implied hook parity across clients. | Codex plugin manifests do not ingest the Claude hook protocol. | Documented hooks as Claude Code-only and omitted hooks from the Codex manifest. |
| P3 | Claude validation reported packaging warnings. | The marketplace had no description and the plugin lived beside a root CLAUDE.md that is not loaded as plugin context. | Added a marketplace description and moved the plugin beneath `plugins/garage`. |

## Validation

Passed against the 2026-07-13 checkout:

- Claude marketplace and nested plugin validation completed without warnings.
- The Codex plugin validator passed for `plugins/garage`.
- All 12 skills passed the Codex skill validator.
- Claude hook smoke tests passed 19/19; Python compilation and shell syntax checks passed.
- An isolated Codex home added this checkout as a marketplace, discovered `garage@garage`
  version 1.1.0, installed and enabled it, and cached all 12 skills.
- `claude --plugin-dir plugins/garage --help` loaded the nested plugin successfully.
- JSON parsing, manifest-version parity, and `git diff --check` passed.

Version 1.1.0 was committed and pushed on 2026-07-13, so both local-path and documented Git
installation are available. The later 1.2.0 content review is tracked separately in
`docs/skills-content-review-2026-07-13.md`.

## Deliberate non-parity

- `plugins/garage/hooks/` remains Claude Code-only because Codex does not accept hooks in its
  plugin manifest.
- `scripts/usage-audit.py` remains a repository-maintenance tool for Claude Code history. It is
  outside the installed plugin and must not be treated as cross-client usage telemetry.

## Version 1.2.0 content follow-up

The full skill-content review in `docs/skills-content-review-2026-07-13.md` removed contradictory
and unsafe guidance while preserving the same 12-skill topology. A fresh isolated Codex home
installed and enabled version 1.2.0, cached all 12 skills, and produced a cache identical to the
plugin checkout. Claude marketplace/plugin validation, all Codex skill/plugin validators, 33 hook
tests, JSON parsing, shell syntax, usage-audit fixtures, and `git diff --check` passed.
