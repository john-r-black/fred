# DPUMC Network Topology

## Overview

Comcast gateway in bridge mode passes public IP directly to the UDM Pro. The UDM Pro handles all routing, NAT, DHCP, and firewall for the entire network.

## WAN

- **Comcast gateway:** Bridge/passthrough mode
- **UDM Pro WAN IP:** Public IP via DHCP from Comcast (76.143.85.189 as of 2026-04-09)
- **Dual WAN:** Internet 1 and Internet 2 configured

## Networks / VLANs

| VLAN | Name | Subnet | Gateway | DHCP Range | Zone |
|------|------|--------|---------|------------|------|
| 1 | DPUMC Network (default) | 192.168.1.0/24 | 192.168.1.1 | .30 - .254 | Internal |
| 2 | AV Production | 10.1.10.0/24 | 10.1.10.1 | .200 - .253 | Internal |
| 10 | IOT | 192.168.10.0/24 | 192.168.10.1 | .6 - .254 | IOT |
| 20 | Guest | 192.168.20.0/24 | 192.168.20.1 | .6 - .254 | Hotspot |
| 30 | Protect | 192.168.30.0/24 | 192.168.30.1 | .6 - .254 | Protect |
| 40 | Access | 192.168.40.0/24 | 192.168.40.1 | .6 - .254 | Access |
| 50 | Talk | 192.168.50.0/24 | 192.168.50.1 | .6 - .254 | Talk |

### Zone Isolation

- **Internal:** DPUMC Network + AV Production (inter-VLAN routing enabled between these two)
- **IOT, Protect, Access, Talk:** Each in its own zone, isolated from all other zones
- **Hotspot:** System-defined zone with client isolation and captive portal support

### DNS

- DPUMC Network / AV Production: 1.1.1.1, 8.8.8.8, 9.9.9.9
- IOT: 8.8.8.8, 1.1.1.1, 9.9.9.9

### AV Production Static Assignments

| Device | IP | MAC |
|--------|-----|-----|
| DESKTOP-VSPIT20 | 10.1.10.101 | 04:42:1A:8D:30:F6 |
| birddog-03f83 | 10.1.10.102 | D4:20:00:A0:3F:83 |
| TL-SG108E | 10.1.10.121 | E8:48:B8:71:2B:ED |
| Announcements | 10.1.10.238 | 5C:1B:F4:9F:32:6B |
| (previously offline) | 10.1.10.205 | F0:2F:74:CF:28:D9 |

## Switch Topology

All switches, WAPs, and smart power strips have static IPs on the DPUMC Network (VLAN 1). Uplinks between managed UniFi switches automatically trunk all VLANs.

```
DPUMC-Gateway (UDM Pro) — 192.168.1.1
├─ [SFP+ 10G] Admin - Pro-48-PoE (192.168.1.3) — Office area, core distribution
│   ├── MWS - Pro-24-PoE (192.168.1.4) — Preschool
│   ├── MWS - Flex Mini (192.168.1.5) — Preschool (2nd switch)
│   ├── East - Pro-24-PoE (192.168.1.6) — East end, main building
│   ├── Pastor - Lite-8-PoE (192.168.1.7) — Pastor's office
│   └── FLC - Lite 16 PoE (192.168.1.9) — Family Life Center
│       └── FLC - Pro-24-PoE (192.168.1.8) — Family Life Center (2nd switch)
├─ [RJ45] Staging - US 24 PoE 250W (192.168.1.10) — Undeployed devices for firmware updates
└─ [Port 7, untagged VLAN 2] TP-Link TL-SG108E (10.1.10.121) — AV Production (unmanaged)
```

### WiFi Access Points

| Name | Model | IP |
|------|-------|----|
| WiFi FLC | AC HD | 192.168.1.11 |
| WiFi Admin | Nano HD | 192.168.1.12 |
| WiFi Front | UK Ultra | 192.168.1.13 |
| WiFi MWS | U6 Pro | 192.168.1.14 |
| WiFi Children | UK Ultra | 192.168.1.15 |
| WiFi Concourse | AC HD | 192.168.1.16 |
| WiFi East | Nano HD | 192.168.1.17 |
| WiFi Sanctuary | AC HD | 192.168.1.18 |
| WiFi Choir | Nano HD | 192.168.1.19 |
| WiFi FP | Nano HD | 192.168.1.20 |
| WiFi Sign | AC LR | 192.168.1.22 |

### Smart Power Strips

| Name | IP |
|------|----|
| FLC Power Strip | 192.168.1.26 |
| MWS Power Strip | 192.168.1.27 |
| East Power Strip | 192.168.1.28 |
| Admin Power Strip | 192.168.1.29 |

## Device Migration Status

Protect (27 cameras, 2 displays), Access (12 hubs, 23 readers), and Talk (17 phones) are currently all on the DPUMC Network (VLAN 1). VLANs and zones have been created but devices have not been migrated yet. Migration requires reassigning switch port profiles per-device via the UniFi UI since devices are distributed across all location switches.

## Site-to-Site VPN (In Progress)

IPsec policy-based VPN between home and office UDM Pros. Different Ubiquiti accounts so Magic VPN is not an option.

### Home UDMPRO
- **WAN:** 99.122.140.237
- **LAN:** 192.168.0.0/24
- **DDNS:** dpumc.duckdns.org
- **VPN Remote Gateway:** 76.143.85.189 (using IP while debugging, switch to dpumc1.duckdns.org once working)
- **VPN Remote Networks:** 192.168.1.0/24

### Office UDMPRO
- **WAN:** 76.143.85.189
- **LAN:** 192.168.1.0/24
- **DDNS:** dpumc1.duckdns.org
- **VPN Remote Gateway:** 99.122.140.237 (using IP while debugging, switch to dpumc.duckdns.org once working)
- **VPN Remote Networks:** 192.168.0.0/24

### Current Status (2026-04-09)
- **Tunnel is UP — bidirectional pings confirmed**
- Both sides configured with matching pre-shared keys, policy-based IPsec
- Both sides running zone-based firewall with auto-generated IPsec allow rules
- Next step: switch VPN remote gateways from direct IPs to DDNS hostnames

### Troubleshooting History (2026-04-09)
Two issues blocked the tunnel:
1. **IDS/IPS on home UDM Pro** — was flagging/blocking IPsec traffic. Disabled to resolve.
2. **Home UDM Pro was on legacy firewall** — zone-based firewall was not enabled, so the IPsec allow rules (Allow IPsec, Allow ESP, Allow Policy-Based IPsec VPN) were never generated. Migrated to zone-based firewall, which auto-created the needed rules.

## Notes

- **Comcast admin UI** is no longer accessible in bridge mode. Factory reset required to revert.
- Cutover completed 2026-04-09. Devices retained their IPs with zero reconfiguration.
- No subnet conflicts between home and church networks. Home uses 192.168.0/2/3.0/24, church uses 192.168.1/10/20/30/40/50.0/24 and 10.1.10.0/24.
