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

Um conjunto de scripts, dotfiles e automações que transformam uma instalação limpa do Debian em um ambiente de desenvolvimento/station pronto para uso em **minutos**, não horas.

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

bash instalar.sh     # 2º - Apps Flatpak + 309 pkgs APT + 3 .deb + extensões GNOME + ~/.local
# → Faça logout/login para extensões carregarem

bash configs.sh      # 3º - Swap 8GB, dconf, Fish/Kitty, XMousePasteBlock, GTK middle-click block
# → Reinicie o computador

# 3. Pronto! Ambiente configurado.
```

**O que cada script faz:**

| Script | Responsabilidade | Reinício necessário? |
|--------|------------------|---------------------|
| `flatpak.sh` | Instala `flatpak`, `gnome-software-plugin-flatpak`, adiciona Flathub, `flatpak update` | **Sim** (logout/login) |
| `instalar.sh` | Apps Flatpak (4), 309 pacotes APT, 3 `.deb`, 10 extensões GNOME, restaura `~/.local` | **Sim** (logout/login p/ extensões) |
| `configs.sh` | Swap 8GB, dconf (GNOME), Fish/Kitty defaults, XMousePasteBlock, GTK middle-click block | **Sim** (reinício completo) |

> ⚠️ **Importante**: A ordem é obrigatória. `flatpak.sh` prepara a infraestrutura que `instalar.sh` usa. `configs.sh` aplica configs que dependem dos pacotes instalados.

---

## 📦 O que está incluído

| Categoria | Detalhes |
|-----------|----------|
| **Scripts** | `instalar.sh`, `configs.sh`, `flatpak.sh` — idempotentes, seguros, com `set -e` |
| **APT (309 pkgs)** | `pacotes/pacotes.txt` — dev tools (git, python3, docker), GNOME apps, firmware, fish, kitty, neofetch, stacer, etc. |
| **Flatpak (4)** | `pacotes/flatpaks.txt` — ExtensionManager, Bottles, GdmSettings, MissionCenter |
| **`.deb` (3)** | Extension Manager, Nautilus Open Any Terminal, Stacer |
| **Extensões GNOME (10)** | `extensoes/` + `local/share/gnome-shell/extensions/` — tilingshell, dash-to-panel, astra-monitor, arcmenu, clipboard-indicator, lockkeys, user-theme, blur-my-shell, quick-settings-tweaks, gnome-fuzzy-app-search |
| **dconf** | `gnome/dconf.ini` — keybindings (Super+T=kitty, Super+G=navegador), tema Yaru-purple-dark, middle-click paste desabilitado, appfolders, notificações |
| **Dotfiles** | `configs/fish/` (welcome + neofetch), `configs/kitty/` (splits Ctrl+Shift+D/Enter), `configs/neofetch/`, `configs/stacer/` |
| **Autoscroll (opcional)** | `.desktop` em `configs/autostart/` e `local/share/applications/` — apontam para `$HOME/linux-autoscroll/` (script Python **não incluso**, cada usuário adiciona o seu) |

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

- **Zero segredos** no repositório: chaves privadas, certificados KDE Connect/GSConnect, cookies, histórico de navegador, IPs LAN, usernames — **removidos**
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