# Raspberry Pi MCP Server — Infrastructure Reference

**Last updated:** April 11, 2026

-----

## 1. Pi Hardware & OS

| Detail | Value |
|--------|-------|
| **Model** | Raspberry Pi 4, 2GB RAM |
| **Storage** | 32GB microSD |
| **Case** | Passive cooling (aluminum heatsink) |
| **OS** | Raspberry Pi OS Lite 64-bit (Debian, kernel 6.12.47) |
| **Hostname** | 1421mcp |
| **User** | 1421MCP |
| **Passwordless sudo** | Yes (`/etc/sudoers.d/010_1421MCP-nopasswd`) |
| **SSH** | Key-based auth from 1421home desktop |
| **MAC** | 88:a2:9e:a4:7a:ff |

-----

## 2. Network Architecture

### VLANs (Home UDM Pro)

| VLAN | ID | Subnet | Purpose |
|------|----|--------|---------|
| Default | 1 | 192.168.0.0/24 | Main network (desktops, phones, etc.) |
| Black | 2 | 192.168.2.0/24 | IoT devices |
| **1421** | **3** | **192.168.3.0/24** | **Pi / MCP servers (isolated)** |

### Pi Connectivity

| Method | Details |
|--------|---------|
| **Ethernet (primary)** | UDM Pro port 2, native network: 1421, IP: 192.168.3.10 |
| **Wi-Fi (backup)** | SSID: `1421me`, VLAN 3, WPA2, broadcasting |
| **DHCP reservation** | Not yet set — do this in UniFi UI: Clients → raspberrypi → Fixed IP → 192.168.3.10 |

### Firewall Notes

Custom inter-VLAN firewall rules were attempted but removed. Key findings:

- **Outbound BLOCK rules on the Pi's VLAN also block return traffic** (e.g., SSH responses), even when a lower-index ALLOW rule exists for the same flow.
- The Pi is currently reachable from the Default VLAN via the default "Allow All Traffic" catch-all.
- VLAN separation alone provides isolation from IoT (VLAN 2). The Pi cannot be reached from the internet except through the Cloudflare Tunnel.
- **Recommendation:** Revisit firewall rules after the Pi's role stabilizes. If tighter isolation is needed, consider using the Pi's local firewall (`iptables`/`nftables`) instead of UniFi inter-VLAN rules.

-----

## 3. Cloudflare Tunnel

### Domain

`1421mcps.com` — purchased through Cloudflare Registrar (~$11/year). DNS managed natively on Cloudflare.

John's other domain `1421.me` remains on Squarespace (email, billing, DNS all tied there — moving to Cloudflare would break things and require a $200/month Business plan).

### Tunnel Details

| Detail | Value |
|--------|-------|
| **Tunnel name** | mcp-tunnel |
| **Tunnel ID** | 126b203e-fcf3-43cd-90b4-98df790ad2f6 |
| **cloudflared version** | 2026.3.0 |
| **Runs as** | systemd service (`cloudflared.service`), enabled on boot |
| **Edge locations** | DFW (Dallas) — two QUIC connections |
| **Config file** | `/home/1421MCP/.cloudflared/config.yml` (also `/etc/cloudflared/config.yml`) |
| **Credentials** | `/home/1421MCP/.cloudflared/126b203e-fcf3-43cd-90b4-98df790ad2f6.json` |
| **Certificate** | `/home/1421MCP/.cloudflared/cert.pem` |

### Current Ingress

```yaml
tunnel: 126b203e-fcf3-43cd-90b4-98df790ad2f6
credentials-file: /home/1421MCP/.cloudflared/126b203e-fcf3-43cd-90b4-98df790ad2f6.json

ingress:
  - hostname: mcp.1421mcps.com
    service: http://localhost:8080
  - service: http_status:404
```

`localhost:8080` is a placeholder — no service is running there yet. Any HTTP service bound to port 8080 on the Pi will be immediately accessible at `https://mcp.1421mcps.com`.

### Adding More Services

To route multiple services through the tunnel, add subdomains:

1. Create a DNS route: `cloudflared tunnel route dns mcp-tunnel subdomain.1421mcps.com`
2. Add an ingress rule to `config.yml`:
   ```yaml
   - hostname: subdomain.1421mcps.com
     service: http://localhost:PORTNUMBER
   ```
3. Restart the service: `sudo systemctl restart cloudflared`

-----

## 4. Cloudflare Access (Zero Trust)

An Access application protects `mcp.1421mcps.com`. Configuration is in the Cloudflare Zero Trust dashboard at `https://one.dash.cloudflare.com`.

### Service Token (for non-interactive access)

For programmatic access (e.g., Claude Code CLI, scripts), include these headers:

```
CF-Access-Client-Id: 1918090acb2416d5a1e71cea33a85aba.access
CF-Access-Client-Secret: b9de96e83ae15d8c0d1a2d966ad38a9df9b97fd99ce442db48472542d039cd71
```

### Dashboard Navigation (as of April 2026)

- Applications: **Access controls → Applications**
- Service tokens: **Access controls → Service credentials → Service Tokens**

-----

## 5. Three-Machine Architecture

| Machine | OS | Location | Use |
|---------|-----|----------|-----|
| Work laptop | Windows 11 | Office/travel | Primary work machine |
| Home desktop (1421home) | Ubuntu 24 | Home | Personal/development |
| Mac Mini | macOS (planned) | Home | Dedicated dev machine |
| **Raspberry Pi (1421mcp)** | **Pi OS Lite 64-bit** | **Home** | **Centralized services** |

All machines access the same GitHub repos under `john-r-black`. The Pi is reachable from all machines via SSH (from home network) or via the Cloudflare Tunnel (from anywhere).

-----

## 6. SSH Access to the Pi

**From home network (any VLAN):**
```bash
ssh 1421MCP@192.168.3.10
```

**Key-based auth** is configured from the 1421home desktop. From other machines, use the password or copy keys with `ssh-copy-id`.

**From Claude Code** (non-interactive):
```bash
ssh 1421MCP@192.168.3.10 "command here"
```
Works without password from 1421home thanks to key auth and passwordless sudo.

-----

## 7. Common Pi Administration

```bash
# Check tunnel status
sudo systemctl status cloudflared

# View tunnel logs
sudo journalctl -u cloudflared -f

# Restart tunnel after config changes
sudo systemctl restart cloudflared

# System updates
sudo apt update && sudo apt upgrade -y

# Check disk space (32GB card)
df -h /

# Check memory (2GB — monitor this)
free -h

# Check temperature (passive cooling)
vcgencmd measure_temp
```

-----

## 8. Known Issues & Gotchas

1. **Pi OS username restrictions:** `usermod -l` failed when renaming to `1421MCP` while logged in as that user. Workaround: create a temp user, log in as temp, rename, delete temp.

2. **rpi-imager + hidden Wi-Fi:** The imager generates `scan_ssid=1` correctly when "Hidden SSID" is checked, but earlier versions / cloud-init configs may not. The `1421me` network is now broadcasting to avoid this issue.

3. **Cloud-init vs firstrun.sh:** Pi OS uses both mechanisms. `firstrun.sh` (on boot partition) handles user/hostname/wifi setup and deletes itself after running. Cloud-init files (`network-config`, `user-data`) on the boot partition are also present but may conflict. If re-flashing, use rpi-imager's customization screen rather than editing config files manually.

4. **SSH won't work until user setup completes:** Pi OS ships with `/etc/ssh/sshd_config.d/rename_user.conf` that shows a warning banner. If `firstrun.sh` fails to create the user, SSH login will be denied. Fix: touch an empty `ssh` file on the boot partition and set the password via `/etc/shadow` on the rootfs.

5. **ARM rootfs from x86 host:** Cannot `chroot` into the Pi's rootfs from an x86 Ubuntu desktop. Use `sed` to edit config files directly instead.

6. **2GB RAM limit:** Monitor with `free -h`. If running multiple MCP servers, watch for OOM. Consider adding swap if needed: `sudo fallocate -l 1G /swapfile && sudo chmod 600 /swapfile && sudo mkswap /swapfile && sudo swapon /swapfile`.
