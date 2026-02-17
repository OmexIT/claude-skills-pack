---
name: experiment-design
description: Design an experiment (A/B test) or staged rollout for a product change: hypothesis, metrics, guardrails, segments, exposure, duration, instrumentation, and decision rule. Triggers: "A/B test", "experiment", "feature flag rollout", "measure impact".
argument-hint: "[feature]"
---

# Experiment design

## What I'll produce
An experiment plan that's implementable by engineering and interpretable by product/data.

## Inputs I'll use (ask only if missing)
- Hypothesis (expected direction and why)
- Primary metric (one) and guardrails
- Target population and exclusions
- Rollout constraints (time, risk appetite)

## How I'll think about this
1. **One primary metric**: If you can't pick one, the experiment isn't focused enough. Secondary metrics are for monitoring, not decision-making.
2. **Hypothesis must be falsifiable**: "We think X will improve Y because Z" — if Z is wrong, the hypothesis fails. Vague hypotheses ("users will like it") can't be tested.
3. **Guardrails protect the business**: Define what must NOT get worse (error rates, latency, support volume, revenue). An experiment that improves signups but tanks revenue is a failure.
4. **Statistical rigor matters**: Consider sample size requirements. How many users/events do you need to detect a meaningful effect? Running an experiment for too short a time or with too small a sample leads to noise, not signal.
5. **Segment analysis upfront**: Decide which segments to analyze before the experiment runs (new vs returning, mobile vs desktop, plan tier). Post-hoc segmentation invites p-hacking.
6. **Clear decision rules**: Define in advance what "ship" vs "iterate" vs "revert" looks like. Don't wait until results are in to decide what counts as success.

## Anti-patterns to flag
- No guardrail metrics (only measuring the upside)
- Running too short / too small to detect the expected effect size
- Changing the primary metric after seeing results
- Post-hoc segmentation to find a "winning" cohort
- No rollback plan if the experiment causes harm
- "We'll figure out the metrics later" (instrument before shipping)

## Quality bar
- Hypothesis follows "If X, then Y, because Z" format
- Primary metric has a clear definition and data source
- Guardrails are defined with acceptable thresholds
- Sample size and duration reasoning is included (even if approximate)
- Decision rule is defined before the experiment starts
- Instrumentation checklist is concrete (specific events, properties, dashboards)

## Workflow context
- Typically follows: `/prd`, `/design-doc`
- Feeds into: `/ticket-breakdown` (instrumentation tickets), `/release-notes`
- Related: `/metrics-review` (data quality), `/monitoring-plan` (dashboards)

## Output
Fill `templates/experiment-plan.md`.
