#!/usr/bin/env bash
# PreToolUse guardrail: while any orchestrator skill from this plugin
# (tech-lead, plan-runner, release-manager...) has marked itself active via
# the .orchestrator-active marker it writes/removes at the project root,
# deny Write/Edit/NotebookEdit outright instead of trusting the prompt alone.
set -euo pipefail

input="$(cat)"
project_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
marker="$project_root/.orchestrator-active"

if [[ -f "$marker" ]]; then
  tool_name="$(printf '%s' "$input" | jq -r '.tool_name // ""')"
  file_path="$(printf '%s' "$input" | jq -r '.tool_input.file_path // ""')"

  # Orchestration bookkeeping, not implementation: let the orchestrator write
  # its own memory file without having to toggle the marker off and on.
  if [[ "$(basename -- "$file_path")" == "TECH_LEAD_MEMORY.md" ]]; then
    echo '{}'
    exit 0
  fi

  cat <<JSON
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"An orchestrator skill is active (.orchestrator-active marker present) and must delegate $tool_name to a sub-agent/session instead of editing files itself. Remove the marker (end orchestrator mode) or delegate this change."}}
JSON
else
  echo '{}'
fi
