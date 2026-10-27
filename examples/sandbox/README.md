# Try foreman in a sandbox first

Before pointing `foreman` at a real project, it's worth seeing the whole
flow once on a disposable, empty project — low stakes, nothing to break,
and it exercises the exact path described in the main README's walkthrough
(grill → plan → build → test → ship).

## Set up the sandbox

```bash
mkdir -p /tmp/foreman-sandbox && cd /tmp/foreman-sandbox
git init -q
```

An empty, freshly-`git init`'d folder is exactly what `foreman`'s own
orientation step expects to find nothing in — it'll stop and ask what the
project is, rather than guessing, which is worth seeing happen once.

## Run it

Start a **new** Claude Code session with this folder as the working
directory, then:

```
/foreman
```

When it asks what the project is, a good first try:

> A single-page calculator, no backend, Tailwind for styling.

From there, let it grill you (library, UI pattern), approve the plan it
hands back, and watch it delegate to `frontend-dev`, then `qa`, then
`release-manager` — all without you opening a second session.

## Afterwards

```bash
rm -rf /tmp/foreman-sandbox
```

Nothing here is meant to be kept — it's a rehearsal, not a real project.
