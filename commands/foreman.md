---
description: Turn this session into the foreman orchestrator and set the .orchestrator-active marker that the plugin's guardrail hook enforces.
argument-hint: [optional: what you want to discuss]
---

Invoke the `foreman` skill now (skill name: `foreman`, from the
`foreman` plugin). Before doing anything else, create an empty
marker file at `.orchestrator-active` in the project root (so the plugin's
PreToolUse hook blocks direct Write/Edit/NotebookEdit for the rest of this
mode), then follow the skill's instructions.

$ARGUMENTS
