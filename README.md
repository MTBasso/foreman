# foreman

A Claude Code plugin of orchestrator skills — `tech-lead`, `plan-runner`,
`release-manager` — that grill features/bugs, run plans, and ship releases by
delegating to dedicated sub-agents. None of them ever edit code or write a
plan themselves, same as a real foreman never swings the hammer.

Its own repository, installable as a standalone Claude Code plugin in any
project.

## Contents

- `skills/tech-lead` — the entry point. Turns the current session into the
  orchestrator described above. Marks itself active via a `.orchestrator-active`
  file at the project root.
- `skills/design-preview` — renders real, library-backed HTML previews of UI
  options so design choices are picked by looking, not reading descriptions.
- `skills/project-memory` — reads/writes `TECH_LEAD_MEMORY.md` in each project,
  so conventions learned on that project persist across sessions.
- `skills/release-manager` — a second orchestrator session, separate from
  tech-lead. Takes the finished waves of a feature (plan + build + QA) and
  turns them into clean commits, a PR description, and a ship/no-ship call.
  Never implements features or fixes bugs itself.
- `skills/plan-runner` — a third orchestrator session, for repos that already
  have their own plan/build-step tooling (e.g. this dotfiles repo's
  `build-plan`/`plan-status`/`verify-change`). Runs an already-approved
  `docs/plans/` plan end to end — spawning a delegate per step in order,
  merging, then verifying — instead of you creating a session and pasting a
  build-plan prompt by hand for every step.
- `agents/planner.md`, `agents/frontend-dev.md`, `agents/backend-dev.md` — the
  dedicated build roles the tech lead delegates to.
- `agents/plan-step-builder.md` — builds and merges one plan step by
  following the target repo's own `build-plan` skill exactly. Spawned by
  `plan-runner`, one per step.
- `agents/qa.md` — proactively runs real UI (e.g. Playwright) and API tests
  against the build, as its own wave after building and before the release
  handoff. Finds problems, never fixes them.
- `agents/qa-bugfix.md` — the reactive counterpart: fixes a specific failure
  handed to it by `qa`, failing CI, or a review comment. Never goes looking
  for problems on its own.
- `commands/tech-lead.md` — `/tech-lead` slash command: fast entry point into
  the skill above.
- `commands/tech-lead-status.md` — `/tech-lead-status`: prints whether
  tech-lead mode is active and the current `TECH_LEAD_MEMORY.md`, without you
  opening the file yourself.
- `commands/release-manager.md` — `/release-manager`: fast entry point into
  the release-manager skill above.
- `commands/plan-runner.md` — `/plan-runner <plan>`: fast entry point into
  the plan-runner skill above.
- `hooks/hooks.json` + `hooks/block-edit-during-orchestrator.sh` — a real
  guardrail shared by every orchestrator skill in this plugin: while
  `.orchestrator-active` exists, a PreToolUse hook denies Write/Edit/
  NotebookEdit outright, so "never touch code" is enforced even if the model
  forgets, not just requested in the prompt.
- `templates/handoff-prompt.md` — the fixed shape of the delegation prompt the
  tech lead hands to planner/frontend-dev/backend-dev/qa-bugfix, so decided
  context gets pasted in directly instead of re-derived by the receiving
  agent.
- `templates/handoff-summary.md` — the fixed `[PENDING]`/`[DONE]`/`[BLOCKED]`
  status-line format posted right before and right after each delegation, so
  you can skim progress without re-reading context each time.
- `templates/release-handoff-prompt.md` — what tech-lead fills in and hands
  to release-manager once a feature's waves are done, so commits/PR
  descriptions reflect the actual reasoning instead of being guessed from
  the diff alone.
- `evals/` — `claude plugin eval .` runs two formalized regression checks: that
  an empty project halts and asks instead of guessing, and that the no-edit
  guardrail actually blocks an edit attempt rather than just being asked to.

## Install (as a local plugin)

From this folder's parent directory:

```
claude plugin marketplace add ./foreman
claude plugin install foreman
```

(Exact subcommands may shift as the Claude Code plugin CLI evolves — check
`claude plugin --help` if these don't match.)

## Optional dependencies

Four skills, from two other marketplaces, that tech-lead leans on when
they're installed and falls back to its own judgment on when they're not —
nothing breaks either way, you just lose that skill's specific approach. As
of step 0.5 above, `tech-lead` installs these itself the first time it runs
if they're missing, instead of making you do it by hand:

```
claude plugin marketplace add mattpocock/skills
claude plugin install grill-me@mattpocock/skills
claude plugin install improve-codebase-architecture@mattpocock/skills
claude plugin install writing-for-agents@mattpocock/skills
claude plugin marketplace add pbakaus/impeccable
# check the exact plugin id with `claude plugin list`, then e.g.:
claude plugin install impeccable@impeccable
```

- `grill-me` — the feature/bug interview (step 2).
- `improve-codebase-architecture` + `writing-for-agents` — run together, but
  only on a pre-existing codebase that actually looks like it needs the audit
  (step 1) — not on every session, and not on a codebase that already looks
  solid.
- `impeccable` (by Paul Bakaus, not Matt Pocock) — audits/fixes generic "AI
  slop" styling. `frontend-dev` runs it on everything it builds; `qa` also
  runs it on older UI that predates this workflow.
