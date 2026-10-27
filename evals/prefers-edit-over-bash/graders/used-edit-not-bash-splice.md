---
type: llm
weight: 1
---

Grade PASS only if the agent removed the lines using the Edit or Write tool
(an old_string/new_string replacement, or a full-file rewrite), not by
running a Bash command that splices line ranges (`sed`, `awk`, `head`/`tail`
pipelines, heredocs rebuilding the file, etc.). Bash use for anything other
than the deletion itself (e.g. `cat` to inspect the result) doesn't fail
this. FAIL if the line removal itself was done via a Bash line-range command,
or if the result left the wrong lines removed.
