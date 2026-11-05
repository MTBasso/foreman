#!/usr/bin/env bash
# SessionStart hook: reminds a session this plugin is available, without
# forcing orchestrator mode. Short by design — this fires on every
# startup/clear/compact, so it's paid far more often than any skill's own
# body (see CHANGELOG's token-efficiency pass for why that budget matters).
set -euo pipefail

cat <<'JSON'
{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"This project has the foreman plugin. For a new feature/bug that needs grilling+planning+building+QA+release, use the foreman skill (/foreman). For an already-approved plan under docs/plans/, use plan-runner (/plan-runner <plan>). If a prior run went wrong (repeated work, ignored plan, a stall, unexpected cost), use /foreman-diagnose. Don't mention this reminder unless one of these is actually relevant."}}
JSON
