# Black Home Network

_Last verified against live UniFi controller: 2026-04-11_

## TL;DR for a new AI

- **Single UDM Pro** (`Dream Machine Pro`, UniFi OS 5.0.16) behind an AT&T fiber ONT. UDM Pro handles routing, NAT, DHCP, DNS, and zone-based firewall.
- **3 VLANs, one flat firewall zone (`Internal`).** All three VLANs are placed in the same zone, so by default they can route freely. The `Black` VLAN (192.168.2.0/24) is explicitly isolated via source-IP block rules — it is the "quarantine" network.
- **Minimal UniFi hardware:** UDM Pro, one USW Lite 8 PoE, and two APs (U6-LR in the living room, Nano HD in the bedroom).
- **Lots of consumer IoT.** ~60 of the ~69 active clients are Alexa/Echo, smart bulbs, fans, switches, the Petkit feeder, Ring doorbell, roborock vacuum, etc. They live on the default VLAN.
- **IPsec site-to-site tunnel to the church UDM Pro is UP** (migrated to zone-based firewall 2026-04-09 to make it work).
- **Pi MCP server** lives on VLAN 3 at `192.168.3.10` (see `pi-infrastructure.md`).
- **MCP access:** `unifi-home` MCP server exposes the same tool surface as the church controller.

## Access & credentials

- UniFi controller: via `unifi-home` MCP (`mcp__unifi-home__*`).
- Site ID: `88f7af54-98f8-306a-a1c7-c9349722b1f6` (default site).
- Separate Ubiquiti account from the church site.

---

## WAN

| Field | Value |
|---|---|
| ISP | AT&T (fiber) |
| UDM Pro WAN IP | `99.122.140.237` |
| DDNS | `dpumc.duckdns.org` |
| Dual-WAN | Internet 1 and Internet 2 both defined on the UDM Pro |

---

## VLANs

| VLAN | Name | Subnet | Gateway | Zone | SSID | Purpose |
|------|------|--------|---------|------|------|---------|
| 1 | Default | 192.168.0.0/24 | 192.168.0.1 | Internal | `Black Family Network` | Everything household: laptops, phones, IoT, smart home |
| 2 | Black | 192.168.2.0/24 | 192.168.2.1 | Internal (blocked by source-IP rules) | `iotnet` | Isolation / quarantine network for untrusted devices |
| 3 | 1421 | 192.168.3.0/24 | 192.168.3.1 | Internal | `1421me` | Work / 1421.me systems, including the Pi MCP server |

### How VLAN isolation actually works here

All three VLANs share the single `Internal` firewall zone, so the zone-based policies alone would let them all talk freely. The UniFi controller instead inserts **source-IP block rules** targeting `192.168.2.0/24` specifically:

- `192.168.2.0/24 → Internal zone`: BLOCK
- `192.168.2.0/24 → Hotspot zone`: BLOCK
- `192.168.2.0/24 → Dmz zone`: BLOCK

The result: devices on the `Black` VLAN can reach the internet but cannot initiate traffic to anything else on the LAN. VLAN 1 and VLAN 3 do *not* have these block rules, so they can route to each other — the Pi on `192.168.3.10` is reachable from the main network.

**Implication for a new AI:** don't assume "different VLAN = different zone = isolated." Here, only VLAN 2 is isolated, and it's done via source-filter rules rather than zones.

---

## Live client snapshot (2026-04-11)

69 active clients total. Rough breakdown:

- **Infrastructure / wired:** UDM Pro, USW Lite 8 PoE, 2 APs, Epson printer, Ring Chime, Living-Room hub, Leak Sensor Hub.
- **Apple devices:** iPads, iPhones, Apple Watches (Misty + John).
- **Alexa ecosystem:** Echo, Echo Dot, Echo Show, Echo Plus in kitchen, living room, dining room, office, bedrooms, garage, attic (10+ units).
- **Smart lighting/switches:** 25+ Inovelli / Kasa / Feit / Sengled / ESP-based switches — every room.
- **Appliances / other IoT:** dishwasher, disposal, thermostat, garage door opener, roborock vacuum, Petkit feeder, Govee Lyra, Aura frame, LG webOS TV, Insignia TV, stereo speakers.
- **Work / infrastructure:** `1421home` (wired, 192.168.0.213), `1421mcp` Pi (wired, **192.168.3.10**).

---

## Firewall zones

The zone structure is minimal — the controller only creates the system zones:

| Zone | Type | Networks |
|---|---|---|
| Internal | system, configurable | Default (VLAN 1), Black (VLAN 2), 1421 (VLAN 3) |
| External | system, fixed | WAN 1, WAN 2 |
| Gateway | system, fixed | UDM Pro itself |
| Vpn | system, fixed | IPsec site-to-site |
| Hotspot | system, configurable | (empty — no guest SSID) |
| Dmz | system, configurable | (empty) |

**Total policies:** 67, essentially all system-generated. Key non-default ones:
- Three `Isolated Networks` BLOCK rules filtering source subnet `192.168.2.0/24` (see VLAN section above).
- Auto-generated IPsec rules in the `Vpn`/`Gateway` chains: `Allow IPsec` (UDP 500/4500), `Allow ESP`, `Allow Neighbor Solicitations/Advertisements`, and `Allow Policy-Based IPsec Site-to-Site VPN` matching source `192.168.1.0/24` (church LAN) to destinations `192.168.0.0/24`, `192.168.2.0/24`, `192.168.3.0/24`.

---

## WiFi (SSIDs)

| SSID | Security | VLAN / Network | Frequencies | Purpose |
|---|---|---|---|---|
| `Black Family Network` | WPA2 Personal | Native (VLAN 1, 192.168.0/24) | 2.4 + 5 GHz | Household |
| `iotnet` | WPA2 Personal | Black (VLAN 2, 192.168.2/24) | 2.4 + 5 GHz | Quarantined IoT |
| `1421me` | WPA2 Personal | 1421 (VLAN 3, 192.168.3/24) | 2.4 + 5 GHz | Work / Pi server |

---

## Physical topology

```
Dream Machine Pro (UDM Pro) — 99.122.140.237 / 192.168.0.1
├─ USW Lite 8 PoE       (192.168.0.190)  — wired closet
│   ├── 1421home        (192.168.0.213, wired)
│   └── 1421mcp (Pi)    (192.168.3.10, wired, tagged VLAN 3)
├─ Living Room AP — U6-LR (192.168.0.71)   — main coverage, 2.4 + 5 + 6 GHz capable
└─ Bedroom AP - Nano HD   (192.168.0.154)  — secondary, rear of house
```

### UniFi devices (live)

| Name | Model | IP | Firmware | Role |
|---|---|---|---|---|
| Dream Machine Pro | UDM Pro | 99.122.140.237 | 5.0.16 | Gateway + switch + controller |
| USW Lite 8 PoE | USW Lite 8 PoE | 192.168.0.190 | 7.4.1 | Access switch |
| Living Room AP | U6 LR | 192.168.0.71 | 6.7.41 | Primary AP |
| Bedroom | Nano HD | 192.168.0.154 | 6.7.41 | Secondary AP |

---

## Site-to-site IPsec VPN (to church UDM Pro)

Policy-based IPsec, status **UP** as of 2026-04-09. Subnet selectors expanded 2026-04-14 to cover the church AV VLAN. See the church doc for tunnel troubleshooting history — both original issues were on this (home) side.

| Field | Home (this site) | Office |
|---|---|---|
| WAN | `99.122.140.237` | `76.143.85.189` |
| LAN advertised (auto from Internal zone) | `192.168.0.0/24`, `192.168.2.0/24`, `192.168.3.0/24` | `192.168.1.0/24`, `10.1.10.0/24` |
| Remote subnets configured in tunnel | `192.168.1.0/24`, `10.1.10.0/24` | `192.168.0.0/24`, `192.168.3.0/24` |
| DDNS | `dpumc.duckdns.org` | `dpumc1.duckdns.org` |
| Remote gateway | `76.143.85.189` (direct IP, debug) | `99.122.140.237` (direct IP, debug) |
| Tunnel name | `home-office` | `office-home` |

**Reachability verified 2026-04-14:** from `1421home` (192.168.0.213) to church VLAN 1 and VLAN 2 hosts (UDM Pro, NVR, Pastor2023, Worship PC) via ICMP and RustDesk Direct IP. See `references/remote-access.md`.

**Note on the Black VLAN (192.168.2.0/24) quarantine:** although `192.168.2.0/24` is technically advertised as a local subnet via Internal zone membership, the source-IP block rules prevent it from initiating outbound traffic toward any other zone (including `Vpn`). In practice, quarantined devices cannot reach the church LAN and should not be expected to — that's the entire point of the quarantine. Do not try to "fix" this by carving exceptions in the block rules.

**Pending cleanup:** replace both hard-coded remote-gateway IPs with the DDNS hostnames.

**Critical config notes — do not regress:**
- **IDS/IPS must stay off** (or be carefully scoped) on this UDM Pro. Turning IDS/IPS on previously killed the tunnel by flagging IPsec traffic.
- **Zone-based firewall must stay enabled.** The legacy firewall does not auto-generate the `Allow IPsec` / `Allow ESP` / `Allow Policy-Based IPsec VPN` rules. Migrating back to legacy will break the tunnel.
- **Don't bridge the Black VLAN.** See note above.

---

## Related docs in this repo

- `pi-infrastructure.md` — the VLAN 3 Pi (192.168.3.10) that hosts the MCP server
- `2026-04-11_network_church.md` — mirror document for the church side
- `vlan-migration-plan.md` — church-side VLAN migration (not relevant here)

---

## Things a new AI should know before making changes

- **VLAN 2 isolation is source-IP-rule-based, not zone-based.** If you change firewall policies, be sure the three `Isolated Networks` BLOCK rules for `192.168.2.0/24` stay in place.
- **VLAN 1 and VLAN 3 are not isolated from each other.** Anything on `192.168.0/24` can reach the Pi at `192.168.3.10` and vice versa. That's intentional.
- **Most "weird" clients are smart-home devices.** Don't be alarmed by 40+ ESP-based lights / switches / hubs with cryptic MAC-suffix names — they're Inovelli / Kasa / generic ESP8266 lighting, all on VLAN 1.
- **Only 2 APs cover the house.** If WiFi troubleshooting comes up, roaming between Living Room and Bedroom APs is the whole story.
- **Church tunnel relies on this side's config.** Disabling zone-based firewall or turning IDS/IPS back on will silently break remote access from the church.
- **The `unifi-home` MCP is the source of truth.** Use it to verify clients/devices rather than trusting this doc after config changes.
