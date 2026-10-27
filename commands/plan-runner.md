---
description: Turn this session into the plan-runner skill, to run an already-approved docs/plans/ plan end to end without manual session-hopping.
argument-hint: <plan name or path in docs/plans/>
---

Invoke the `plan-runner` skill now (skill name: `plan-runner`, from the
`foreman` plugin). Before doing anything else, create an empty
marker file at `.orchestrator-active` in the project root if it doesn't
exist (same guardrail the `foreman` skill uses), then follow the skill's
instructions for this plan.

$ARGUMENTS
