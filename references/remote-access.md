# Remote Access Architecture

_Last verified: 2026-04-14_

How John remotes into church and home machines from either location. The goal is to avoid the balcony-stairs trip for ProPresenter setup while not depending on flaky public relay servers.

## TL;DR

- **RustDesk Direct IP Access** on LAN + tunnel, not the public rendezvous server.
- **One-time Windows Firewall rules** via `scripts/setup-rustdesk-firewall.ps1` — scoped to LAN + VPN ranges only, no internet exposure.
- **IPsec site-to-site tunnel** between the church and home UDM Pros carries home → `10.1.10.0/24` traffic directly (policy-based, auto-included via Internal zone membership — see network docs).
- **Pastor2023 (192.168.1.40) is the jump box** for anything the tunnel doesn't directly reach (isolated VLANs, devices without their own remote access).

## Why not the public RustDesk server?

The free `rustdesk.com` rendezvous/relay servers are congested and intermittent. Sessions drop and reset. Renewed Vision's ProPresenter workflow can't tolerate that during service setup. RustDesk Direct IP bypasses the public infrastructure entirely — the two peers connect directly by IP on the LAN (or over the IPsec tunnel from home). Sessions are stable.

**Tradeoff:** RustDesk Direct IP is **unencrypted by design** (the RustDesk devs marked it wontfix — see [issue #3714](https://github.com/rustdesk/rustdesk/issues/3714)). Their stated recommendation is to layer a VPN underneath. For us:
- Intra-church Direct IP sessions ride the local LAN, same trust boundary as any other wired office traffic.
- Home ↔ church Direct IP sessions ride inside the IPsec tunnel, which encrypts at the tunnel layer regardless of what RustDesk does on top.

The red "Direct and Unencrypted" warning in RustDesk is expected and can be ignored for this deployment.

## Per-machine state

| Machine | IP | OS | Firewall rules | RustDesk Direct IP | Notes |
|---|---|---|---|---|---|
| Pastor2023 (office desktop) | 192.168.1.40 | Windows 11 | ✅ via script | ✅ | **NetworkCategory set to Private** (was Public, which silenced all Private-profile rules) |
| Worship PC (sanctuary balcony) | 10.1.10.205 | Windows 11 | ✅ via script (ran as one-liners, script updated to match) | ✅ | Primary target — this is what we stopped climbing stairs for |
| Broadcast PC | 10.1.10.101 | Windows | ✅ via script one-liners | ✅ | Verified Direct from office 2026-04-14 |
| Announcements Mac | 10.1.10.238 | macOS | ⏸ pending | ⏸ pending | Not reachable when we tried 2026-04-14; revisit when device is online |
| 1421home | 192.168.0.213 | Ubuntu 24 | n/a (ufw inactive) | ✅ | Reachable from Pastor2023 over the IPsec tunnel |

## Setup steps for a new Windows machine

1. From an elevated PowerShell: `scripts/setup-rustdesk-firewall.ps1`. The script is idempotent. It creates three rules (TCP/UDP 21118 + ICMPv4 echo), all scoped to `192.168.1.0/24, 10.1.10.0/24, 192.168.0.0/24` and both Private + Domain profiles. It also checks `Get-NetConnectionProfile` and warns if any interface is `Public`.
2. If the warning fires, run:
   ```powershell
   Set-NetConnectionProfile -InterfaceIndex <idx> -NetworkCategory Private
   ```
   and re-verify. This is the single biggest gotcha — the firewall rules are live but do nothing on a Public-classified interface.
3. Open RustDesk → **⋮** → **Settings** → **Security**:
   - Enable **Direct IP Access** (port 21118)
   - Set a **permanent password** (write it down; Direct IP sessions still prompt)
4. Test from another machine by entering the IP into the RustDesk ID field. Session should show **Direct** in the status.

## Setup steps for a new Linux machine

1. Check ufw: `sudo ufw status`. If inactive, no firewall work needed. If active, allow 21118/tcp from `192.168.1.0/24, 10.1.10.0/24, 192.168.0.0/24`.
2. In RustDesk GUI: enable Direct IP Access + set permanent password (same as Windows).

## Setup steps for a new macOS machine (placeholder — pending Announcements Mac)

1. Enable Direct IP Access + permanent password in the RustDesk GUI.
2. macOS Application Firewall typically auto-prompts to allow RustDesk on first run. If not, add it manually under System Settings → Network → Firewall → Options.
3. Test.

## Windows-specific gotchas learned the hard way (2026-04-14)

- **`New-NetFirewallRule ... -Profile Private,Domain` does nothing on a network classified as `Public`.** Windows applies rules based on the interface's active profile, not the remote address. Always check `Get-NetConnectionProfile` first.
- **The built-in "File and Printer Sharing (Echo Request - ICMPv4-In)" rule has `RemoteAddress = LocalSubnet`.** Enabling it doesn't help with pings coming in over the IPsec tunnel, because the source IP isn't on the local subnet. We add a separate custom ICMP rule with explicit LAN+VPN scope instead.
- **RustDesk outbound works even when rules are wrong.** We tested RustDesk from Pastor2023 *to* other machines before realizing Pastor2023's inbound rules were inactive due to the Public profile. Always test in the direction the rules matter for.
- **Windows PowerShell 5.1 multi-line paste is unreliable** (string literals break across line wraps). Prefer single-line commands or store values in variables first (`$scope = "a","b","c"`).

## Tunnel specifics

- Home → church: traffic destined for `192.168.1.0/24` or `10.1.10.0/24` matches the `home-office` tunnel's remote-subnet selector and encrypts over IPsec.
- Church → home: traffic destined for `192.168.0.0/24` or `192.168.3.0/24` matches the `office-home` tunnel's remote-subnet selector.
- **Not routed across the tunnel (intentional):** IOT (VLAN 10), Guest (VLAN 20), Protect (VLAN 30), Access (VLAN 40), Talk (VLAN 50), and the home Black quarantine VLAN (192.168.2.0/24). Isolation is the security model.
- For an emergency path into an isolated church VLAN from home, RustDesk to Pastor2023 and work from there — Pastor2023 lives in the Internal zone, which has Allow All to every other user zone.

## Files

- `scripts/setup-rustdesk-firewall.ps1` — idempotent Windows Firewall rule creator + NetworkCategory check
- `references/2026-04-11_network_church.md` — church network + tunnel details
- `references/2026-04-11_network_home.md` — home network + tunnel details
