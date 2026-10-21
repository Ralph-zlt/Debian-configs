![Debian](https://img.shields.io/badge/Debian-13_(Trixie)-A80030?logo=debian&logoColor=white)
![GNOME](https://img.shields.io/badge/GNOME-48-000000?logo=gnome&logoColor=white)
![Shell](https://img.shields.io/badge/Shell-Bash-4EAA25?logo=gnu-bash&logoColor=white)
![License](https://img.shields.io/badge/License-GPL_v3-blue)
![Status](https://img.shields.io/badge/Status-Active-brightgreen)
![Language](https://img.shields.io/badge/Language-EN-blue)

[🇧🇷 **Versão em Português**](README.md)

---

# Debian-configs (RDEB)

> **Complete, reproducible Debian 13 (Trixie) GNOME setup** — built for productivity, job market readiness, and technical portfolio.

A collection of scripts, dotfiles, and automations that turn a clean Debian install into a ready-to-use development/station environment in **minutes**, not hours.

---

## 🎯 Purpose

| For whom | Why |
|----------|-----|
| **Devs / Sysadmins / Students** | Fast onboarding on new machines, reproducibility, versioned personal infrastructure |
| **Technical portfolio** | Demonstrates: Bash automation, dotfiles management, GNOME/Flatpak/APT ecosystem, dconf, extensions |
| **Teams** | Standardized base for Debian/GNOME workstations |

---

## 🚀 Quick Start

```bash
# 1. Clone the repository
git clone https://github.com/Ralph-zlt/Debian-configs.git
cd Debian-configs

# 2. Run scripts IN ORDER (each may need session restart):
bash flatpak.sh      # 1st - Installs Flatpak + configures Flathub
# → Logout/login (or reboot) for Flatpak to work fully

bash instalar.sh     # 2nd - Flatpak apps + 45 APT pkgs + 1 .deb + GNOME extensions + ~/.local
# → Logout/login for extensions to load

bash configs.sh      # 3rd - dconf, Fish, XMousePasteBlock, GTK middle-click block
# → Full reboot

# 4. (Optional) Windows-style autoscroll
bash scripts/install-autoscroll.sh
# → Logout and log into "GNOME on Xorg" (Wayland not supported)

# 5. Done! Environment ready.
```

**What each script does:**

| Script | Responsibility | Restart needed? |
|--------|----------------|-----------------|
| `flatpak.sh` | Installs `flatpak`, `gnome-software-plugin-flatpak`, adds Flathub, `flatpak update` | **Yes** (logout/login) |
| `instalar.sh` | Flatpak apps (3), 45 APT packages, 1 `.deb`, 11 GNOME extensions, restores `~/.local` | **Yes** (logout/login for extensions) |
| `configs.sh` | dconf (GNOME), Fish as default shell, XMousePasteBlock, GTK middle-click block | **Yes** (full reboot) |
| `scripts/install-autoscroll.sh` | Windows-style autoscroll (icon, Xorg only) | **Yes** (logout + Xorg session) |

> ⚠️ **Important**: Order is mandatory. `flatpak.sh` sets up infrastructure used by `instalar.sh`. `configs.sh` applies configs depending on installed packages.

---

## 📦 What's Included

| Category | Details |
|----------|---------|
| **Scripts** | `instalar.sh`, `configs.sh`, `flatpak.sh`, `scripts/install-autoscroll.sh` — idempotent, safe, `set -e` |
| **APT (45 pkgs)** | `pacotes/pacotes.txt` — dev tools (git, python3, distrobox+podman), firmware, fish, fastfetch, **tilix (default terminal)**, gnome-tweaks, dconf-editor, gparted, synaptic, Yaru themes, codecs, drivers, AppImage (libfuse2t64 + fuse3) |
| **Flatpak (3)** | `pacotes/flatpaks.txt` — ExtensionManager, Bottles, GdmSettings |
| **`.deb` (1)** | Nautilus Open Any Terminal (integration "Open terminal here") |
| **GNOME Extensions (11)** | `extensoes/` + `local/share/gnome-shell/extensions/` — tilingshell, dash-to-panel, astra-monitor, arcmenu, clipboard-indicator, lockkeys, user-theme, gsconnect, quick-settings-tweaks, gnome-fuzzy-app-search, rounded-window-corners |
| **dconf** | `gnome/dconf.ini` — keybindings (Ctrl+Alt+T=Tilix, Ctrl+Alt+G=Firefox, Ctrl+Alt+N=files), Yaru-bark-dark theme (Yaru-dark icons), middle-click paste disabled, appfolders, notifications, 11 extensions enabled |
| **Dotfiles** | `configs/fish/` (welcome + fastfetch), `configs/fastfetch/` (`config.jsonc` with Linux logo + custom colors) |
| **Autoscroll** | `scripts/install-autoscroll.sh` — installs icon version (PyQt5), autostart configured. **Requires "GNOME on Xorg" session** |

---

## 🛠️ Customization

```bash
# Add/remove APT packages
vim pacotes/pacotes.txt

# Add/remove Flatpaks
vim pacotes/flatpaks.txt

# Drop your own .deb files in pacotes/
cp my-package.deb pacotes/

# Update dconf after GNOME tweaks
dconf dump / > gnome/dconf.ini

# Add GNOME extensions
# Download extension .zip → extract to extensoes/<uuid>/ and local/share/gnome-shell/extensions/<uuid>/
```

---

## ⚙️ Requirements

- Debian 13 (Trixie) with **GNOME** (default)
- Internet connection (APT, Flatpak, Git)
- Working `sudo` (interactive password or `NOPASSWD`)

---

## 🔒 Security

- **Zero secrets** in repository: private keys, certificates, cookies, browser history, LAN IPs, usernames — **removed**
- Paths use `$HOME` — works for any user
- `.gitignore` protects against future leaks
- **GPL v3** license — improvements give back to community

---

## 📄 License

**GPL v3** — see [LICENSE](LICENSE).

```
Copyright (C) 2026 Rafael (Ralph-zlt)
This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.
```

---

## 🤝 Contributing

1. Fork → branch → PR
2. Keep scripts idempotent (`set -e`, existence checks)
3. Document changes in README
4. No secrets in commits (`.gitignore` exists for a reason)

---

## 👤 Author

**Ralph (Ralph-zlt)** — [GitHub](https://github.com/Ralph-zlt)

> *Built to learn, share, and streamline the daily workflow of professionals using Debian/GNOME.*