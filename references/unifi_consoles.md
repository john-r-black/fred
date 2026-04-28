# UniFi consoles — SSH access and operational notes

Non-secret reference for the three UniFi consoles John manages. The root password is **not** here — auth is by SSH key.

## Consoles

| Console | LAN IP | Role | OS hostname | Network device name |
|---|---|---|---|---|
| Church Gateway | `192.168.1.1` | UDM Pro; Network + Access + Protect + Talk controllers | `DPUMC-Gateway` | `DPUMC-Gateway 3159` |
| Church NVR | `192.168.1.2` | UNVR Pro; Protect recording (standalone from gateway) | `DPUMC-NVR-187C` | `DPUMC-NVR 187C` |
| Home Gateway | `192.168.0.1` | UDM Pro; Network controller | `HomeGateway-DreamMachinePro-65A` | `Dream Machine Pro 65AB` |

> **OS hostname vs Network device name:** the OS hostname (what `hostnamectl` reports) is set on the device itself and is what DHCP clients broadcast. The Network device name is a separate label stored in the Network controller's mongo DB — that's what shows up in the UniFi Network UI. This repo's renaming convention (`ends with the last 4 of the MAC`) applies to the **Network device name**; OS hostnames are left alone.

Reachability: the church and home networks have a site-to-site VPN, so both `192.168.1.0/24` and `192.168.0.0/24` are routable from either machine when the VPN is up.

## Authentication

- SSH **must be enabled** in each console's UniFi OS → Console Settings for key auth to work. It's off by default and sometimes gets auto-disabled by firmware updates; check there first if a session fails to connect.
- Each machine has its own key pair (don't copy private keys between machines):
  - Windows: `~/.ssh/unifi_ed25519` (comment: `claude-windows-<host>-unifi`)
  - Ubuntu home machine: needs a separate `~/.ssh/unifi_ed25519` generated locally, then pubkey deployed to all three consoles once using the current root password.
- `root@` is the SSH user on all three.
- Example:
  ```
  ssh -i ~/.ssh/unifi_ed25519 -o IdentitiesOnly=yes root@192.168.1.1
  ```

### Host key fingerprints (ED25519)

Pin these so `-BatchMode` / `-batch` doesn't prompt:

| Host | Fingerprint |
|---|---|
| `192.168.1.1` | `SHA256:XXPddYkz72iwZsI6Q1yPYGMB98i9Dc1dH+PZsq+NpvU` |
| `192.168.1.2` | `SHA256:hfB9HSeBzZBEcpAnawXtESL5+81ObYkUb4/ijwmBSGQ` |
| `192.168.0.1` | `SHA256:V8TuMbx8bBSW28WsjCl2EnBfy7ZIeojBlv8wwSruxTU` |

If a fingerprint changes, the console was likely reinstalled/reset — verify before trusting.

## What SSH unlocks that the MCPs don't

The UniFi Integration API (what the `unifi-church` / `unifi-home` / `unifi-church-nvr` MCPs wrap) has **no rename endpoint** for network clients or devices, and no NVR rename at all. Direct mongo on the UDM Pro is the only programmatic path for those operations.

### Mongo (UDM Pro) cheat sheet

Network controller DB is `ace`, listening on `127.0.0.1:27117`, no auth required locally.

```
mongo --quiet --port 27117 ace
```

Key collections (scoped to the `default` site):

- `site` — get site id with `db.site.findOne({name:"default"})._id.str`
- `user` — client aliases. Fields: `mac`, `name` (the sticky UI alias — what the Network UI displays), `hostname` (what the device broadcasts; often a `.id.ui.direct` cloud string on UniFi consoles, not changeable from device side), `last_ip`, `fixed_ip`, `last_seen` (unix seconds), `noted` (true when admin has ever touched it).
- `device` — managed UniFi devices (APs, switches, the gateway). Same `name` field.

**Bulk rename pattern:**
```
var s = db.site.findOne({name:"default"})._id.str;
db.user.updateOne({site_id:s, mac:"aa:bb:cc:dd:ee:ff"}, {$set:{name:"New Name"}});
```

**Gotcha:** the Integration API does NOT mirror `user.name` reliably — for UniFi console clients it returns the `hostname`/`direct_connect_domain` cloud string instead, even when a proper alias is set. Dump from mongo, don't trust the MCP, when you need authoritative names.

**Gotcha (port profiles / UDM Pro `port_overrides`):** direct mongo writes to `device.port_overrides` do **not** propagate to the switch ASIC. The Network controller's config-emit pipeline (which writes `/data/udapi-config/udapi-net-cfg-<id>.json`) is only triggered by REST API mutations — restarting `unifi.service`, `udapi-server`, `udapi-bridge`, calling `ubios-udapi-client INTERNAL /internal/sync/cmd "sync_all"`, or `mca-ctrl -t req-inform` will all NOT cause the file to be regenerated. The on-disk config is what the gateway actually applies. So for port profile changes (native VLAN, tagged VLANs, port isolation, PoE mode), use the UniFi UI or the authenticated controller REST API at `https://<console>:443/proxy/network/api/s/default/...` — not direct mongo. Same architectural lesson as DHCP reservations: only fields the controller treats as cosmetic (e.g. `user.name`, `device.name`) survive a direct-mongo edit.

**Before bulk writes**, take a quick backup:
```
mongodump --port 27117 -d ace -o /tmp/ace-backup-$(date +%F)
```

## Managed device SSH (switches, APs, UAH hubs)

Separate from console SSH. Adopted devices inherit SSH credentials from the Network controller's **Device SSH Authentication** (Network app → Devices → gear icon top-right → SSH section). Settings push to every adopted device on the site.

- Church site (`192.168.1.0/24`): username `dpumc`, `~/.ssh/unifi_ed25519` pubkey authorized. BusyBox shell on login.
- Home site (`192.168.0.0/24`): username `1421`, same `~/.ssh/unifi_ed25519` pubkey authorized.
- Example (church): `ssh -i ~/.ssh/unifi_ed25519 dpumc@192.168.1.8` (FLC Pro-24-PoE).
- Example (home): `ssh -i ~/.ssh/unifi_ed25519 1421@192.168.0.190`.
- Useful for: PoE port cycling (`swctrl poe`), port counters (`swctrl port show`), interface stats (`ifconfig`, `cat /proc/net/dev`), inform host (`cat /etc/persistent/cfg/mgmt`).
- Access readers (G3-Flex, UA-Lite, UDA) have no direct SSH — managed through their UAH hub only.

## Protect MCP — what it CAN do

On `unifi-church-nvr`, the Protect MCP *does* support renaming:

- `protect_cameras action=update` with `config={name: "..."}` — cameras
- `protect_devices action=update_viewer|update_light|update_sensor|update_chime` with `config={name: "..."}` — peripherals
- `protect_system action=get_nvr` returns the NVR name but there is **no** `update_nvr` — the NVR name can only be set in the UniFi OS UI.

## Key re-deploy after firmware updates

UniFi OS firmware upgrades sometimes wipe `/root/.ssh/authorized_keys`. If key auth stops working after an upgrade:
1. Re-enable SSH in UniFi OS if it's off
2. Log in once with the root password from a local admin session
3. `echo 'PUBKEY' >> /root/.ssh/authorized_keys; chmod 600 /root/.ssh/authorized_keys`

## Security notes

- Anyone with access to the Windows or Ubuntu user account can become root on all three consoles (private key has no passphrase). This is a deliberate trade-off for unattended automation.
- SSH should be **disabled** in UniFi OS when not actively needed, even with key auth. It's only on when you're actively working.
- The password-based root access exists in parallel and should eventually be disabled once you're confident in key-only auth on both machines.
