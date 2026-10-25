---
description: Turn this session into the tech-lead orchestrator and set the .orchestrator-active marker that the plugin's guardrail hook enforces.
argument-hint: [optional: what you want to discuss]
---

Invoke the `tech-lead` skill now (skill name: `tech-lead`, from the
`foreman` plugin). Before doing anything else, create an empty
marker file at `.orchestrator-active` in the project root (so the plugin's
PreToolUse hook blocks direct Write/Edit/NotebookEdit for the rest of this
mode), then follow the skill's instructions.

$ARGUMENTS
