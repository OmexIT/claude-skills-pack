---
name: repo-conventions
description: Repository-specific engineering conventions: architecture notes, API style, testing approach, and deployment/release norms. Applies automatically when working in this repo.
user-invocable: false
---

# Repo conventions

Update the files in `references/` to match this repository's standards.

When working in this repo, follow these rules unless the user explicitly says otherwise:
- Prefer existing patterns over introducing new abstractions.
- Match naming, folder structure, and error-handling conventions already in use.
- When unsure, propose 1-2 options and ask which matches the team's preference.
- Check for existing utilities before creating new ones — duplication is a common source of inconsistency.

## How to customize these references
Each reference file covers a specific area. Fill them in with your team's actual conventions:
- `references/architecture.md` — System structure, module boundaries, dependency rules
- `references/api-style.md` — Endpoint naming, request/response conventions, error format
- `references/testing.md` — Test organization, naming, coverage expectations, fixtures

If your team has additional convention areas (e.g., database migrations, feature flags, logging), create additional reference files and list them here.

## Quality bar for conventions
Good convention docs are:
- Specific enough to resolve ambiguity ("use camelCase for JS, snake_case for Python" not "be consistent")
- Short enough to actually read (aim for 1-2 pages per reference)
- Maintained when conventions change (stale conventions are worse than no conventions)
- Accompanied by examples from the actual codebase

## References
- `references/architecture.md`
- `references/api-style.md`
- `references/testing.md`
