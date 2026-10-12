# ROADMAP — Debian-configs (RDEB)

> Changelog: 2026-10-12 — criação. 2026-10-12 — P0 concluído. 2026-10-12 — P1-1/P1-2/P1-3-base concluídos. 2026-10-12 — P1-4 docs concluído. 2026-10-12 — P2-2/P2-3 concluídos. 2026-10-12 — v-nova: fuse3 (43 pkgs) + remoção neofetch + versionamento (antiga em Bekaps).
> Última atualização: 2026-10-12.

---

## 1. Objetivo

**Exportar o ambiente de trabalho do dono (Debian 13 Trixie + GNOME 48) de forma completa e reprodutível** — “a gosto do chef”: scripts ordenados (`flatpak.sh` → `instalar.sh` → `configs.sh` + autoscroll opcional), dotfiles, dconf, extensões GNOME vendored e listas APT/Flatpak que transformam uma instalação limpa em estação pronta em minutos. Não é minimalismo extremo: o vendoring (`extensoes/` + `local/`) e o toolkit atual são intencionais (offline/reprodutível).

---

## 2. Próximos passos

- [ ] P2-1 merge `limpo-flatpak` → `main` (só com validação do dono; inclui commit desta sessão)
- [ ] Pendente do dono: teste funcional em VM limpa Debian 13; extras AppImage se algum app exigir além de FUSE; decisão limpar `dconf` YaST/Pardus

---

## 3. Concluído
- [x] (2026-10-12) v-nova: `fuse3` adicionado (43 pkgs, alta compatibilidade AppImage); `configs/neofetch/` removido do repo (export fastfetch confirmado + backup); versionamento: antiga (`4d9352e`) em `Bekaps/Debian-configs-v-antiga-2026-10-12/`, nova commitada em `limpo-flatpak`.
- [x] (2026-10-12) P2-2/P2-3 testes+reviews: `bash -n` ×4 ok; `shellcheck` warning-level limpo (2 infos SC2086 falso-positivas: word-splitting intencional nas listas APT/Flatpak); fastfetch JSON ok; grep MissionCenter/stacer/docker/neofetch zerados; zero segredos; contagens conferem (42 APT, 3 flatpaks, 1 .deb, 11 extensões). Security: sem `curl|bash`, clones via https `--depth 1`, APT oficial; risco residual: clones sem pin de commit. Conformance: código × docs consistente.
- [x] (2026-10-12) P1-4 docs: README PT/EN (`gsconnect` no lugar de `blur-my-shell`, 42 pkgs, fastfetch, AppImage); `.gitignore` sem `stacer`/`extension-manager`; duplicados documentados no `AGENTS.md` (xdg-terminals, dconf YaST/Pardus mantido como dump fiel); `extensoes.txt` confirmado como manifesto (mesmo conjunto).
- [x] (2026-10-12) P1-1 fastfetch: `configs/fastfetch/config.jsonc` (logo linux + cores da ASCII, 17 módulos), `config.fish` → `fastfetch`, bloco neofetch removido do `instalar.sh` (42 pkgs APT). `configs/neofetch/` mantido em transição no repo + cópia em `Bekaps/.../neofetch-orig/`. README PT/EN atualizados.
- [x] (2026-10-12) P1-2 docker removido dos READMEs (era só texto; código já usava `distrobox`).
- [x] (2026-10-12) P1-3-base AppImage: `libfuse2t64` adicionado (42 pkgs). Pendente: lista de apps do dono p/ decidir `fuse3`/extras.
- [x] (2026-10-12) P0 robustez: P0-1 `set -e` no `flatpak.sh`; P0-2 `pkill || true`; P0-3 `apt update` + `trap` + `TMP_WORK` no `instalar.sh` + `--depth 1` neofetch; P0-4 `mimeapps` → SystemMonitor; P0-5 `--depth 1` XMousePasteBlock/autoscroll + guarda `sed`. Backup: `Bekaps/Debian-configs-pre-p0-2026-10-12/`. Validação: `bash -n` ×4 ok, `grep MissionCenter` zerado.
- [x] (2026-10-06) Limpeza `limpo-flatpak`: remove kitty/swap/stacer/MissionCenter; 41 pkgs comentados; flatpak-first; autoscroll com ícone Xorg; fish+neofetch; `gir1.2-gmenu-3.0` (commits `d72bbdb`–`4d9352e`, ainda não mergeado na `main`)
- [x] (2026-10-12) Auditoria robustez/estrutura/docs: 7 inconsistências mapeadas (blur-my-shell↔gsconnect, docker, neofetch/fastfetch, mimeapps, extensões 11×9, `.gitignore`, dconf YaST/Pardus)
- [x] (2026-10-12) Docs base: `AGENTS.md` + `ROADMAP.md` + `docs/CHANGELOG.md` criados; `PROJETOS.md` corrigido (`rdeb/` → `Debian-configs/`)
