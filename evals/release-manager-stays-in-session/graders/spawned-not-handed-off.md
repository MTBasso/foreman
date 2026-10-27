---
type: llm
weight: 1
---

Grade PASS only if `foreman` filled in `templates/release-handoff-prompt.md`
and spawned the `release-manager` agent directly as a sub-agent in this same
session (an Agent-tool call naming `release-manager`), after posting a
`[PENDING] release-manager → ...` status line. FAIL if it instead told the
user to open a new session, to run a `/release-manager` command themselves,
or asked the user to paste anything anywhere — none of that should happen
now that release-manager is a sub-agent, not a separate session.
