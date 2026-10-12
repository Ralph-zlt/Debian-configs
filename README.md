![Debian](https://img.shields.io/badge/Debian-13_(Trixie)-A80030?logo=debian&logoColor=white)
![GNOME](https://img.shields.io/badge/GNOME-48-000000?logo=gnome&logoColor=white)
![Shell](https://img.shields.io/badge/Shell-Bash-4EAA25?logo=gnu-bash&logoColor=white)
![License](https://img.shields.io/badge/License-GPL_v3-blue)
![Status](https://img.shields.io/badge/Status-Active-brightgreen)
![Language](https://img.shields.io/badge/Language-PT--BR-green)

[🇺🇸 **English Version**](README.en.md)

---

# Debian-configs (RDEB)

> **Configuração completa e reproduzível do Debian 13 (Trixie) com GNOME** — pensada para produtividade, mercado de trabalho e portfólio técnico.

Um conjunto de scripts, dotfiles e automações que transformam uma instalação limpa do Debian em um ambiente de desenvolvimento pronto para uso em **minutos**, não horas.

---

## 🎯 Objetivo

| Para quem | Por que |
|-----------|---------|
| **Devs / Sysadmins / Estudantes** | Onboarding rápido em máquinas novas, reprodutibilidade, versionamento de infraestrutura pessoal |
| **Portfólio técnico** | Demonstra: automação Bash, gestão de dotfiles, ecossistema GNOME/Flatpak/APT, dconf, extensões |
| **Equipes** | Base padronizada para workstations Debian/GNOME |

---

## 🚀 Início Rápido

```bash
# 1. Clone o repositório
git clone https://github.com/Ralph-zlt/Debian-configs.git
cd Debian-configs

# 2. Execute os scripts EM ORDEM (cada um pode precisar de reinício da sessão):
bash flatpak.sh      # 1º - Instala Flatpak + configura Flathub
# → Faça logout/login (ou reinicie) para o Flatpak funcionar 100%

bash instalar.sh     # 2º - Apps Flatpak + 43 pkgs APT + 1 .deb + extensões GNOME + ~/.local
# → Faça logout/login para extensões carregarem

bash configs.sh      # 3º - dconf, Fish, XMousePasteBlock, GTK middle-click block
# → Reinicie o computador

# 4. (Opcional) Autoscroll estilo Windows
bash scripts/install-autoscroll.sh
# → Faça logout e entre em "GNOME on Xorg" (Wayland não suporta)

# 5. Pronto! Ambiente configurado.
```

**O que cada script faz:**

| Script | Responsabilidade | Reinício necessário? |
|--------|------------------|---------------------|
| `flatpak.sh` | Instala `flatpak`, `gnome-software-plugin-flatpak`, adiciona Flathub, `flatpak update` | **Sim** (logout/login) |
| `instalar.sh` | Apps Flatpak (3), 43 pacotes APT, 1 `.deb`, 11 extensões GNOME, restaura `~/.local` | **Sim** (logout/login p/ extensões) |
| `configs.sh` | dconf (GNOME), Fish como shell padrão, XMousePasteBlock, GTK middle-click block | **Sim** (reinício completo) |
| `scripts/install-autoscroll.sh` | Autoscroll estilo Windows (ícone, Xorg apenas) | **Sim** (logout + sessão Xorg) |

> ⚠️ **Importante**: A ordem é obrigatória. `flatpak.sh` prepara a infraestrutura que `instalar.sh` usa. `configs.sh` aplica configs que dependem dos pacotes instalados.

---

## 📦 O que está incluído

| Categoria | Detalhes |
|-----------|----------|
| **Scripts** | `instalar.sh`, `configs.sh`, `flatpak.sh`, `scripts/install-autoscroll.sh` — idempotentes, seguros, com `set -e` |
| **APT (43 pkgs)** | `pacotes/pacotes.txt` — dev tools (git, python3, distrobox), firmware, fish, fastfetch, gnome-tweaks, dconf-editor, gparted, synaptic, temas Yaru, codecs, drivers, AppImage (libfuse2t64 + fuse3) |
| **Flatpak (3)** | `pacotes/flatpaks.txt` — ExtensionManager, Bottles, GdmSettings |
| **`.deb` (1)** | Nautilus Open Any Terminal (integração "Abrir terminal aqui") |
| **Extensões GNOME (11)** | `extensoes/` + `local/share/gnome-shell/extensions/` — tilingshell, dash-to-panel, astra-monitor, arcmenu, clipboard-indicator, lockkeys, user-theme, gsconnect, quick-settings-tweaks, gnome-fuzzy-app-search, rounded-window-corners |
| **dconf** | `gnome/dconf.ini` — keybindings (Super+T=terminal, Super+G=navegador), tema Yaru-dark, middle-click paste desabilitado, appfolders, notificações |
| **Dotfiles** | `configs/fish/` (welcome + fastfetch), `configs/fastfetch/` (`config.jsonc` com logo Linux + cores personalizadas) |
| **Autoscroll** | `scripts/install-autoscroll.sh` — instala versão com ícone (PyQt5), autostart configurado. **Requer sessão "GNOME on Xorg"** |

---

## 🛠️ Personalização

```bash
# Adicionar/remover pacotes APT
vim pacotes/pacotes.txt

# Adicionar/remover Flatpaks
vim pacotes/flatpaks.txt

# Colocar .deb próprios em pacotes/
cp meu-pacote.deb pacotes/

# Atualizar dconf após mudanças no GNOME
dconf dump / > gnome/dconf.ini

# Adicionar extensões GNOME
# Baixe .zip da extensão → extraia em extensoes/<uuid>/ e local/share/gnome-shell/extensions/<uuid>/
```

---

## ⚙️ Pré-requisitos

- Debian 13 (Trixie) com **GNOME** (padrão)
- Conexão com internet (APT, Flatpak, Git)
- `sudo` funcional (senha interativa ou `NOPASSWD`)

---

## 🔒 Segurança

- **Zero segredos** no repositório: chaves privadas, certificados, cookies, histórico de navegador, IPs locais, usuários — **removidos**
- Paths usam `$HOME` — funciona para qualquer usuário
- `.gitignore` protege contra vazamentos futuros
- Licença **GPL v3** — melhorias voltam para a comunidade

---

## 📄 Licença

**GPL v3** — veja [LICENSE](LICENSE).

```
Copyright (C) 2026 Rafael (Ralph-zlt)
This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.
```

---

## 🤝 Contribuição

1. Fork → branch → PR
2. Mantenha scripts idempotentes (`set -e`, checagens de existência)
3. Documente mudanças no README
4. Sem segredos no commit (`.gitignore` existe por motivo)

---

## 👤 Autor

**Ralph (Ralph-zlt)** — [GitHub](https://github.com/Ralph-zlt)

> *Feito para aprender, compartilhar e agilizar o dia a dia de quem usa Debian/GNOME profissionalmente.*