---
description: Show whether foreman mode is currently active and print FOREMAN_MEMORY.md for this project without opening the file yourself.
allowed-tools: Bash(cat:*), Bash(ls:*), Bash(stat:*), Bash(date:*)
---

Run, and show the raw output verbatim, no summarizing:

```bash
if [ -f .orchestrator-active ]; then
  mtime=$(stat -c %Y .orchestrator-active 2>/dev/null || stat -f %m .orchestrator-active 2>/dev/null)
  now=$(date +%s)
  if [ -n "$mtime" ]; then
    age_min=$(( (now - mtime) / 60 ))
    echo "foreman mode active: yes (marker created ${age_min}m ago — if that's older than this conversation, it may be a leftover from a previous session; see references/orchestrator-marker.md)"
  else
    echo "foreman mode active: yes"
  fi
else
  echo "foreman mode active: no"
fi
echo "---"
if [ -f FOREMAN_MEMORY.md ]; then cat FOREMAN_MEMORY.md; else echo "(no FOREMAN_MEMORY.md yet — no decisions recorded for this project)"; fi
```
