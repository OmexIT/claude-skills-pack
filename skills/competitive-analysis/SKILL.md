---
name: competitive-analysis
description: Analyze competitors and market positioning with structured feature comparison, strength/weakness assessment, and strategic differentiation opportunities. Triggers: "competitive analysis", "competitor review", "market landscape", "who else does this".
argument-hint: "[product / market / feature area]"
---

# Competitive analysis

## What I'll do
Produce a structured competitive landscape analysis that identifies key players, compares capabilities, and surfaces differentiation opportunities.

## Inputs I'll use (ask only if missing)
- Your product/feature (what you're comparing)
- Known competitors (or ask me to identify them)
- Focus area: full product, specific feature, pricing, or market segment
- Your current positioning and target customer

## How I'll think about this
1. **Map the landscape first**: Identify direct competitors (same solution, same customer), indirect competitors (different solution, same problem), and potential future competitors (adjacent products expanding).
2. **Compare on dimensions that matter to customers**: Not feature checklists — capabilities that drive buying decisions. Price, time-to-value, integration ecosystem, support quality, and reliability often matter more than features.
3. **Assess honestly**: Your product has weaknesses. Competitors have strengths. An honest analysis is actionable; a biased one is useless.
4. **Find the gaps**: Where are customers underserved by all competitors? That's where differentiation opportunities live.
5. **Consider trajectory, not just current state**: A competitor with worse features but faster shipping velocity, better funding, or a stronger platform play is more threatening than their current product suggests.
6. **Jobs-to-be-done lens**: Competitors aren't just products with similar features — they're anything the customer uses to solve the same problem, including spreadsheets, manual processes, or doing nothing.

## Anti-patterns to flag
- Feature checkbox comparison without context (features aren't equally important)
- Ignoring indirect competitors and substitutes
- Only analyzing current state without considering trajectory
- Assuming your strengths are what customers care about
- "We have no real competitors" (every product competes with the status quo)

## Quality bar
- Landscape includes direct, indirect, and substitute competitors
- Comparison dimensions reflect actual customer buying criteria
- Assessment is honest about your product's weaknesses
- Differentiation opportunities are specific and actionable
- Each competitor profile includes: target customer, key strengths, key weaknesses, trajectory
- Strategic implications are clear (what to build, what to avoid, where to invest)

## Workflow context
- Typically follows: Market research, customer feedback
- Feeds into: `/prd` (informed requirements), `/opportunity-assessment`, `/go-to-market`
- Related: `/experiment-design` (validating differentiation)

## Output
Fill `templates/competitive-analysis.md`.

## Output contract
```yaml
produces:
  - type: "analysis"
    format: "markdown"
    path: "claudedocs/<feature>-competitive-analysis.md"
    sections: [landscape, feature_comparison, strengths_weaknesses, differentiation]
```
