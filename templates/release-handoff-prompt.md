<!--
The foreman skill fills this in once its delegated waves for a feature are
done (planning + building + any QA/bugfix loop), and spawns the
release-manager agent directly with this as its prompt -- same session, no
copy-paste into a new one.
-->

# Release handoff: <feature/change title>

## Waves completed
- <role> — <one-line task> — [DONE|BLOCKED] <outcome>
- <role> — <one-line task> — [DONE|BLOCKED] <outcome>
<!-- one line per delegation, reuse the handoff-summary status lines as-is -->

## Why (from FOREMAN_MEMORY.md)
<paste the relevant decisions-log entries verbatim — the reasoning behind the
stack/pattern choices this release embodies, so commit messages/PR
description can reflect it instead of guessing>

## Known loose ends
<anything flagged as BLOCKED, deferred, or explicitly out of scope — the
release manager should see these before packaging, not discover them>

## Branch / target
<branch name, base branch, whether a PR already exists>
