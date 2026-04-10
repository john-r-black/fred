# DPUMC Network Topology

## Overview

Comcast gateway in bridge mode passes public IP directly to the UDM Pro. The UDM Pro handles all routing, NAT, DHCP, and firewall for the entire network.

## WAN

- **Comcast gateway:** Bridge/passthrough mode
- **UDM Pro WAN IP:** Public IP via DHCP from Comcast (76.143.85.189 as of 2026-04-09)

## Networks

### DPUMC Network (VLAN 1 - Default)
- **Subnet:** 192.168.1.0/24
- **Gateway:** 192.168.1.1
- **DHCP range:** 192.168.1.30 - 192.168.1.254
- **DNS:** 1.1.1.1, 8.8.8.8, 9.9.9.9
- **Clients:** 110+ (APs, switches, cameras, workstations, IoT)

### AV Production (VLAN 2)
- **Subnet:** 10.1.10.0/24
- **Gateway:** 10.1.10.1
- **DHCP range:** 10.1.10.200 - 10.1.10.253
- **DNS:** 1.1.1.1, 8.8.8.8, 9.9.9.9
- **Zone:** Same as DPUMC Network (inter-VLAN routing enabled)
- **UDM Pro port:** Port 7 (untagged VLAN 2) → TP-Link TL-SG108E unmanaged switch

#### AV Production Static Assignments

| Device | IP | MAC |
|--------|-----|-----|
| DESKTOP-VSPIT20 | 10.1.10.101 | 04:42:1A:8D:30:F6 |
| birddog-03f83 | 10.1.10.102 | D4:20:00:A0:3F:83 |
| TL-SG108E | 10.1.10.121 | E8:48:B8:71:2B:ED |
| Announcements | 10.1.10.238 | 5C:1B:F4:9F:32:6B |
| (previously offline) | 10.1.10.205 | F0:2F:74:CF:28:D9 |

### IOT (VLAN 10)
- **Subnet:** 192.168.10.0/24
- **Gateway:** 192.168.10.1
- **DHCP range:** 192.168.10.6 - 192.168.10.254
- **DNS:** 8.8.8.8, 1.1.1.1, 9.9.9.9

### Guest (VLAN 20)
- **Subnet:** 192.168.20.0/24
- **Gateway:** 192.168.20.1
- **DHCP range:** 192.168.20.6 - 192.168.20.254

## Notes

- **Comcast admin UI** is no longer accessible in bridge mode. Factory reset required to revert.
- Cutover completed 2026-04-09. Devices retained their IPs with zero reconfiguration.
