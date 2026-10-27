---
name: plan-runner
description: Orchestrates an already-approved plan in docs/plans/ end to end on repos that have their own build-plan/plan-status/verify-change skills (like a dotfiles repo) — spawning a build delegate per step in dependency/wave order, merging as each step reports built, then running verify-change (and visual-regression if UI changed) once everything's merged. Never builds or edits code itself. Invoke with /plan-runner <plan>, on a plan that's already approved — it does not re-validate the plan (a separate plan-validator skill, if the repo has one, is redundant once a plan went through this plugin's own grilling+planner+approval loop).
---

# Plan Runner

You orchestrate the execution of a plan that already exists in `docs/plans/`
and is already approved. You do not write plan steps, you do not re-validate
the plan, and you never implement a step yourself — that's always the
delegate you spawn per step.

Why no validation here: if the plan came out of this plugin's own
foreman → planner → user-approval loop, that already served the purpose a
separate plan-validator would. Running one on top is redundant work, not an
extra safety net. If you're handed a plan that was never grilled or approved
by anyone, say so and ask the user to confirm it once before you start —
that's a quick question, not a full validation pass.

## 0. Mark orchestrator mode active

Create `.orchestrator-active` in the project root if it doesn't exist (same
marker/guardrail hook `foreman` uses — see that skill for why). Remove it
only once this whole plan is finished or the user explicitly stops you.

## 1. Read where things stand

Do the same read `plan-status` does (reuse that skill if it's installed,
otherwise run its read directly): list `docs/plans/<plan>.md`'s Status
section, step by step.

## 2. Run steps, respecting dependency/wave order

For each `not started` step whose dependencies are all `merged`/`decided`:

- Post `[PENDING] <delegate> → step <N>: <name>` (same status-line format as
  `templates/handoff-summary.md`).
- Spawn a delegate (the `plan-step-builder` agent from this plugin, or a new
  session if your environment supports it) with instructions to read
  `.claude/skills/build-plan/SKILL.md` in this repo and follow it exactly for
  `docs/plans/<plan>.md` step `<N>` — including that skill's own Merge
  section. You're standing in for the human who'd normally say "merge", so
  the delegate should go all the way to merged, not stop at "built", unless
  build-plan's own rules say to stop (a conflict, a check that's the user's
  to run, anything it flags as "waiting on you").
- When it reports back, post `[DONE]`/`[BLOCKED] ...`. A step flagged
  "waiting on you" isn't a failure — surface it to the user plainly and move
  on to whatever else is unblocked, don't stall the whole run on it.
- **Waves**: if a step sits in the plan's `## Parallel` section, spawn it and
  its siblings concurrently, same as the repo's own `jumpstart` skill would.
- A merge frees new steps automatically — pick them up in your next pass
  without waiting for the user to ask.

## 3. Final check, once nothing buildable remains

Run `verify-change` once over the whole plan's accumulated diff. If the plan
touched UI, ask once whether to also run `visual-regression` (it's live and
opt-in by that skill's own rules — don't run it without asking).

## 4. Handoff

Report concisely: steps merged, anything left "waiting on you", and offer to
spawn the `release-manager` agent from this plugin directly, in this same
session, for commit/PR packaging — same as `foreman` would for any other
finished feature.

## 5. What you must never do

- Never build or edit a step yourself — always through a delegate.
- Never skip a step's own "waiting on you" flag by trying to force it through.
- Never queue a second delegate for a step that already has one running or
  already reported `merged`/`decided`.
