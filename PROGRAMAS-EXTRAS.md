# Programas EXTRA — o que o Debian 13 GNOME já traz vs o que este setup instala

> Origem: `pacotes/pacotes.txt` (309 pkgs) auditado contra Debian 13 trixie + task-gnome-desktop.

## Já vem no Debian 13 — REMOVIDOS da lista limpa (não reinstalar)

- Base/sistema (~200): `bash, coreutils, systemd, apt, dpkg, libc*, lib*, locales, grub*, udev, etc`
- GNOME default: `baobab, evince, evolution*, file-roller, gnome-calculator, gnome-calendar, gnome-clocks, gnome-connections, gnome-contacts, gnome-control-center, gnome-disk-utility, gnome-font-viewer, gnome-logs, gnome-system-monitor, gnome-terminal, gnome-text-editor, gnome-tour, gnome-user-docs, nautilus, totem, shotwell, loupe, tecla, yelp, seahorse, gnome-keyring, gvfs*, gdm3, gnome-shell, gnome-settings-daemon`
- Metapacotes: `task-desktop, task-laptop, task-brazilian-portuguese*, tasksel`
- Editores default: `nano, vim-tiny`

## EXTRA real — fica em `pacotes/pacotes-apt-min.txt` (~45 pkgs, sem kitty)

| Programa | Por que APT (sem flatpak viável ou precisa de sistema) |
|---|---|
| `fish, fastfetch, xsel` | workflow mantido; xsel exigido pelo autoscroll `CLEAR_CLIPBOARD` |
| `git, curl, wget, python3-dev/pip/venv, make, gcc, pkg-config` | dev/base |
| `distrobox` | precisa integração host (sem flatpak oficial completo) |
| `gnome-tweaks, dconf-editor, gnome-software-plugin-flatpak, flatpak` | integração GNOME |
| `gparted, synaptic` | precisam root/apt (flatpak do gparted é limitado) |
| `nautilus-python, python3-nautilus, zenity` | extensão “Novo Documento” + diálogos |
| `yaru-theme-*` | tema (sem flatpak) |
| `gstreamer1.0-libav, gstreamer1.0-plugins-ugly` | codecs |
| `firmware-*, intel-microcode` | hardware |
| `libev-dev, libx11-dev, libxi-dev` | build XMousePasteBlock |
| `bind9-dnsutils, netcat-traditional, traceroute, lsof, usbutils, pciutils` | net/sysadmin |

## EXTRA via Flatpak — `pacotes/flatpaks.txt` (4, já flatpak-first)

| Flatpak ID | Substitui | Motivo |
|---|---|---|
| `com.mattjakeman.ExtensionManager` | `gnome-shell-extension-manager_0.6.3-2_amd64.deb` | .deb redundante → remover .deb |
| `io.missioncenter.MissionCenter` | `stacer.deb (21MB)` | Stacer abandonado/parado → MissionCenter nativo GTK4, menos deps |
| `com.usebottles.bottles` | — | só tem flatpak oficial |
| `io.github.realmazharhussain.GdmSettings` | — | só tem flatpak / compilação manual |

`.deb` mantido: `nautilus-extension-any-terminal_0.8.1-1_all.deb` (integração Nautilus, sem flatpak).

## Removidos por decisão

- `kitty` → volta `gnome-terminal` (default Debian) + `fish`. Remover `configs/kitty/`, trocar `Super+T` no dconf, trocar `nautilus-open-any-terminal terminal kitty → gnome-terminal`.
- `plasma-discover-backend-flatpak` → resto de KDE no GNOME, remove.
- `neofetch` → instalado via fonte em `instalar.sh` (dylanaraps, arquivado mas funciona). `fastfetch` já está no apt-min como futuro substituto. `configs/fish/config.fish` + `configs/neofetch/` mantidos.

## Autoscroll (Xorg apenas)

- Debian 13 usa Wayland por padrão. `TWolczanski/linux-autoscroll` só funciona em **Xorg/XWayland**.
- Instalador correto: `scripts/install-autoscroll.sh` (clone → `~/linux-autoscroll` → venv `.autoscroll` → `pip wheel pynput` → `autoscroll_no_icon.py` → `CLEAR_CLIPBOARD=True, TRIGGER_DELAY=0.5` → autostart).
- No GDM escolher “GNOME on Xorg”. Em Wayland o script abre mas não rola — limitação conhecida, não bug do setup.
