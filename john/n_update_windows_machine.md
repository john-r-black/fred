# Windows box — mcp-google stdio cleanup

**Context:** On 2026-04-14 (Ubuntu session) we migrated mcp-google from
stdio-only to a Pi-hosted remote connector at `https://google.1421mcps.com`.
The new Custom Connector "Google MCP" auto-syncs to every Claude surface
including Claude Code CLI. The five old stdio entries are no longer needed
and should be removed from the Windows dev box so the tools don't load twice.

The Ubuntu side was already cleaned up. This file is a reminder for the
Windows box only.

---

## What to do

1. In any Windows `~/code_projects/fred/.mcp.json` (and check the equivalent
   on Windows — `%USERPROFILE%\code_projects\fred\.mcp.json` or wherever
   your fred clone lives), delete these five blocks:

   - `"google-1421"`
   - `"google-dpumc"`
   - `"google-dpumc-admin"`
   - `"google-dpumc-yt"`
   - `"google-jrb"`

   Each block points at `../mcp-google/index.js` with an `MCP_ACCOUNT` env
   var. All five are safe to delete — the remote connector replaces them.

2. Also check any other `.mcp.json` on the Windows box:
   - `%USERPROFILE%\code_projects\mcp-google\.mcp.json` — OK to leave alone
     if you ever do local stdio dev from that directory. Delete if you want.
   - `%USERPROFILE%\.claude.json` — unlikely to have google entries, but
     search for `MCP_ACCOUNT` just in case.

3. Confirm the **Google MCP** Custom Connector is listed and enabled in
   Claude Desktop on Windows (it should have auto-synced from claude.ai).
   If it's there, you're done.

4. Delete this note: `rm ~/code_projects/fred/john/n_update_windows_machine.md`
   (or ask Claude to do it).

---

## How to verify it worked

Open a fresh Claude Code session from `~/code_projects/fred` on Windows.
The Google tools should still be available — they'll show up as
`jrb_gmail`, `1421_admin`, `dpumc_calendar`, etc. under the "Google MCP"
connector rather than under five separate stdio servers. If you see the
tools, cleanup was successful.

---

## Background (optional reading)

- Migration doc: `~/code_projects/mcp-google/references/2026-04-14_pi-deployment.md`
- Login password for the connector is the same as the three unifi-mcp
  connectors (saved in your password manager under the mcp-ui entry).
- Refresh tokens expire every 7 days because the Google Cloud OAuth project
  is in Testing mode. When tools start returning `invalid_grant`, run the
  re-grant runbook in the migration doc §11 from whichever box has a browser.
