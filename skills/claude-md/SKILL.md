---
name: claude-md
description: Generate a CLAUDE.md project configuration file for Claude Code. Analyzes codebase to produce build commands, code conventions, architecture notes, and workflow preferences. Triggers: "claude md", "CLAUDE.md", "claude code setup", "project instructions", "claude config".
argument-hint: "[project path or description]"
---

# CLAUDE.md generator

## What I'll do
Analyze the codebase and produce a `CLAUDE.md` file that gives Claude Code the context it needs to work effectively in this project — build commands, conventions, architecture, and anything a new contributor would need to know.

## Inputs I'll use (ask only if missing)
- Project root path (default: current directory)
- Any strong preferences about how Claude should behave in this project
- Existing documentation to incorporate (READMEs, contributing guides, ADRs)

## How I'll think about this
1. **Analyze before writing**: Read the project's package.json / pyproject.toml / Makefile / Cargo.toml / build files to extract real commands — never guess.
2. **Observe, don't invent conventions**: Look at the actual code for naming patterns, file organization, import style, and error handling. Document what exists, not what "should" exist.
3. **Commands must be copy-pasteable**: Every build, test, and lint command should work when pasted into a terminal. Verify against the actual build config.
4. **Keep it scannable**: Claude reads this file at the start of every session. Dense walls of text waste context. Use short sections, bullet points, and only include what changes behavior.
5. **Separate facts from preferences**: Build commands are facts (derived from config). "Prefer composition over inheritance" is a preference (needs user input or strong codebase evidence).
6. **Prioritize high-signal content**: A CLAUDE.md that says "use TypeScript" for a TypeScript project adds nothing. Focus on things Claude wouldn't infer from the code itself — gotchas, non-obvious patterns, team decisions.

## Anti-patterns to flag
- Inventing build commands instead of reading them from config files
- Restating language defaults as project conventions ("use const in JavaScript")
- Including generic advice that applies to every project ("write clean code")
- Writing long architectural essays — keep it to what affects day-to-day coding decisions
- Listing every file and directory — focus on non-obvious structure
- Adding aspirational conventions the codebase doesn't actually follow

## Quality bar
- Every command listed actually runs successfully in the project
- Conventions described are backed by evidence in the codebase (not aspirational)
- File is under 150 lines — if longer, it probably includes low-signal content
- A new contributor reading only this file could make a correct PR on their first try
- Architecture section explains *boundaries* and *decisions*, not a file-by-file listing
- No duplication with what's already in README.md or CONTRIBUTING.md

## Workflow context
- Typically follows: Project creation, repository setup, team onboarding
- Feeds into: Every Claude Code session in this project (read automatically)
- Related: `/repo-conventions` (detailed convention references), `/onboarding-doc` (human onboarding)

## Output
Use the template at `templates/claude-md.md`.

Before generating, always:
- Read `package.json`, `pyproject.toml`, `Makefile`, `Cargo.toml`, or equivalent build config
- Scan 3-5 source files to observe actual conventions
- Check for existing `README.md`, `CONTRIBUTING.md`, `.editorconfig`, linter configs
- Look at test files to understand the testing approach

## Always-included sections
The following sections from the template are **not project-specific** — they must be included verbatim in every generated CLAUDE.md:
- **Workflow Orchestration** (Plan Mode Default, Subagent Strategy, Self-Improvement Loop, Verification Before Done, Demand Elegance, Autonomous Bug Fixing)
- **Task Management** (plan-first workflow with `tasks/todo.md` and `tasks/lessons.md`)
- **Core Principles** (Simplicity First, No Laziness, Minimal Impact)

These sections define standard Claude Code working behavior and should never be omitted or modified during generation.
