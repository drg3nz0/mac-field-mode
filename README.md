# field-mode — Mac travel security & battery toolkit

A set of zsh CLI tools for using a MacBook on public / untrusted WiFi.
One command turns your Mac into a **ghost on the network** and squeezes
**maximum battery life** — then restores everything when you get home.

Built and tested on Apple Silicon (M4 Pro, macOS 15+). No dependencies
beyond macOS built-ins (`python3` used only for precise power readings).

```
field-mode on      # arriving at a café / airport
field-mode off     # back home
field-mode status  # full posture
```

---

## What it does

| Direction | Threat | Handled by |
|-----------|--------|:---:|
| **Inbound** | port scans, ping, intrusion, SSH/SMB/VNC | `wifi-shield` |
| **Outbound** | evil-twin, MITM, DNS spoofing, sniffing | your VPN + `net-secure` DoH |

`wifi-shield` blocks inbound and makes the Mac invisible. It does **not**
protect outbound traffic — pair it with a VPN. `field-mode on` refuses to
arm if no VPN is active (default route not via a `utun` tunnel).

---

## Tools

### `field-mode` — the combo
```
field-mode on | off | status | log
```
Arms/disarms `battery-save` + `wifi-shield` together. Checks for an active
VPN before arming.

### `wifi-shield` — ghost mode
```
wifi-shield on | off | status | log
```
On: firewall block-all inbound + stealth mode + kills SSH/SMB/Screen-sharing
+ a `pf` inbound block (stateful, outbound stays open) + AirDrop off + Bonjour
multicast off + connection logging. `wifi-shield log` shows blocked attempts
(historical from `/var/log/appfirewall.log` + live `pf` drops).

Off restores signed-inbound + AirDrop (contacts). Firewall stays **on**;
SSH/SMB/Screen-sharing stay **off** by design.

### `battery-save` — max battery
```
battery-save on | off | status | hogs | startup | startup-off <name> | health | watch | menu
```
Low Power Mode, 60 Hz, sleep tuning, Spotlight/Time Machine pause, cloud-app
suspend, and more. Shows a **before → after** power-draw comparison and a
session summary on `off`. Extras: `health` (cycles/wear), `watch` (live
watts/drain), `startup-off` (disable a login item / LaunchAgent).

### `field-guard` — untrusted-WiFi alerts
```
field-guard install | uninstall | status | trust [ssid] | untrust [ssid] | list
```
A LaunchAgent watches WiFi changes. Join a network that is **not** in your
trusted list → a macOS notification reminds you to run `field-mode on`.
(Full auto-arm needs `sudo`, which a background agent can't provide — so it
alerts instead of arming silently.)

### `net-secure` — encrypted DNS + posture check
```
net-secure dns-on | dns-off | check
```
`dns-on` points the resolver at Cloudflare and generates a DNS-over-HTTPS
configuration profile to install. `check` reports FileVault, SIP, firewall,
VPN, DNS, and remote-login status.

---

## Install

```bash
git clone https://github.com/drg3nz0/mac-field-mode.git
cd mac-field-mode
./install.sh          # symlinks bin/* into ~/.local/bin
```

Make sure `~/.local/bin` is on your `PATH`:
```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
```

### Menu-bar shortcut (optional)
`bin/field-on.command` and `bin/field-off.command` are double-clickable
launchers (add them to the Dock, or wire them into macOS **Shortcuts** and
pin to the menu bar).

---

## How it works (no magic)

- **Firewall / stealth**: `socketfilterfw` (Application Firewall).
- **Inbound block**: a `pf` anchor `block in on en0` + `pass out keep state`.
- **VPN detection**: default route interface is a `utun*` tunnel.
- **Power draw**: `ioreg AppleSmartBattery` InstantAmperage × Voltage.
- All privileged steps use `sudo` and prompt for your password. Nothing runs
  with stored elevated privileges; there is no `NOPASSWD` requirement.

---

## Safety notes

- Every state change is reversible with the matching `off`.
- `field-mode`/`wifi-shield` never touch your data, only network/power settings.
- Read the scripts — they are plain zsh, ~600 lines total, no obfuscation.

## License

MIT © drg3nz0
