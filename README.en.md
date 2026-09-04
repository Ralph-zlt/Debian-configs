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

bash instalar.sh     # 2nd - Flatpak apps + 309 APT pkgs + 3 .deb + GNOME extensions + ~/.local
# → Logout/login for extensions to load

bash configs.sh      # 3rd - 8GB swap, dconf, Fish/Kitty, XMousePasteBlock, GTK middle-click block
# → Full reboot

# 3. Done! Environment ready.
```

**What each script does:**

| Script | Responsibility | Restart needed? |
|--------|----------------|-----------------|
| `flatpak.sh` | Installs `flatpak`, `gnome-software-plugin-flatpak`, adds Flathub, `flatpak update` | **Yes** (logout/login) |
| `instalar.sh` | Flatpak apps (4), 309 APT packages, 3 `.deb`, 10 GNOME extensions, restores `~/.local` | **Yes** (logout/login for extensions) |
| `configs.sh` | 8GB swap, dconf (GNOME), Fish/Kitty defaults, XMousePasteBlock, GTK middle-click block | **Yes** (full reboot) |

> ⚠️ **Important**: Order is mandatory. `flatpak.sh` sets up infrastructure used by `instalar.sh`. `configs.sh` applies configs depending on installed packages.

---

## 📦 What's Included

| Category | Details |
|----------|---------|
| **Scripts** | `instalar.sh`, `configs.sh`, `flatpak.sh` — idempotent, safe, `set -e` |
| **APT (309 pkgs)** | `pacotes/pacotes.txt` — dev tools (git, python3, docker), GNOME apps, firmware, fish, kitty, neofetch, stacer, etc. |
| **Flatpak (4)** | `pacotes/flatpaks.txt` — ExtensionManager, Bottles, GdmSettings, MissionCenter |
| **`.deb` (3)** | Extension Manager, Nautilus Open Any Terminal, Stacer |
| **GNOME Extensions (10)** | `extensoes/` + `local/share/gnome-shell/extensions/` — tilingshell, dash-to-panel, astra-monitor, arcmenu, clipboard-indicator, lockkeys, user-theme, blur-my-shell, quick-settings-tweaks, gnome-fuzzy-app-search |
| **dconf** | `gnome/dconf.ini` — keybindings (Super+T=kitty, Super+G=browser), Yaru-purple-dark theme, middle-click paste disabled, appfolders, notifications |
| **Dotfiles** | `configs/fish/` (welcome + neofetch), `configs/kitty/` (splits Ctrl+Shift+D/Enter), `configs/neofetch/`, `configs/stacer/` |
| **Autoscroll (optional)** | `.desktop` in `configs/autostart/` and `local/share/applications/` — point to `$HOME/linux-autoscroll/` (Python script **not included**, each user adds their own) |

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

- **Zero secrets** in repository: private keys, KDE Connect/GSConnect certificates, cookies, browser history, LAN IPs, usernames — **removed**
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