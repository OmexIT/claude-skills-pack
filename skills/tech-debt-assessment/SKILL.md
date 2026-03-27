---
name: tech-debt-assessment
description: Inventory and prioritize technical debt by type, cost-of-delay, and strategic impact. Produces an actionable repayment roadmap. Triggers: "tech debt", "technical debt", "code health", "refactoring priorities", "cleanup".
argument-hint: "[codebase / area / service]"
effort: high
---

# Tech debt assessment

## What I'll do
Inventory technical debt in a codebase or system, categorize it by type and severity, and produce a prioritized repayment plan based on cost-of-delay.

## Inputs I'll use (ask only if missing)
- Codebase or area to assess
- Known pain points (slow builds, flaky tests, difficult deploys)
- Team concerns or frustrations
- Upcoming roadmap (what features are planned that debt blocks?)

## How I'll think about this
1. **Categorize by type**: Code debt (duplication, poor abstractions), architecture debt (wrong boundaries, scaling limits), testing debt (low coverage, flaky tests), infrastructure debt (manual processes, outdated tooling), documentation debt (missing runbooks, outdated docs). Different types require different remediation approaches.
2. **Measure cost-of-delay, not just ugliness**: Ugly code that nobody touches has zero cost. Clean code that you modify weekly saves time on every change. Prioritize debt that's actively slowing the team down.
3. **Identify compounding debt**: Some debt gets worse over time — every new feature built on a bad abstraction makes the eventual fix harder. This is the most urgent category.
4. **Connect to roadmap**: Tech debt that blocks upcoming features should be addressed first. Debt in areas you won't touch for 6 months can wait.
5. **Right-size the fix**: Not all debt needs a big refactor. Sometimes the fix is a small naming change, extracting a function, or adding a missing test. Quick wins build momentum.
6. **Budget, don't sprint**: Sustainable debt repayment means a consistent allocation (e.g., 20% of sprint capacity), not a heroic "cleanup sprint" followed by months of new debt accumulation.

## Anti-patterns to flag
- "Rewrite everything" as a debt strategy (almost always wrong)
- Cleanup sprints with no follow-up (debt reaccumulates immediately)
- Tracking debt without prioritizing it (a list without a plan)
- Prioritizing by engineering preference rather than business impact
- Ignoring testing debt (flaky/missing tests slow everything)
- Treating all debt as equal severity

## Quality bar
- Debt items are categorized by type (code, architecture, testing, infra, docs)
- Each item has: description, cost-of-delay estimate, blast radius, remediation effort
- Items are prioritized by cost-of-delay and compounding risk, not aesthetics
- Connection to roadmap: which upcoming work is blocked or slowed by which debt
- Repayment plan includes timeline, resource allocation, and success metrics
- Quick wins are identified separately (high value, low effort)

## Workflow context
- Typically follows: Team retrospectives, performance issues, difficult feature implementations
- Feeds into: `/ticket-breakdown` (debt repayment tickets), `/design-doc` (architectural changes)
- Related: `/performance-review` (performance-related debt), `/security-review` (security-related debt)

## Output
Fill `templates/tech-debt-assessment.md`.

## Learning & Memory
After completing this skill, store reusable insights in memory:
- **Tech debt categories**: Recurring debt patterns by type (code, architecture, testing, infra, docs) and their typical indicators in codebases
- **Cost-of-delay patterns**: Observed relationships between debt items and team velocity, including compounding debt that worsened over time
- **Repayment strategies**: Effective remediation approaches, budget allocation ratios, and quick-win identification heuristics that delivered results

## Output contract
```yaml
produces:
  - type: "assessment"
    format: "markdown"
    path: "claudedocs/<feature>-tech-debt-assessment.md"
    sections: [inventory, prioritization, cost_of_delay, roadmap]
    handoff: "Write claudedocs/handoff-tech-debt-assessment-<timestamp>.yaml — suggest: ticket-breakdown, design-doc"
```
