# VLAN Migration Plan — Protect, Access, Talk

**Created:** 2026-04-11
**Status:** Not started

## Overview

Migrate Protect (cameras/NVR/viewports), Access (hubs/readers), and Talk (phones/ATA) devices from DPUMC Network (VLAN 1) to dedicated VLANs with isolated zones.

| VLAN | Name | Subnet | Zone |
|------|------|--------|------|
| 30 | Protect | 192.168.30.0/24 | Protect |
| 40 | Access | 192.168.40.0/24 | Access |
| 50 | Talk | 192.168.50.0/24 | Talk |

## Port Profile Types Needed

1. **Protect** — Native VLAN 30 (untagged). For ports with only Protect devices.
2. **Access** — Native VLAN 40 (untagged). For ports with only Access hubs.
3. **Talk** — Native VLAN 50 (untagged). For ports with only Talk devices.
4. **Data + Voice** — Native VLAN 1 (computer, untagged) + Tagged VLAN 50 (phone). For ports where a computer daisy-chains through a phone.
5. **Protect + Voice** — Native VLAN 30 (viewport, untagged) + Tagged VLAN 50 (phone). For the one port with a viewport and phone sharing a cable.

## Access Reader Note

Access readers connect to Access hubs via the hub's built-in ports, not to network switches. Changing the hub's switch port to VLAN 40 automatically moves all readers connected to that hub. Readers do not have their own switch port entries.

## Migration By Switch

### Admin - Pro-48-PoE (192.168.1.3)

| Port | Device | App | Profile | Notes |
|------|--------|-----|---------|-------|
| 1 | Front Desk - Max FB92 + Front Desk Computer | Talk + Network | **Data + Voice** | Phone passthrough to desktop |
| 2 | 102 - Touch 32D6 | Talk | **Talk** | |
| 3 | Family - Touch 3204 | Talk | **Talk** | |
| 4 | Finance - Touch 3312 + Finance Computer | Talk + Network | **Data + Voice** | Phone passthrough to desktop |
| 15 | Nursery - Flex 61C2 | Talk | **Talk** | |
| 16 | Touch 339C | Talk | **Talk** | Unassigned phone |
| 19 | Touch 3420 | Talk | **Talk** | Unassigned phone |
| 20 | Touch 1617 | Talk | **Talk** | Unassigned phone |
| 43 | Front Interior (UA Hub Door) | Access | **Access** | Readers: Entry (UA Reader Lite), Exit (UA Reader Lite) |
| 47 | Front Exterior (UA Hub) | Access | **Access** | Readers: Entry (UA Pro), Exit (UA Reader Lite) |
| 51 | DPUMC-UNVR | Protect | **Protect** | NVR must be on same VLAN as cameras |

**Ports to change: 11** (5 Talk, 2 Data+Voice, 2 Access, 1 Protect, 1 NVR)

### East - Pro-24-PoE (192.168.1.6)

| Port | Device | App | Profile |  Notes |
|------|--------|-----|---------|--------|
| 3 | East FP | Protect | **Protect** | |
| 4 | Food Pantry - Touch 342C | Talk | **Talk** | |
| 5 | East Concourse | Protect | **Protect** | |
| 7 | East Door (camera) | Protect | **Protect** | |
| 21 | FP Exterior (UA Hub Door) | Access | **Access** | Readers: Entry (UA G2), Exit (UA Reader Lite) |
| 22 | FP Interior (UA Hub Door) | Access | **Access** | Readers: Entry (UA Reader Lite), Exit (UA Reader Lite) |
| 23 | Concourse (UA Hub) | Access | **Access** | Readers: Entry (UA G2), Exit (UA Reader Lite) |
| 24 | East Door (UA Hub) | Access | **Access** | Readers: Entry (UA Pro), Exit (UA Reader Lite) |

**Ports to change: 8** (3 Protect, 1 Talk, 4 Access)

### MWS - Pro-24-PoE (192.168.1.4)

| Port | Device | App | Profile | Notes |
|------|--------|-----|---------|-------|
| 1 | 124-G3-Flex | Protect | **Protect** | |
| 2 | West Kitchen | Protect | **Protect** | |
| 3 | Nursery-G3 Flex | Protect | **Protect** | |
| 4 | MWS-E | Protect | **Protect** | |
| 5 | West Door | Protect | **Protect** | |
| 6 | MWS-N | Protect | **Protect** | |
| 7 | West Concourse | Protect | **Protect** | |
| 8 | MWS-W | Protect | **Protect** | |
| 19 | MWS Front (UA Hub) | Access | **Access** | Readers: Entry (UA Pro), Exit (UA Reader Lite) |
| 22 | MWS Back (UA Hub) | Access | **Access** | Readers: Entry (UA Reader Lite), Exit (UA Reader Lite) |
| 23 | MWS Interior (UA Hub) | Access | **Access** | Readers: Entry (UA Reader Lite), Exit (UA Reader Lite) |

**Ports to change: 11** (8 Protect, 3 Access)

### FLC - Pro-24-PoE (192.168.1.8)

| Port | Device | App | Profile | Notes |
|------|--------|-----|---------|-------|
| 1 | FLC201 - G3 Flex 8B31 | Protect | **Protect** | |
| 2 | FLC201 - Flex 32B0 | Talk | **Talk** | Offline |
| 3 | FLC202 - G3 Flex F9DA | Protect | **Protect** | |
| 4 | FLC202 - Flex 3271 | Talk | **Talk** | Offline |
| 5 | FLC203 - G3 Flex F87B | Protect | **Protect** | |
| 6 | FLC203 - Flex 3242 | Talk | **Talk** | Offline |
| 7 | FLC204 - G3 Flex FF3E | Protect | **Protect** | |
| 8 | FLC205 - Flex B389 | Talk | **Talk** | Offline |
| 9 | FLC205A - G3 Flex 008B | Protect | **Protect** | |
| 10 | FLC204 - Flex 323F | Talk | **Talk** | Offline |
| 11 | FLC205B - G3 Flex 009A | Protect | **Protect** | |
| 13 | FLC2H1 - G3 Flex FECE | Protect | **Protect** | |
| 14 | FLC1H1 - G3 Flex FA94 | Protect | **Protect** | |
| 15 | FLC2H2 - G3 Flex F861 | Protect | **Protect** | |
| 16 | FLC1H2 - G3 Flex FF14 | Protect | **Protect** | |
| 17 | FLC2H3 - G3 Flex F8BA | Protect | **Protect** | |
| 18 | FLC1H3 - G3 Flex 002E | Protect | **Protect** | |
| 22 | FLC Closets (UA Ultra) | Access | **Access** | Standalone reader, no hub |
| 23 | FLC Gym (UA Hub) | Access | **Access** | Readers: Entry (UA G3 Flex B, offline), Exit (UA Reader Lite) |
| 24 | FLC Back (UA Hub) | Access | **Access** | Readers: Entry (UA G2), Exit (UA Reader Lite) |

**Ports to change: 20** (12 Protect, 5 Talk, 3 Access)

### FLC - Lite 16 PoE (192.168.1.9)

| Port | Device | App | Profile | Notes |
|------|--------|-----|---------|-------|
| 8 | CrossOver - Max FDDB + Protect Viewport | Talk + Protect | **Protect + Voice** | Native VLAN 30 (viewport) + Tagged VLAN 50 (phone) |

**Ports to change: 1**

### Pastor - Lite-8-PoE (192.168.1.7)

| Port | Device | App | Profile | Notes |
|------|--------|-----|---------|-------|
| 1 | Pastor - Max 7C33 | Talk | **Talk** | |

**Ports to change: 1**

### MWS - Flex Mini (192.168.1.5)

| Port | Device | App | Profile | Notes |
|------|--------|-----|---------|-------|
| 4 | MWS - ATA 347F | Talk | **Talk** | |

**Ports to change: 1**

### Staging - US 24 PoE 250W (192.168.1.10)

| Port | Device | App | Profile | Notes |
|------|--------|-----|---------|-------|
| 3 | Admin 1 | Protect | **Protect** | Undeployed camera |
| 5 | G3-Flex | Protect | **Protect** | Undeployed camera |
| 7 | Admin 2 | Protect | **Protect** | Undeployed camera |
| 9 | Foyer | Protect | **Protect** | Undeployed camera |
| 11 | Protect Viewport | Protect | **Protect** | Undeployed viewport |

**Ports to change: 5** (all Protect)

## Summary

| Profile | Port Count |
|---------|------------|
| Protect | 27 |
| Access | 12 |
| Talk | 14 |
| Data + Voice | 2 |
| Protect + Voice | 1 |
| **Total ports to change** | **56** |

## Recommended Migration Order

1. **Staging switch first** — 5 undeployed devices, zero risk. Validates that cameras adopt correctly on the new VLAN.
2. **NVR (Admin Port 51)** — Move before deployed cameras so the NVR is ready on VLAN 30 when cameras start arriving.
3. **MWS - Pro-24-PoE** — 8 cameras + 3 Access hubs. Large batch, single switch. Good test of both Protect and Access on new VLANs.
4. **East - Pro-24-PoE** — Mixed (3 Protect, 4 Access, 1 Talk). Tests all three VLANs.
5. **FLC - Pro-24-PoE** — Busiest switch (20 ports). Do this once confident from previous switches.
6. **Admin - Pro-48-PoE** — Phones, Access hubs, and the two Data+Voice dual-VLAN ports. Save the complex port profiles for last.
7. **FLC - Lite 16 PoE** — The Protect+Voice dual-VLAN port.
8. **Pastor and MWS Flex Mini** — One phone each. Trivial.

## Devices Staying on DPUMC Network (VLAN 1)

These wired clients remain on VLAN 1 — no changes needed:

| Device | Switch | Port | IP |
|--------|--------|------|----|
| Front Desk Computer | Admin Pro-48 | 1 (via phone) | 192.168.1.57 |
| Finance Computer | Admin Pro-48 | 4 (via phone) | 192.168.1.241 |
| Sharp 4141N (printer) | Admin Pro-48 | 29 | 192.168.1.21 |
| Thermostat Control Computer | Admin Pro-48 | 33 | 192.168.1.31 |
| Synology 1 | Admin Pro-48 | 25 | 192.168.1.50 |
| Synology 2 | Admin Pro-48 | 23 | 192.168.1.51 |
| Pastor2023 | Pastor Lite-8 | 8 | 192.168.1.40 |
| iPhone 99:d1 | Pastor Lite-8 | 4 | 192.168.1.159 |
| MWS Desktop | MWS Flex Mini | 5 | 192.168.1.107 |
| 85onnRokuTV | DPUMC-Gateway | 3 | 192.168.1.102 |

## AV Production (VLAN 2) — No Changes

| Device | IP |
|--------|----|
| Windows PC 30:f6 | 10.1.10.101 |
| BirdDog | 10.1.10.102 |
| TL-SG108E | 10.1.10.121 |
| Broadcast | 10.1.10.205 |
| Announcements | 10.1.10.238 |

All on DPUMC-Gateway Port 7 via TP-Link unmanaged switch. No changes.

## Pre-Migration Checklist

- [ ] Create port profiles in UniFi UI: Protect, Access, Talk, Data+Voice, Protect+Voice
- [ ] Verify uplink ports between switches are set to "All" (trunk all VLANs) — should be default
- [ ] Schedule maintenance window — devices will briefly disconnect during VLAN change
- [ ] Confirm NVR can reach cameras on VLAN 30 after migration
- [ ] Confirm Access hubs reconnect and readers come online on VLAN 40
- [ ] Confirm Talk phones register and make calls on VLAN 50
- [ ] Test Data+Voice ports — computer stays on VLAN 1, phone on VLAN 50
