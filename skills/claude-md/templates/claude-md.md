# CLAUDE.md

## Project overview
<!-- One-liner: what this project is and does -->

## Build & run
<!-- Commands extracted from actual build config — every command must work -->
```bash
# Install dependencies
<command>

# Run development server
<command>

# Build for production
<command>
```

## Test
```bash
# Run all tests
<command>

# Run single test file
<command> <path>

# Run with coverage
<command>
```

## Lint & format
```bash
# Lint
<command>

# Format
<command>

# Type-check (if applicable)
<command>
```

## Code style
<!-- Only list conventions that aren't obvious from linter config or language defaults -->
- Naming: <observed pattern — e.g., camelCase for functions, PascalCase for components>
- Imports: <observed ordering/grouping — e.g., stdlib → external → internal>
- Error handling: <project pattern — e.g., Result types, custom error classes, try/catch conventions>

## Architecture
<!-- Key boundaries and non-obvious structure — not a file listing -->
- `<dir>/` — <purpose and boundary>
- `<dir>/` — <purpose and boundary>

<!-- Key architectural decisions that affect how to write code here -->
- <decision and why — e.g., "All DB access goes through repository classes, never direct queries">

## Gotchas
<!-- Things that would trip someone up — the stuff not in the README -->
- <non-obvious thing>

## Preferences
<!-- How you want Claude to behave in this project -->
- <preference — e.g., "Ask before creating new files", "Prefer editing existing tests over creating new test files">

## Workflow Orchestration

### 1. Plan Mode Default
- Enter plan mode for ANY non-trivial task (3+ steps or architectural decisions)
- If something goes sideways, STOP and re-plan immediately – don't keep pushing
- Use plan mode for verification steps, not just building
- Write detailed specs upfront to reduce ambiguity

### 2. Subagent Strategy
- Use subagents liberally to keep main context window clean
- Offload research, exploration, and parallel analysis to subagents
- For complex problems, throw more compute at it via subagents
- One task per subagent for focused execution

### 3. Self-Improvement Loop
- After ANY correction from the user: update `tasks/lessons.md` with the pattern
- Write rules for yourself that prevent the same mistake
- Ruthlessly iterate on these lessons until mistake rate drops
- Review lessons at session start for relevant project

### 4. Verification Before Done
- Never mark a task complete without proving it works
- Diff behavior between main and your changes when relevant
- Ask yourself: "Would a staff engineer approve this?"
- Run tests, check logs, demonstrate correctness

### 5. Demand Elegance (Balanced)
- For non-trivial changes: pause and ask "is there a more elegant way?"
- If a fix feels hacky: "Knowing everything I know now, implement the elegant solution"
- Skip this for simple, obvious fixes – don't over-engineer
- Challenge your own work before presenting it

### 6. Autonomous Bug Fixing
- When given a bug report: just fix it. Don't ask for hand-holding
- Point at logs, errors, failing tests – then resolve them
- Zero context switching required from the user
- Go fix failing CI tests without being told how

## Task Management

1. **Plan First**: Write plan to `tasks/todo.md` with checkable items
2. **Verify Plan**: Check in before starting implementation
3. **Track Progress**: Mark items complete as you go
4. **Explain Changes**: High-level summary at each step
5. **Document Results**: Add review section to `tasks/todo.md`
6. **Capture Lessons**: Update `tasks/lessons.md` after corrections

## Core Principles

- **Simplicity First**: Make every change as simple as possible. Impact minimal code.
- **No Laziness**: Find root causes. No temporary fixes. Senior developer standards.
- **Minimal Impact**: Changes should only touch what's necessary. Avoid introducing bugs.
