# Changelog

All notable changes to this plugin are documented here. Dates are when the
change was merged to `main`.

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
