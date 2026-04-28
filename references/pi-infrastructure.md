# Raspberry Pi Infrastructure Reference

**Last updated:** 2026-04-27 (Pi swap + ACPC repurpose + VLAN 3 wired migration)

John runs **two** Pi units. Until ACPC moves to the church, both are physically at home on the 1421 VLAN.

-----

## 1. Pi Inventory

| Role | Hardware | Storage | Hostname | UniFi name(s) | Status |
|---|---|---|---|---|---|
| **Production MCP server** | Pi 4B Rev 1.5, **8 GB** | **256 GB USB SSD** (ORICO enclosure, Realtek RTL9201, UAS) | `1421mcp` | `1421mcp 9E62` (eth0) / `1421mcp 9e:64` (wlan0, currently down) | Live, in production |
| **ACPC controller** (AC + door control) | Pi 4B Rev 1.5, 2 GB | Fresh SSD, first-boot Pi OS | `1421acpc` | `1421acpc 7a:ff` | Bootstrapped, en route to church office |

The ACPC Pi *is the same physical hardware* that previously ran production MCPs (MAC `88:a2:9e:a4:7a:ff`); when production moved to the 8GB unit on the SSD, the 2GB unit was repurposed with a new SSD set up for ACPC.

### Production Pi specifics

| Detail | Value |
|--------|-------|
| OS | Raspberry Pi OS Lite 64-bit (Debian, kernel 6.12.75) |
| User | `1421MCP`, passwordless sudo |
| SSH auth | Key-based; alias `1421mcp` in `~/.ssh/config` → `192.168.3.7` |
| eth0 MAC | `2c:cf:67:45:9e:62` |
| wlan0 MAC | `2c:cf:67:45:9e:64` |
| Boot partitions | `/dev/sda1` (vfat) → `/boot/firmware`; `/dev/sda2` (ext4) → `/` (PARTUUID `7c1fbad8-02`) |

### ACPC Pi specifics

| Detail | Value |
|--------|-------|
| OS | Raspberry Pi OS Lite 64-bit (Trixie / Debian 13) |
| User | `acpc`, passwordless sudo, SSH key auth |
| SSH alias | `acpc` in `~/.ssh/config` → `192.168.3.10` (will move when the Pi goes to church) |
| Password (fallback) | `Kagewa41421!` (set during fix; key auth is the normal path) |

ACPC has the long-standing dnsmasq fixed-IP entry for MAC `88:a2:9e:a4:7a:ff` → `.10`, which is why it lands at `192.168.3.10` even on a fresh install.

ACPC application is not running yet — fresh image, no service installed. Only port 22 listening. Once the application is deployed, capture port + service-name details here.

**Trixie userconf gotcha (learned during ACPC bring-up, 2026-04-27):** Pi OS Lite Trixie's `userconf` rejects usernames that don't match `^[a-z][a-z0-9-]*$`. The original reflash script (`/tmp/reflash-pi-acpc.sh`) used `1421MCP` (uppercase + leading digit), which userconf wrote to `failed_userconf.txt` with the message *"Must only contain lower-case letters, digits and hyphens, and must start with a letter."* The user was never created, so the `firstrun.sh` `install -d -o 1421MCP` call failed silently, leaving the Pi with a working hostname but no usable login. Fix script (`/tmp/fix-acpc-user.sh`) created `acpc` directly via rootfs file edits while the SSD was mounted on `1421home`. **For future Trixie+ Pi builds, pick a Trixie-valid username.** The production Pi's `1421MCP` works only because it was created on Bookworm where validation was looser.

-----

## 2. Network Architecture

### Home VLANs (UDM Pro)

| VLAN | ID | Subnet | Purpose |
|------|----|--------|---------|
| Default | 1 | 192.168.0.0/24 | Main household network |
| Black | 2 | 192.168.2.0/24 | IoT quarantine |
| **1421** | **3** | **192.168.3.0/24** | **Pi / MCP / 1421 work systems** |

### Current Pi connectivity

| Pi | Connection | UDM Pro port | IP | Notes |
|---|---|---|---|---|
| Production | Ethernet | **Port 3** (native VLAN reconfigured to 1421 on 2026-04-27) | 192.168.3.7 (DHCP) | wlan0 disabled (`1421me` profile retained, `connection.autoconnect=no`); can be brought up with `sudo nmcli connection up 1421me` if eth0 fails |
| ACPC | Ethernet | Port 2 (already on 1421 VLAN) | 192.168.3.10 (dnsmasq fixed entry) | Temporary — moves to church office |

### How VLAN 3 isolation works (or doesn't)

VLANs 1 and 3 share the `Internal` zone and are **not** isolated from each other — devices on `192.168.0.0/24` can reach the Pis at `.7` and `.10`. Only VLAN 2 (Black/IoT) is isolated, via source-IP block rules. See `2026-04-11_network_home.md` for the full firewall picture.

### UDM Pro port-profile gotcha (learned 2026-04-27)

Direct mongo writes to `device.port_overrides` on the UDM Pro **do not** propagate to the switch ASIC. The Network controller's config-emit pipeline (which writes `/data/udapi-config/udapi-net-cfg-<id>.json`) only triggers on REST API mutations. Use the UI or authenticated controller REST API. Restart of `unifi.service`, `udapi-server`, `udapi-bridge`, `sync_all`, `req-inform` — none of them work. Captured in `unifi_consoles.md`.

-----

## 3. Cloudflare Tunnel

Production Pi runs `cloudflared.service` as the tunnel endpoint. All ingress targets `localhost`, so the Pi's LAN IP can change without affecting the tunnel.

| Detail | Value |
|--------|-------|
| Tunnel name | `mcp-tunnel` |
| Tunnel ID | `126b203e-fcf3-43cd-90b4-98df790ad2f6` |
| Domain | `1421mcps.com` (Cloudflare Registrar) |
| Config | `/etc/cloudflared/config.yml` (also `/home/1421MCP/.cloudflared/config.yml`) |
| Credentials | `/home/1421MCP/.cloudflared/126b203e-fcf3-43cd-90b4-98df790ad2f6.json` |

### Live ingress (10 hostnames)

| Hostname | Local port | Service |
|---|---|---|
| `mcp.1421mcps.com` | 8080 | (placeholder — no current listener) |
| `unifi-home.1421mcps.com` | 8081 | unifi-mcp-home |
| `unifi-church.1421mcps.com` | 8082 | unifi-mcp-church |
| `unifi-church-nvr.1421mcps.com` | 8083 | unifi-mcp-church-nvr |
| `google.1421mcps.com` | 8084 | mcp-google |
| `pco-dpumc.1421mcps.com` | 8085 | mcp-pco-dpumc |
| `pco-hckaty.1421mcps.com` | 8086 | mcp-pco-hckaty |
| `httc.1421mcps.com` | 8087 | mcp-httc |
| `sudoku.1421mcps.com` | 8090 | sd26 (public Sudoku app) |
| `seats.1421mcps.com` | 8091 | ticket-scout |

### Adding more services

1. Route DNS: `cloudflared tunnel route dns mcp-tunnel subdomain.1421mcps.com`
2. Add an `ingress:` rule in `config.yml` pointing at `http://localhost:PORT`
3. `sudo systemctl restart cloudflared`

-----

## 4. Cloudflare Access (Zero Trust)

Access application protects `mcp.1421mcps.com` and the per-app ingress hosts. Configure at `https://one.dash.cloudflare.com`.

### Service token (non-interactive access)

```
CF-Access-Client-Id: 1918090acb2416d5a1e71cea33a85aba.access
CF-Access-Client-Secret: b9de96e83ae15d8c0d1a2d966ad38a9df9b97fd99ce442db48472542d039cd71
```

### Dashboard navigation (April 2026)
- Applications: **Access controls → Applications**
- Service tokens: **Access controls → Service credentials → Service Tokens**

-----

## 5. Running services on the production Pi

Active systemd services (as of 2026-04-27):

| Service | Port | Description |
|---|---|---|
| `cloudflared` | — | Cloudflare tunnel endpoint |
| `unifi-mcp-home` | 8081 | UniFi home console MCP |
| `unifi-mcp-church` | 8082 | UniFi church gateway MCP |
| `unifi-mcp-church-nvr` | 8083 | UniFi church NVR MCP |
| `mcp-google` | 8084 | Google Workspace MCP (5 accounts) |
| `mcp-pco-dpumc` | 8085 | Planning Center Online — DPUMC |
| `mcp-pco-hckaty` | 8086 | Planning Center Online — HCKaty |
| `mcp-httc` | 8087 | Honeywell Total Connect Comfort |
| `sd26` | 8090 | Sudoku puzzle generator (public, no auth) |

Plus a non-systemd-managed gunicorn for `ticket-scout` on 8091 (process supervised some other way — confirm before reboot if availability matters).

Standard mcp-ui deploy:
```bash
ssh 1421mcp 'cd mcp-ui && git pull && npm run build && sudo systemctl restart unifi-mcp-home unifi-mcp-church unifi-mcp-church-nvr'
```

-----

## 6. Three-machine + two-Pi topology

| Machine | OS | Location | Use |
|---|---|---|---|
| Work laptop | Windows 11 | Office / travel | Primary work machine; consumer-only (no `mcp-*` repos) |
| Home desktop (`1421home`) | Ubuntu 24 | Home | Personal / development; MCP dev happens here |
| Mac Mini | macOS (planned) | Home | Dedicated dev machine |
| **Production Pi (`1421mcp`)** | Pi OS Lite 64-bit | Home | Centralized MCP servers + Cloudflare tunnel |
| **ACPC Pi (`1421acpc`)** | Pi OS Lite (fresh) | Home → church office | AC + door control |

All machines share the same GitHub repos under `john-r-black`.

-----

## 7. SSH

```bash
# Production Pi (key auth from 1421home + Windows desktop)
ssh 1421mcp                    # alias → 1421MCP@192.168.3.7

# ACPC Pi (key auth from 1421home; same key as production Pi)
ssh acpc                       # alias → acpc@192.168.3.10
```

-----

## 8. Common Pi administration

```bash
# Tunnel status / logs / restart
sudo systemctl status cloudflared
sudo journalctl -u cloudflared -f
sudo systemctl restart cloudflared

# System updates
sudo apt update && sudo apt upgrade -y

# Disk / memory / temp (8GB RAM, 256GB SSD)
df -h /
free -h
vcgencmd measure_temp
```

-----

## 9. Known issues & gotchas

1. **Pi OS first-boot username:** `firstrun.sh` and cloud-init both run on first boot and can collide. Use rpi-imager's customization screen, not manual config-file edits.
2. **rpi-imager + hidden Wi-Fi:** Earlier imager versions don't set `scan_ssid=1` reliably. The `1421me` SSID broadcasts to dodge this.
3. **SSH banner before user setup completes:** Pi OS shows a "Please note that SSH may not work until a valid user has been set up" banner when no user has been configured. This is `sshd_config.d/rename_user.conf` — the banner displays *before* auth, so seeing it doesn't necessarily mean no user exists. Try authentication regardless.
4. **ARM rootfs from x86 host:** Cannot `chroot` from an x86 Ubuntu desktop into the Pi's rootfs. Edit configs with `sed`.
5. **USB SSD requirements on Pi 4:** SSD must be in a USB 3.0 (blue) port; PSU must be a real 5V/3A USB-C; bootloader EEPROM must be 2021+ for reliable USB boot.
6. **UDM Pro port-profile changes:** must go through the controller UI/API. Direct mongo writes to `device.port_overrides` will not propagate. See `unifi_consoles.md`.
