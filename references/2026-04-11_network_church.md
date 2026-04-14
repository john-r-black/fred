# DPUMC Church Network

_Last verified against live UniFi controller: 2026-04-11_

## TL;DR for a new AI

- **Single UDM Pro** (`DPUMC-Gateway`, UniFi OS 5.0.16) behind a Comcast gateway in bridge mode. UDM Pro handles routing, NAT, DHCP, DNS, and zone-based firewall for everything.
- **7 VLANs / 6 firewall zones.** VLAN 1 (DPUMC Network) and VLAN 2 (AV Production) share the `Internal` zone and can route freely between each other. IOT, Protect, Access, Talk are each in their own isolated zone. Guest is in `Hotspot` (captive portal, client isolation).
- **Migration pending:** Protect (cameras), Access (door readers), and Talk (phones) VLANs/zones exist but the physical devices are all still on VLAN 1. See `vlan-migration-plan.md`.
- **Site-to-site IPsec tunnel** to the home UDM Pro is UP as of 2026-04-09.
- **Management convention:** every switch, WAP, and smart PDU has a static IP on VLAN 1 so the UniFi controller can reach them regardless of VLAN changes.
- **MCP access:** the `unifi-church` MCP server exposes read+write tools for everything in this doc. Prefer it over guessing.

## Access & credentials

- UniFi controller: via `unifi-church` MCP (`mcp__unifi-church__*`).
- Site ID: `88f7af54-98f8-306a-a1c7-c9349722b1f6` (default site, name "Default").
- Separate Ubiquiti account from the home site — Magic VPN is not available between them.

---

## WAN

| Field | Value |
|---|---|
| ISP | Comcast Business |
| Upstream | Comcast gateway in **bridge / passthrough** mode |
| UDM Pro WAN IP | `76.143.85.189` (DHCP from Comcast, stable as of 2026-04-09) |
| DDNS | `dpumc1.duckdns.org` |
| Dual-WAN | Internet 1 and Internet 2 both configured on the UDM Pro |

**Gotcha:** the Comcast admin UI is unreachable while the gateway is in bridge mode. A factory reset on the Comcast box is required to revert.

---

## VLANs

All VLANs are terminated on the UDM Pro.

| VLAN | Name | Subnet | Gateway | DHCP range | Zone | Notes |
|------|------|--------|---------|------------|------|-------|
| 1 | DPUMC Network (default) | 192.168.1.0/24 | 192.168.1.1 | .30 – .254 | Internal | All UniFi infra + currently all Protect/Access/Talk devices |
| 2 | AV Production | 10.1.10.0/24 | 10.1.10.1 | .200 – .253 | Internal | Inter-VLAN with VLAN 1 |
| 10 | IOT | 192.168.10.0/24 | 192.168.10.1 | .6 – .254 | IOT | Isolated; `UMC` SSID broadcasts here |
| 20 | Guest | 192.168.20.0/24 | 192.168.20.1 | .6 – .254 | Hotspot | `DPUMC` open SSID, client isolation |
| 30 | Protect | 192.168.30.0/24 | 192.168.30.1 | .6 – .254 | Protect | **Empty** — migration pending |
| 40 | Access | 192.168.40.0/24 | 192.168.40.1 | .6 – .254 | Access | **Empty** — migration pending |
| 50 | Talk | 192.168.50.0/24 | 192.168.50.1 | .6 – .254 | Talk | **Empty** — migration pending |

### DNS servers handed out by DHCP

- VLAN 1 / VLAN 2: `1.1.1.1`, `8.8.8.8`, `9.9.9.9`
- VLAN 10 (IOT): `8.8.8.8`, `1.1.1.1`, `9.9.9.9`

### Current client distribution (live snapshot 2026-04-11)

| Subnet | Active clients |
|---|---|
| 192.168.1.0/24 (VLAN 1) | 112 |
| 192.168.10.0/24 (IOT) | 21 |
| 192.168.20.0/24 (Guest) | 9 |
| 10.1.10.0/24 (AV) | 5 |
| 192.168.30/40/50 | 0 each (pre-migration) |

The high VLAN-1 count reflects Protect/Access/Talk devices not yet migrated.

---

## Firewall zones

Zone-based firewall is enabled (required for the IPsec tunnel auto-rules to work — see "Troubleshooting history" below).

| Zone | Type | Networks |
|---|---|---|
| Internal | system, configurable | DPUMC Network (VLAN 1), AV Production (VLAN 2) |
| Hotspot | system, configurable | Guest (VLAN 20) |
| IOT | user-defined | IOT (VLAN 10) |
| Protect | user-defined | Protect (VLAN 30) |
| Access | user-defined | Access (VLAN 40) |
| Talk | user-defined | Talk (VLAN 50) |
| External | system, fixed | WAN 1, WAN 2 |
| Gateway | system, fixed | UDM Pro itself |
| Vpn | system, fixed | Site-to-site IPsec |
| Dmz | system, configurable | (unused) |

**Policy model:** 94 policies in total, mostly auto-generated. The effective rules are:
- `Internal` ↔ `Internal` is open (lets VLAN 1 and VLAN 2 talk).
- `Internal` → every other user zone: explicit `Allow All` (management from VLAN 1 still works after migration).
- Each isolated zone → `Internal`: blocked except return traffic.
- Isolated zones cannot talk to each other.
- `Vpn` zone has auto-generated rules for IKE (UDP 500/4500) and ESP triggered by the site-to-site tunnel.

---

## WiFi (SSIDs)

| SSID | Security | VLAN / Network | Frequencies | Purpose |
|---|---|---|---|---|
| `DPU` | WPA2/WPA3 Personal | Native (VLAN 1) | 2.4 + 5 GHz | Staff / primary |
| `MWS` | WPA2/WPA3 Personal | Native (VLAN 1) | 2.4 + 5 GHz | Preschool staff |
| `UMC` | WPA2/WPA3 Personal | IOT (VLAN 10) | 2.4 + 5 GHz | IoT / church devices |
| `DPUMC` | Open + Hotspot | Guest (VLAN 20) | 2.4 + 5 GHz | Public guest, captive portal |

---

## Physical topology

All UniFi infrastructure is statically addressed on VLAN 1. Inter-switch uplinks auto-trunk all VLANs.

```
DPUMC-Gateway (UDM Pro) — 192.168.1.1  (UniFi OS 5.0.16)
├─ [SFP+ 10G] Admin - Pro-48-PoE (192.168.1.3) — Office area, core distribution
│   ├── MWS - Pro-24-PoE   (192.168.1.4)  — Preschool
│   ├── MWS - Flex Mini    (192.168.1.5)  — Preschool secondary
│   ├── East - Pro-24-PoE  (192.168.1.6)  — East end, main building
│   ├── Pastor - Lite-8-PoE (192.168.1.7) — Pastor's office
│   └── FLC - Lite 16 PoE  (192.168.1.9)  — Family Life Center
│       └── FLC - Pro-24-PoE (192.168.1.8) — FLC secondary
├─ [RJ45]  Staging - US 24 PoE 250W (192.168.1.10)
│          — Undeployed devices / firmware-update bench
└─ [Port 7, untagged VLAN 2] TL-SG108E (10.1.10.121)
                             — AV Production (unmanaged TP-Link)
```

### Switches (live)

| Name | Model | IP | Firmware | Role |
|---|---|---|---|---|
| Admin - Pro-48-PoE | USW Pro 48 PoE | 192.168.1.3 | 7.4.1 | Core |
| MWS - Pro-24-PoE | USW Pro 24 PoE | 192.168.1.4 | 7.4.1 | Preschool |
| MWS - Flex Mini | USW Flex Mini | 192.168.1.5 | 2.1.6 | Preschool 2nd |
| East - Pro-24-PoE | USW Pro 24 PoE | 192.168.1.6 | 7.4.1 | East end |
| Pastor - Lite-8-PoE | USW Lite 8 PoE | 192.168.1.7 | 7.4.1 | Pastor's office |
| FLC - Pro-24-PoE | USW Pro 24 PoE | 192.168.1.8 | 7.4.1 | FLC 2nd |
| FLC - Lite 16 PoE | USW Lite 16 PoE | 192.168.1.9 | 7.4.1 | FLC primary |
| Staging - US 24 PoE 250W | US 24 PoE 250W | 192.168.1.10 | 7.4.1 | Staging bench |

### Access points

| Name | Model | IP | Firmware |
|---|---|---|---|
| WiFi FLC | AC HD | 192.168.1.11 | 6.8.2 |
| WiFi Admin | Nano HD | 192.168.1.12 | 6.7.41 |
| WiFi Front | UK Ultra | 192.168.1.13 | 6.8.2 |
| WiFi MWS | U6 Pro | 192.168.1.14 | 6.8.2 |
| WiFi Children | UK Ultra | 192.168.1.15 | 6.8.2 |
| WiFi Concourse | AC HD | 192.168.1.16 | 6.8.2 |
| WiFi East | Nano HD | 192.168.1.17 | 6.7.41 |
| WiFi Sanctuary | AC HD | 192.168.1.18 | 6.8.2 |
| WiFi Choir | Nano HD | 192.168.1.19 | 6.7.41 |
| WiFi FP | Nano HD | 192.168.1.20 | 6.7.41 |
| WiFi Sign | AC LR | 192.168.1.22 | 6.8.2 |

### Smart power strips (UniFi USP)

| Name | IP |
|---|---|
| Admin Power Strip | 192.168.1.29 |
| FLC Power Strip | 192.168.1.26 |
| MWS Power Strip | 192.168.1.27 |
| East Power Strip | 192.168.1.28 |

### AV Production static leases (VLAN 2)

| Device | IP | MAC |
|---|---|---|
| Broadcast PC | 10.1.10.101 | 04:42:1A:8D:30:F6 |
| Concourse BirdDog | 10.1.10.102 | D4:20:00:A0:3F:83 |
| TL-SG108E | 10.1.10.121 | E8:48:B8:71:2B:ED |
| Worship PC | 10.1.10.205 | F0:2F:74:CF:28:D9 |
| Announcements Mac | 10.1.10.238 | 5C:1B:F4:9F:32:6B |
| (unidentified) | 10.1.10.240 | E4:77:D4:08:B9:E2 |

---

## Unmigrated device inventory (still on VLAN 1)

These are the devices that will eventually move to their dedicated zones. Counts and physical layout come from the pre-existing migration plan; verify against `vlan-migration-plan.md` before acting.

- **Protect (→ VLAN 30):** ~27 cameras + 2 displays
- **Access (→ VLAN 40):** 12 door hubs + 23 readers
- **Talk (→ VLAN 50):** 17 phones

Migration requires reassigning per-port switch profiles in the UniFi UI because devices are distributed across every location switch. Zones and VLANs already exist so the change is port-by-port, not config-by-config.

---

## Site-to-site IPsec VPN (to home UDM Pro)

Policy-based IPsec, status **UP** and bidirectionally pinging as of 2026-04-09. Subnet selectors expanded 2026-04-14.

| Field | Office (this site) | Home |
|---|---|---|
| WAN | `76.143.85.189` | `99.122.140.237` |
| LAN advertised | `192.168.1.0/24`, `10.1.10.0/24` (VLAN 2 auto-included, see below) | `192.168.0.0/24`, `192.168.3.0/24` (VLAN 3 auto-included) |
| Remote subnets configured in tunnel | `192.168.0.0/24`, `192.168.3.0/24` | `192.168.1.0/24`, `10.1.10.0/24` |
| DDNS | `dpumc1.duckdns.org` | `dpumc.duckdns.org` |
| Remote gateway | `99.122.140.237` (direct IP, debug) | `76.143.85.189` (direct IP, debug) |
| Tunnel name | `office-home` | `home-office` |

**Verified reachable across the tunnel (from `1421home` 192.168.0.213, 2026-04-14):**
- `192.168.1.1`, `192.168.1.2` (UDM + NVR) — ICMP and HTTPS
- `192.168.1.40` (Pastor2023) — ICMP + RustDesk Direct IP 21118 (required fixing Pastor2023's NetworkCategory from Public → Private and adding a non-LocalSubnet-scoped ICMP allow rule)
- `10.1.10.205` (Worship PC) — ICMP + RustDesk Direct IP 21118

**UniFi gotcha — local subnet auto-inclusion:** on a Policy-Based IPsec tunnel in UniFi Network 9.x/UniFi OS 5.x, the tunnel edit panel does **not** expose a "Local Networks" field. The local-side SA selectors are auto-derived from every network in the same firewall zone as the tunnel's configured LAN. Since VLAN 1 and VLAN 2 both live in the `Internal` zone, `10.1.10.0/24` is automatically included as a local subnet with no UI action. Confirmed empirically 2026-04-14 after adding `10.1.10.0/24` to home's remote-subnets list — traffic immediately began routing. Ubiquiti's docs do not describe this behavior; do not trust this without re-testing if the zone model ever changes.

**Pending cleanup:** swap both remote-gateway fields from hard-coded IPs to the DDNS names now that the tunnel is stable.

### Troubleshooting history (2026-04-09)

Two things blocked the tunnel initially:
1. **IDS/IPS on the home UDM Pro** was flagging/blocking IPsec traffic. Disabled to resolve.
2. **Home UDM Pro was still on the legacy firewall** — zone-based firewall wasn't enabled, so the IPsec auto-allow rules (`Allow IPsec`, `Allow ESP`, `Allow Policy-Based IPsec VPN`) were never generated. Migrating home to zone-based firewall created them automatically.

---

## Things a new AI should know before making changes

- **Never rely on `192.168.1.x` being VLAN 1 forever** — management IPs are deliberately static on VLAN 1 but could move. Query `network_devices` for ground truth.
- **Do not touch the Internet ↔ Internal "Allow Policy-Based IPsec Site-to-Site VPN" rules** unless you are reworking the tunnel; they are how the tunnel stays up.
- **Migration plan exists in `vlan-migration-plan.md`.** When moving a Protect/Access/Talk device, change the switch port profile — do not reconfigure the device itself, UniFi will reassign the IP.
- **Staging switch (192.168.1.10)** is the firmware-update bench. New/returned devices land here before deployment.
- **Cutover completed 2026-04-09** (Comcast → bridged → UDM Pro WAN). Devices kept their IPs — no reconfiguration was needed — so any doc older than that date may still describe the legacy router topology.
- **Use the `unifi-church` MCP** for verification. The firewall policy list alone is ~140 KB of JSON; request specific actions/filters rather than full dumps.
- **No subnet overlap with home** (home uses `192.168.0/2/3.0/24`, church uses `192.168.1/10/20/30/40/50.0/24` + `10.1.10.0/24`) — safe to route across the tunnel without NAT.
- **IPsec tunnel local subnets are auto-derived from zone membership, not a UI field.** See the VPN section above. Adding a new VLAN to the `Internal` zone implicitly makes it routable over the site-to-site tunnel. Conversely, moving a VLAN out of `Internal` will silently remove it from tunnel reachability.
- **Isolated zones (IOT, Guest, Protect, Access, Talk) are deliberately not bridged across the tunnel.** From home, manage devices on those VLANs via the UniFi controller web UI / MCPs at `192.168.1.1`, which aggregates them. Direct network access to isolated devices is via the Pastor2023 jump-box pattern (VLAN 1 has Allow All to every user zone).
- **Remote access is RustDesk Direct IP**, not the public rendezvous server. See `references/remote-access.md` for the per-machine setup and the Windows Firewall / NetworkCategory gotchas.
