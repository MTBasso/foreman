---
description: Spawn the codebase-auditor agent to review existing UI/older code and write FOREMAN_AUDIT.md with findings and recommendations. Read-only — nothing gets fixed automatically.
argument-hint: [optional: area to focus on, e.g. "the settings panel"]
---

Create an empty marker file at `.orchestrator-active` in the project root if
it doesn't exist (same guardrail `foreman` uses), then spawn the
`codebase-auditor` agent (from the `foreman` plugin) directly — no grilling,
no plan, this is a read-only review. Scope it to the area below if one was
given, otherwise the whole project. Relay its summary when it reports back,
and point to `FOREMAN_AUDIT.md` for the full report.

$ARGUMENTS
