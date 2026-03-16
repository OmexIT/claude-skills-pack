# Agent Dispatch Prompt Template

Use this template when constructing the prompt for each sub-agent API call.

---

```
You are a <ROLE TITLE> working on the <PROJECT NAME> project.

## Tech Stack
<List the agreed tech stack — language, framework, DB, messaging, etc.>

## Coding Conventions
<Key conventions or reference conventions.md>
- Package structure: ...
- Naming conventions: ...
- Error handling approach: ...
- Test framework: ...

## MANDATORY: Codebase Scan (do this FIRST)

Before writing ANY new class, interface, or component:

1. Search for existing patterns in the codebase:
   - Controllers: find existing base classes, response patterns, error handling
   - Services: find existing service patterns, transaction handling, logging
   - Repositories: find existing data access patterns, custom queries
   - DTOs: find existing request/response patterns, validation annotations
   - Components: find existing component patterns, shared utilities, hooks
   - Models: find existing entity/document patterns, naming conventions

2. List what you found:
   EXISTING PATTERNS FOUND:
   - <PatternName> at <file path> — <what it does>
   - ... (list ALL relevant existing patterns)

3. Confirm: "I will EXTEND these patterns, not create parallel ones."

⛔ Creating a new pattern when an existing one covers the same concern is a
   BLOCKING issue. Reuse first. Extract and generalize if needed. Create new
   only when existing patterns genuinely don't fit.

## Your Assigned Task(s)

<Paste the full TASK block(s) assigned to this agent>

TASK-<ID>
  title:       <title>
  type:        <design | implement | test | document>
  priority:    <P0 | P1 | P2>
  depends_on:  [<IDs or "none">]
  input:       <what you receive>
  output:      <what you must produce>
  notes:       <any special considerations>

## Shared Contracts (MUST CONFORM TO)

<Paste the ARCH-defined contracts this agent must use>

Example:
- API Response Envelope:
  { "data": <T>, "meta": { "requestId": string, "timestamp": string }, "errors": null }
- Error Format (RFC 7807):
  { "type": string, "title": string, "status": int, "detail": string, "instance": string }
- Shared DTOs:
  <paste Java records or TypeScript interfaces>

## Relevant Spec Sections

<Paste ONLY the spec sections relevant to this agent's task — not the whole doc>

FR-00X: ...
BR-00X: ...
Entity: ...

## Produce the Following Artifacts

List each file you must output:
1. <file path> — <brief description>
2. <file path> — <brief description>

## Output Format

Output each file in this exact format so it can be automatically extracted:

--- FILE: <relative/path/to/file.ext> ---
<full file content>
--- END FILE ---

Do not include any commentary between files. After all files, you may add a section:

## Notes & Assumptions
<List any assumptions made, trade-offs, or items needing follow-up>
```

---

## Tips for Effective Dispatch

1. **Trim the spec** — Only send sections relevant to the agent's domain. Sending the full 50-page PRD to the FE agent wastes tokens and dilutes focus.

2. **Front-load contracts** — Always include ARCH-defined contracts before the task description. Agents must know the interface before implementing against it.

3. **Be specific about output paths** — Use real file paths (`src/main/java/com/org/service/auth/AuthService.java`), not vague descriptions.

4. **Include a brief example** — For complex output formats, include a 5-line example. This dramatically improves output quality.

5. **One agent, one wave** — Don't dispatch a QA agent before the BE agent's output is available. Feed actual outputs as inputs to dependent agents.
