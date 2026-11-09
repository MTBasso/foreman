#!/usr/bin/env bash
# PreToolUse guardrail: while any orchestrator skill from this plugin
# (foreman, plan-runner...) has marked itself active via the
# .orchestrator-active marker it writes/removes at the project root, deny
# Write/Edit/NotebookEdit outright instead of trusting the prompt alone.
# Also covers Bash: the orchestrator is allowed to run Bash freely for
# spot-checks (tests/build/lint), so without this a `sed -i`, `tee`, or
# `cat > file <<EOF` from the orchestrator's own shell would silently edit
# code through the one tool this hook didn't watch.
set -euo pipefail

input="$(cat)"
project_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
marker="$project_root/.orchestrator-active"

# Heuristic: does this shell command look like it writes to a file (as
# opposed to just reading/running things)? Covers redirection (>, >>, not
# counting fd-dup forms like 2>&1 or &>2), sed/perl in-place edit, tee,
# patch, and dd's of=. It's a heuristic, not a parser — a command that
# trips this but is actually fine is the same kind of false positive this
# plugin already documents for Write/Edit (see
# references/guardrail-troubleshooting.md): widen the allowlist below
# rather than working around the hook.
looks_like_write() {
  printf '%s' "$1" | grep -Eq \
    -e '(^|[^0-9>&])>{1,2}[^&>]' \
    -e '\bsed\b[^|;&]*-i\b' \
    -e '\bperl\b[^|;&]*-i\b' \
    -e '\btee\b' \
    -e '(^|[|;&] *)patch\b' \
    -e '\bdd\b[^|;&]*\bof='
}

# Orchestration bookkeeping, not implementation: writing FOREMAN_MEMORY.md,
# anything under .foreman/, discarding output to /dev/null, or redirecting a
# spot-check command's output to a log/report file are all fine without
# having to toggle the marker off and on.
is_allowed_target() {
  printf '%s' "$1" | grep -Eq -e '\.foreman/' -e 'FOREMAN_MEMORY\.md' -e '/dev/null' \
    -e '\.(log|out|txt)([[:space:]]|$)'
}

if [[ -f "$marker" ]]; then
  tool_name="$(printf '%s' "$input" | jq -r '.tool_name // ""')"
  agent_id="$(printf '%s' "$input" | jq -r '.agent_id // ""')"

  # Delegated sub-agents/teammates (hook fires with an agent_id) are exactly
  # who the orchestrator is supposed to hand file edits to — only the
  # orchestrator's own direct calls (no agent_id) need blocking.
  if [[ -n "$agent_id" ]]; then
    echo '{}'
    exit 0
  fi

  if [[ "$tool_name" == "Bash" ]]; then
    command="$(printf '%s' "$input" | jq -r '.tool_input.command // ""')"
    if looks_like_write "$command" && ! is_allowed_target "$command"; then
      cat <<JSON
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"An orchestrator skill is active (.orchestrator-active marker present) and this Bash command looks like it writes to a file (redirection/sed -i/tee/patch/dd). Delegate the change to a sub-agent/session instead of editing it through the shell. If this command is actually read-only/diagnostic and the match is a false positive, widen the allowlist in hooks/block-edit-during-orchestrator.sh rather than finding another way around it."}}
JSON
      exit 0
    fi
    echo '{}'
    exit 0
  fi

  file_path="$(printf '%s' "$input" | jq -r '.tool_input.file_path // ""')"
  if [[ "$(basename -- "$file_path")" == "FOREMAN_MEMORY.md" ]]; then
    echo '{}'
    exit 0
  fi

  cat <<JSON
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"An orchestrator skill is active (.orchestrator-active marker present) and must delegate $tool_name to a sub-agent/session instead of editing files itself. Remove the marker (end orchestrator mode) or delegate this change."}}
JSON
else
  echo '{}'
fi
