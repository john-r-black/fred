# File two UniFi MCP bugs hit during 2026-04-16 FLC Gym keypad outage

On 2026-04-16 (Windows session, fred), the FLC Gym keypad went down. The
attempt to power-cycle it via MCP failed twice over — both the Access
`reboot_device` path and the Network `port_action` path. Fallback to SSH
+ `swctrl poe restart` worked. Both failures are reproducible and blocked
real operational work, so they need to be filed as GitHub issues per
`fred/CLAUDE.md` convention.

MCP dev lives on this Ubuntu box only — Windows can't file these with
source context. That's why this is a handoff.

**Important architecture note**: as of the recent migration, the MCPs
run on the Raspberry Pi (`ssh 1421mcp`), not on Ubuntu directly. The
`mcp-*` source repos live under `~/code_projects/` on Ubuntu, but the
*running* MCP processes are on the Pi. Before filing, confirm that the
version deployed to the Pi matches `HEAD` of the relevant repo — if the
Pi is behind, the bug may already be fixed in source.

---

## 1. Identify the backing repos

The failing MCP tool names were:
- `mcp__claude_ai_UniFi_Church__access_doors` (action `reboot_device`)
- `mcp__claude_ai_UniFi_Church__network_devices` (action `port_action`)

Find which `mcp-*` repos back these:

```bash
ls ~/code_projects/ | grep -i mcp
grep -l "access_doors\|reboot_device" ~/code_projects/mcp-*/src 2>/dev/null
grep -l "port_action\|power_cycle" ~/code_projects/mcp-*/src 2>/dev/null
```

Likely candidates based on naming: `mcp-unifi-access` and
`mcp-unifi-network`, but verify — do NOT file against a guess.

## 2. Bug 1 — Access MCP `reboot_device` returns 404 "no-man zone"

**Exact error observed (twice):**

```
Access API 404: {"code":404,"codeS":"CODE_NOT_FOUND","msg":"The API was not found.","error":"you entered no-man zone"}
```

**Repro:** call `access_doors` action=`reboot_device` with a valid
`deviceId`. Tested against two distinct devices on the church site, both
404'd with the same body:

- UA-G3-Flex reader `847848b8d198` (FLC Gym - Entry)
- UAH hub `d021f950bcac` (FLC Gym)

**Why it's not a device-state gate:**
Both devices returned `is_online: true, is_managed: true,
is_adopted: true` from `list_devices`, and both advertised `support_reboot`
in their `capabilities` array. So the MCP rejected this pre-flight or the
controller genuinely doesn't have the endpoint the MCP is calling.

**Environment:** Church UDM Pro firmware **5.0.16**. The UniFi Access UI's
own "Restart" button works on these same devices, so there IS a working
upstream endpoint — the MCP just isn't using it (or is using a path that
got moved in a firmware bump).

**Triage steps before filing:**
1. Read the MCP source for the `reboot_device` branch — confirm the exact
   URL it constructs.
2. Compare to current Access API docs / known-good paths. A likely cause
   is the MCP still targeting an `/api/v1/…` path that Access moved to
   `/api/v2/…` or changed under a different resource root.
3. If source already fixed but Pi is running older build — issue is just
   "deploy to Pi," file as a deploy task rather than a code bug.

**File the issue:**

```bash
gh issue create --repo john-r-black/<confirmed-repo-name> \
  --title "access_doors reboot_device returns 404 \"no-man zone\" on church UDM Pro 5.0.16" \
  --body "$(cat <<'EOF'
## Repro
Call `access_doors` action=`reboot_device` with a valid `deviceId` on church site.

Tested against (both 404'd):
- UA-G3-Flex reader `847848b8d198` (FLC Gym - Entry)
- UAH hub `d021f950bcac` (FLC Gym)

## Exact error
```
Access API 404: {"code":404,"codeS":"CODE_NOT_FOUND","msg":"The API was not found.","error":"you entered no-man zone"}
```

## Environment
- Church UDM Pro firmware 5.0.16
- Both target devices `is_online: true, is_managed: true, is_adopted: true`, `support_reboot` in capabilities
- UniFi Access UI "Restart" button works on the same devices

## Impact
Had to fall back to SSH + `swctrl poe restart` during an actual keypad outage on 2026-04-16. MCP was unusable for the job it's supposed to do.

## Suspected cause
MCP constructs a URL against an Access API path that no longer exists in 5.0.16. Verify the URL the MCP emits vs. what the current controller exposes.
EOF
)"
```

## 3. Bug 2 — Network MCP `port_action` returns opaque "fetch failed"

**Exact error observed (twice in a row):**

```
fetch failed
```

No status code. No body. No URL. No stack.

**Repro:** call `network_devices` action=`port_action`
deviceAction=`power_cycle` on a valid switch with a valid portIdx.
Specifically:
- `deviceId`: `618c6449-55a6-38cc-bb44-ad2d1a702986` (FLC - Pro-24-PoE BDFD)
- `portIdx`: 23

**Why this is worse than bug 1:**
Bug 1 surfaces the upstream's error body, so you can diagnose. This one
swallows everything and leaves you guessing — upstream timeout, malformed
request, auth failure, all indistinguishable. **First fix is
observability, not the underlying bug.**

**Triage steps before filing:**
1. Read the MCP's `port_action` handler. Wrap the `fetch` in try/catch
   that logs: URL, method, headers (redact auth), status, response body.
2. With that logging in place, re-run the same call and capture what
   actually failed.
3. THEN file the bug with real evidence — or split into two issues
   ("port_action error swallowing" + whatever the root cause turns out
   to be).

**File as an issue (observability first):**

```bash
gh issue create --repo john-r-black/<confirmed-repo-name> \
  --title "network_devices port_action swallows all error detail (bare \"fetch failed\")" \
  --body "$(cat <<'EOF'
## Repro
Call `network_devices` action=`port_action` deviceAction=`power_cycle` on church site:
- deviceId: `618c6449-55a6-38cc-bb44-ad2d1a702986` (FLC - Pro-24-PoE BDFD)
- portIdx: 23

## Error
```
fetch failed
```
Nothing else — no status, no body, no URL.

## Impact
During a real outage on 2026-04-16 this path failed twice with zero diagnostic info. Had to fall back to SSH `swctrl poe restart`. Can't even tell whether the MCP, the network, or the controller is broken.

## Fix requested
Wrap the underlying fetch so errors surface the URL, HTTP status, and response body. Once that's in place, the root-cause bug (if any) becomes diagnosable.
EOF
)"
```

## 4. Home-site sanity check (optional but useful before filing)

Both failures were on the `unifi-church` MCP against the church UDM Pro.
If the same calls work on the home site (`unifi-home`), the bug is
probably controller-firmware-version-specific, not MCP-generic. If they
fail identically, it's an MCP-wide bug.

Call the home-site equivalents (`mcp__claude_ai_UniFi_Home__*`) with a
low-impact target (e.g. a switch port where power-cycling a non-critical
device is OK) and note the result in each issue body. Skip if you can't
identify a safe test target.

## 5. After filing

Each target `mcp-*` repo's `CLAUDE.md` runs `gh issue list` at session
start (per fred/CLAUDE.md). Opening that repo in Claude Code will
surface the new issues automatically — no additional handoff needed.

---

**Delete this note when both issues are filed (or explicitly decided
not to file, with reason written into MEMORY.md).**
