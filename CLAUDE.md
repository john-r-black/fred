# fred — repo context for Claude

This repo is John's catch-all for church + home ops notes, scripts, and references.

## DPUMC Sunday service setup workflow

End-to-end process for setting up a Sunday worship service across PCO Services, YouTube, and PCO Publishing. Designed to be driven by Claude given a short series/week input document from John. Uses `mcp__pco-dpumc__dpumc_services`, `mcp__pco-dpumc__dpumc_publishing`, and `mcp__google-dpumc-yt__dpumc_yt_youtube`.

**`references/sunday-service-workflow.md`** — read this when John asks you to set up a Sunday service, a sermon series, or a batch of weeks. It lists the required inputs, the per-week execution order, known MCP gotchas discovered during testing, and the default channel/playlist/speaker IDs.

## UniFi consoles

SSH access to the three UniFi consoles (church gateway, church NVR, home gateway) is set up with per-machine ed25519 keys. Full details — IPs, host key fingerprints, mongo rename patterns, what SSH unlocks that the MCPs don't — are in:

**`references/unifi_consoles.md`** — read this before trying to rename clients/devices, dump client histories, or otherwise touch the controller DB directly.

Key file on this machine: `~/.ssh/unifi_ed25519` (no passphrase, used with `ssh -i ... -o IdentitiesOnly=yes root@<console>`).

SSH must be manually enabled in UniFi OS → Console Settings on each console before use, and should be disabled again when done.
