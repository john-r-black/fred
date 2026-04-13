# UniFi SSH setup — follow-ups

Follow-ups from the 2026-04-12 session where Claude set up key-based SSH access to the three UniFi consoles.

## 1. Turn SSH back off now

Do this right after the Windows setup session ends. Key auth only works while SSH is enabled, but leaving it on 24/7 is unnecessary exposure.

For each console:
- **DPUMC-Gateway 3159** — https://192.168.1.1 → UniFi OS → Console Settings → SSH → **off**
- **DPUMC-NVR 187C** — https://192.168.1.2 → UniFi OS → Console Settings → SSH → **off**
- **Dream Machine Pro 65AB** (home) — https://192.168.0.1 → UniFi OS → Console Settings → SSH → **off**

Re-enable when you need Claude (or yourself) to do console work, then turn it off again when done.

## 2. Set up SSH key on the Ubuntu home machine

The Windows machine is done. The Ubuntu machine needs its own ed25519 key pair (private keys don't sync across machines — on purpose).

Next time you're on Ubuntu:

1. Pull the latest `fred` repo so `references/unifi_consoles.md` and `CLAUDE.md` are present.
2. Temporarily enable SSH on all three consoles (UniFi OS → Console Settings).
3. Open Claude Code in the `fred` repo and say:
   > set up UniFi SSH on this machine too
4. Have the root password ready — Claude will need it once to deploy the new pubkey to each console's `/root/.ssh/authorized_keys`.
5. After Claude confirms all three consoles accept the new key, **turn SSH off again**.

## 3. Eventually: disable root password SSH

Only after you've confirmed key-only access works from **both** the Windows and Ubuntu machines, disable password login on the consoles (or at least rotate the root password so the one Claude currently knows is invalidated).

How — SSH into each console with your key and edit `/etc/ssh/sshd_config`:
```
PasswordAuthentication no
```
Then `systemctl reload ssh` (or reboot). Do this one console at a time and verify key auth still works before moving to the next, so you don't lock yourself out.

## 4. After firmware upgrades

UniFi OS firmware upgrades sometimes wipe `/root/.ssh/authorized_keys`. If key auth suddenly stops working on a console after an update:

1. Enable SSH again in Console Settings
2. Log in with the root password once
3. Re-append the pubkey to `/root/.ssh/authorized_keys`
4. Or just ask Claude — the Windows machine still has the pubkey at `~/.ssh/unifi_ed25519.pub`

## Reference

- `references/unifi_consoles.md` — full technical reference (IPs, fingerprints, mongo patterns, MCP gotchas)
- `CLAUDE.md` (repo root) — pointer that auto-loads the reference for every Claude session in this repo
