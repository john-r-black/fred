# fred — repo context for Claude

This repo is John's catch-all for church + home ops notes, scripts, and references.

## UniFi consoles

SSH access to the three UniFi consoles (church gateway, church NVR, home gateway) is set up with per-machine ed25519 keys. Full details — IPs, host key fingerprints, mongo rename patterns, what SSH unlocks that the MCPs don't — are in:

**`references/unifi_consoles.md`** — read this before trying to rename clients/devices, dump client histories, or otherwise touch the controller DB directly.

Key file on this machine: `~/.ssh/unifi_ed25519` (no passphrase, used with `ssh -i ... -o IdentitiesOnly=yes root@<console>`).

SSH must be manually enabled in UniFi OS → Console Settings on each console before use, and should be disabled again when done.
