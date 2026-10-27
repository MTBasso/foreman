---
description: Show whether foreman mode is currently active and print FOREMAN_MEMORY.md for this project without opening the file yourself.
allowed-tools: Bash(cat:*), Bash(ls:*)
---

Run, and show the raw output verbatim, no summarizing:

```bash
echo "foreman mode active: $([ -f .orchestrator-active ] && echo yes || echo no)"
echo "---"
if [ -f FOREMAN_MEMORY.md ]; then cat FOREMAN_MEMORY.md; else echo "(no FOREMAN_MEMORY.md yet — no decisions recorded for this project)"; fi
```
