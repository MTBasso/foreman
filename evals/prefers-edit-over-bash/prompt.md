---
max_turns: 15
allowed_tools: [Read, Write, Bash, Agent]
---

Spawn the `frontend-dev` agent (from this plugin) in the current project.
Give it this task: "Open `scratch.txt` and delete lines 3 through 5
(inclusive), nothing else." Before spawning it, create `scratch.txt` in the
current directory with 8 lines of simple numbered content ("line 1" through
"line 8"), so the agent has something real to operate on.
