---
description: Show whether tech-lead mode is currently active and print TECH_LEAD_MEMORY.md for this project without opening the file yourself.
allowed-tools: Bash(cat:*), Bash(ls:*)
---

Run, and show the raw output verbatim, no summarizing:

```bash
echo "tech-lead mode active: $([ -f .orchestrator-active ] && echo yes || echo no)"
echo "---"
if [ -f TECH_LEAD_MEMORY.md ]; then cat TECH_LEAD_MEMORY.md; else echo "(no TECH_LEAD_MEMORY.md yet — no decisions recorded for this project)"; fi
```
