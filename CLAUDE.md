# fred — John's operator console

This repo is John's "get stuff done" working directory, not a software project.
It has the broadest MCP access of any of his repos — multiple Google accounts,
multiple PCO orgs, all UniFi consoles, plus Canva, YouTube, and context7 — so
that any question John asks from here can be answered with the best available
tools. Other repos under `~/code_projects/` are project-specific builders;
`fred` is where their output gets *used*.

## How to work in this repo

- Broad MCP access is **intentional**. Don't invent consent-gate rituals
  ("ask before X", "turn Y off between sessions") on John's behalf.
- The safety net is **backups + rollback**, not restricted capability. When
  evaluating an action, ask "is this recoverable?" — not "does John know?"
- This is not a software project. Don't suggest refactors, test suites,
  linters, or CI for notes and reference docs. Edit files when asked;
  otherwise leave them alone.
- Lean on MCPs first, scripts second. Most tasks here are operational
  (calendar, church admin, network, giving, video), not code.

## Repo layout

- `references/` — long-form docs Claude reads on demand. Stable, versioned.
- `john/` — John's scratch notes. See convention below.
- `mcp_issues/` — symlinks to sibling `mcp-*` repos' issue folders. Machine-
  local, gitignored.
- `CLAUDE.md` — this file. Keep it short; it loads on every session.

## First thing every new session

Before responding to John's first message, check `john/` for files matching
`n_*.md`. These are intentionally-named priority notes: open work items,
cross-machine handoffs, or tasks a previous session left for this one. If
any exist, read them and surface what's actionable as part of your first
response. If none exist, say nothing about it and proceed normally.

Files in `john/` **not** matching `n_*.md` are John's personal scratch —
don't read proactively, don't edit unsolicited, don't delete.

When an `n_*.md` file's tasks are all done, offer to delete it; don't
delete silently.

## Workflows Claude executes

### Sunday service setup → `references/sunday-service-workflow.md`
Trigger: John asks to set up a Sunday service, sermon series, or batch of
weeks. The reference doc has required inputs, per-week execution order,
MCP gotchas, and default IDs.

## References Claude reads on demand

### UniFi consoles → `references/unifi_consoles.md`
Trigger: renaming clients or devices, dumping client history, or any task
that needs direct controller DB access. Covers IPs, host-key fingerprints,
mongo rename patterns, and what SSH unlocks that the MCPs don't.

## Finding things not listed here

This file is an index, not an inventory. If you need something and it's not
listed, grep the repo or ask John.
