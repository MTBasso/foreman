#!/usr/bin/env bash
# SessionStart hook: reminds a session this plugin is available, without
# forcing orchestrator mode. Short by design — this fires on every
# startup/clear/compact, so it's paid far more often than any skill's own
# body (see CHANGELOG's token-efficiency pass for why that budget matters).
set -euo pipefail

input="$(cat)"
source_event="$(printf '%s' "$input" | jq -r '.source // ""' 2>/dev/null || true)"

project_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
marker="$project_root/.orchestrator-active"

base_context="This project has the foreman plugin. For a new feature/bug that needs grilling+planning+building+QA+release, use the foreman skill (/foreman). For an already-approved plan under docs/plans/, use plan-runner (/plan-runner <plan>). If a prior run went wrong (repeated work, ignored plan, a stall, unexpected cost), use /foreman-diagnose. Don't mention this reminder unless one of these is actually relevant."

# "startup" and "clear" both begin with zero conversation memory of ever
# running /foreman, so a marker found at that moment is almost always a
# leftover from a session that crashed/ended without `rm -f
# .orchestrator-active` — not a genuinely active orchestrator run. "compact"
# keeps a summary of the conversation, so the marker there can still be
# legitimate; leave it alone rather than second-guessing it.
if [[ -f "$marker" ]] && { [[ "$source_event" == "startup" ]] || [[ "$source_event" == "clear" ]]; }; then
  stale_context=" NOTE: a .orchestrator-active marker already exists at the project root, but this is a brand-new session with no memory of starting foreman mode here — it is very likely a leftover from a previous session that ended without clearing it (crash, interrupt, or the user just closing the terminal). This plugin's guardrail hook will silently deny every Write/Edit/NotebookEdit you attempt while that file exists. Before doing any file edit, confirm with the user whether foreman mode should actually still be active; if not, remove it with \`rm -f .orchestrator-active\`."
  base_context="$base_context$stale_context"
fi

jq -n --arg ctx "$base_context" '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":$ctx}}'
