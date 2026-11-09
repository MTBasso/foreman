# Changelog

All notable changes to this plugin are documented here. Dates are when the
change was merged to `main`.

## 0.6.2 — 2026-11-09

Closed a real bypass of the "never edit code" rule, plus some cleanup:

- **Guardrail now covers `Bash`, not just Write/Edit/NotebookEdit.** The
  orchestrator is explicitly allowed to run `Bash` for spot-checks, so
  nothing stopped it from editing code through the shell (`sed -i`, `tee`,
  `cat > file <<EOF`, `patch`, `dd`) while `.orchestrator-active` was set —
  the exact thing the marker exists to prevent. `hooks.json`'s matcher now
  includes `Bash`, and `block-edit-during-orchestrator.sh` denies a `Bash`
  call whose command looks like a file write, with the same kind of
  exceptions as before (`.foreman/`, `FOREMAN_MEMORY.md`, `/dev/null`, and
  now `.log`/`.out`/`.txt` so redirecting a spot-check's output to a log
  file still works). This is a heuristic, not a sandbox — see the new
  "Known limits" section in `references/orchestrator-marker.md` for what it
  deliberately doesn't try to catch (e.g. `mv`/`cp` onto a source file).
- De-duplicated the marker/`.gitignore`/stale-marker instructions that were
  copy-pasted across `foreman` and `plan-runner`'s `SKILL.md` into a new
  shared `references/orchestrator-marker.md`.
- `/foreman-status` now reports the marker's age (minutes since created),
  not just whether it exists — makes a leftover marker from a crashed
  session easier to recognize at a glance.

## 0.6.1 — 2026-11-09

Stale-marker fix, reported as "new sessions keep getting edits blocked":

- `hooks/session-start.sh` now reads the `SessionStart` event's `source`
  field. If `.orchestrator-active` is already present on a `startup` or
  `clear` (both begin with zero memory of ever running `/foreman`), the
  session has no way to know it's a leftover from a previous session that
  crashed or was closed without running `rm -f .orchestrator-active` — it
  now surfaces that explicitly in `additionalContext` and is told to
  confirm with the user before relying on it, instead of the guardrail
  hook silently denying edits with no explanation in sight. `compact` is
  left alone, since that case can still be a legitimately ongoing run.
- `foreman` and `plan-runner` now also add `.orchestrator-active` to the
  project's `.gitignore` the first time they create it — it's session-local
  bookkeeping and should never be committed or carried between clones.

## 0.6.0 — 2026-11-05

Adopted patterns surveyed from `anthropics/skills` and `obra/superpowers`:

- **Guardrail fix**: the `.orchestrator-active` hook was blocking
  Write/Edit/NotebookEdit for delegated sub-agents too, not just the
  orchestrator itself — it now checks the hook's `agent_id` field (present
  when a hook fires inside a sub-agent) and only denies the orchestrator's
  own direct calls.
- **Isolated workspaces**: `foreman` and `plan-runner` now offer to set up
  a git worktree before marking orchestrator mode active (detect existing
  isolation → native tool → `git worktree` fallback → work in place if
  declined) — see `references/using-worktrees.md`.
- **Per-run ledger**: `plan-runner` keeps `.foreman/plan-runner/<plan-slug>/
  progress.md` on disk, read first on resume and appended to after every
  step — conversation memory doesn't survive compaction, and a lost-place
  session re-dispatching an already-merged step was the costliest failure
  mode worth guarding against.
- **"Rulings, not stalls"**: `foreman`, `plan-runner`, and
  `plan-step-builder` now decide and log minor ambiguities instead of
  stopping the run — only four things still stop for the user (an
  irreversible/destructive op, a security-sensitive action, a side effect
  outside the worktree like a push/shared-branch merge, or a request/plan
  too broken to guess at).
- **Code review discipline**: new `references/code-review-discipline.md`
  splits requesting a review (real SHAs, isolated context) from receiving
  one (verify before implementing, push back with reasoning instead of
  performative agreement) — wired into `foreman`, `qa`, `qa-bugfix`,
  `release-manager`, and `plan-step-builder`. `release-manager` now
  requests a review of the whole accumulated diff before packaging if
  nothing already covered it.
- **New `/foreman-diagnose` command**: reads the ledger, `FOREMAN_MEMORY.md`,
  git history, and status lines to diagnose a past orchestrated run that
  went wrong (repeated work, an ignored plan, a stall, unexpected cost) —
  read-only, every finding cited to evidence. See
  `references/diagnosing-a-run.md`.
- **Decision diagrams**: `foreman` and `plan-runner` gained `dot`-notation
  flowcharts for "which flow applies here" and "sequential vs. parallel
  wave dispatch", instead of prose-only decision rules.
- **New `SessionStart` hook** (`hooks/session-start.sh`): a short reminder
  on startup/clear/compact that this plugin and its entry points exist,
  without activating orchestrator mode on its own.

## 0.5.0 — 2026-11-05

Independent verification, for work done unattended or in parallel:

- `foreman` now spot-checks a delegate's claims before relaying them or
  handing off to `release-manager` — independently re-runs at least one
  check the delegate reported (test/build/lint, via Bash) instead of
  trusting a self-reported "all green." The guardrail only blocks Write/
  Edit/NotebookEdit, so foreman running read-only verification itself was
  already possible, just not previously instructed.
- Formalized parallel delegation (previously sequential-only): independent
  items with no file-scope overlap can be spawned in parallel, but only
  after confirming that from the plan, and `foreman` runs `git diff --stat`
  over the combined changes afterward to catch a file two delegates both
  claimed, rather than trusting each wave's individual report.
- `release-manager` checks for cross-wave file overlap when the handoff
  flags waves that ran in parallel; `templates/release-handoff-prompt.md`
  now records which waves ran in parallel with which.

## 0.4.1 — 2026-11-05

Token-efficiency pass, no behavior change:

- Trimmed oversized frontmatter descriptions (`plan-runner` 634→~140 chars,
  `foreman` 514→~190, plus `qa`/`codebase-auditor`/`release-manager`/
  `qa-bugfix`) — these are loaded in every session regardless of use.
  Always-on cost: ~1,513 → ~1,097 tokens per session (-27%).
- Shortened the working-discipline block's wording across all agents
  (same six rules, less prose) — paid once per delegation, so this adds up
  across a multi-agent wave. Kept the block inlined in each agent rather
  than a shared reference file: subagents start with no context, and a
  cross-file read trades a small, certain cost for a real risk the agent
  skips it — not worth it for rules this safety-relevant.
- Extracted `foreman`'s rare-path sections (optional-dependency install,
  guardrail-denial troubleshooting) into `references/*.md`, read only when
  actually needed instead of every single invocation. `foreman` on-invoke:
  ~4.2k → ~3.7k tokens.

## 0.4.0 — 2026-11-04

- `frontend-dev`, `qa`, and `codebase-auditor` now back up anything visual
  with a real preview instead of a text description: real screenshots (and,
  for `codebase-auditor`'s proposed directions, an example built with the
  project's own styling library) in a self-contained HTML page under
  `.foreman/previews/*.html`.
- `foreman` now reads any preview path a delegate names and publishes it
  with the Artifact tool before relaying their report — sub-agents can't
  call that tool themselves, only the orchestrating session can.
- `qa` gained the `Write` tool, needed to write its preview pages.

## 0.3.0 — 2026-11-04

- Added `agents/codebase-auditor.md`: reviews existing UI and older code on
  request (new `/foreman-audit [area]` command, or just asking `foreman` for
  a review/recommendations) — not tied to building a specific feature. Uses
  the same 10-dimension visual-quality rubric and anti-slop checklist as
  `qa`/`frontend-dev`, plus a lighter pass for stale dependencies and
  deprecated patterns. Writes `FOREMAN_AUDIT.md`; never fixes anything
  itself — findings become normal feature/bug requests if acted on.
- `foreman`'s step 1.5 now routes an audit/review request to this agent
  directly instead of running it through grilling/planning/building.

## 0.2.0 — 2026-11-04

- **Quality upgrades to `planner`, `frontend-dev`, `qa`, `qa-bugfix`**,
  adapting specific, scoped ideas from [ECC](https://github.com/affaan-m/ECC)
  (credited in README Acknowledgments):
  - `planner` now writes a structured plan (file/action/why/risk per step,
    a testing strategy, phasing for large features, a red-flags self-check)
    instead of a loose step list.
  - `frontend-dev` sets an explicit design direction (purpose/audience/tone/
    states) before coding and checks its own work against a generic
    "AI-slop" pattern list.
  - `qa` scores visual changes on a 10-dimension rubric and runs a
    lightweight security checklist (secrets, SQLi, XSS, missing auth) on
    backend work touching input/auth.
  - `qa-bugfix` will not satisfy a failing check by weakening, skipping, or
    deleting it — the fix has to be in the code.
- **AgentShield integration**: `release-manager` now runs a security scan
  (`agentshield scan --path .`) over the repo before packaging a release —
  a found secret or unsafe hook/MCP/permission config blocks shipping.
- Added a language-matching rule to `foreman`/`plan-runner`: always respond
  in the user's language, translate a delegate's report when relaying it.
- `foreman` now splits a multi-item request into one delegation per item
  (each with its own `[PENDING]`/`[DONE]` line) instead of bundling several
  distinct pieces of work into one silent agent run.
- Added `LICENSE` (MIT).
- Fixed a real bug in every eval case: `prompt.md`/`graders/*.md` need YAML
  frontmatter that none of them had, so `claude plugin eval .` silently
  failed to load any case since the suite was first written. Added two more
  cases (`prefers-edit-over-bash`, `release-manager-stays-in-session`).
- Added `examples/sandbox` (a guided first run on a disposable project) and
  a Troubleshooting section to both READMEs.

## 0.1.0 — 2026-10-25

Initial release, moved out of a personal dotfiles repo into its own.

- `tech-lead` renamed to `foreman` throughout (skill, commands,
  `FOREMAN_MEMORY.md`); `release-manager` changed from a separate
  orchestrator session to a sub-agent `foreman` spawns directly.
- Core skills: `foreman`, `plan-runner`, `design-preview`, `project-memory`.
- Core agents: `planner`, `frontend-dev`, `backend-dev`, `qa`, `qa-bugfix`,
  `plan-step-builder`, `release-manager`.
- The `.orchestrator-active` guardrail hook (denies Write/Edit/NotebookEdit
  while any orchestrator skill is active) and a shared working-discipline
  block on every delegate agent (prefer Edit over Bash, self-check before
  reporting done, stop after two failed attempts, don't invent APIs, no
  destructive commands without authorization).
- Optional dependencies: `grill-me`, `improve-codebase-architecture`,
  `writing-for-agents` (Matt Pocock), `impeccable` (Paul Bakaus).
