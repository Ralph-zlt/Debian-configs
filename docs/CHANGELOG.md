# CHANGELOG — Debian-configs (RDEB)

> Entradas no topo (mais recente primeiro). Formato: data + o que mudou + por quê + onde.

## 2026-10-12 — podman backend distrobox (43→44 pkgs)
- `podman` adicionado após `distrobox` em `pacotes.txt` + `listadepacotes.txt`; READMEs/AGENTS 43→44. Motivo: `distrobox` sem backend falhava em install limpo; podman rootless nativo Debian resolve (uidmap/slirp4netns via recommends). Antiga (`9825c7b`) em `Bekaps/Debian-configs-v-9825c7b-2026-10-12/`. Validação: contagem 44, `bash -n` ×4 ok, `shellcheck` limpo. Onde: branch `limpo-flatpak`. Pendente funcional: `distrobox create` na VM limpa.

## 2026-10-12 — v-nova: fuse3 + remoção neofetch + versionamento
- `fuse3` adicionado (42→43 pkgs, READMEs/AGENTS atualizados); `configs/neofetch/config.conf` removido (fastfetch validado, backup em `Bekaps/.../neofetch-orig/`); refs de transição limpas nos READMEs/AGENTS. Motivo: alta compatibilidade AppImage + migração concluída. Versionamento: antiga (`4d9352e`) arquivada em `Bekaps/Debian-configs-v-antiga-2026-10-12/` (20M, `git archive` + `ORIGEM.txt`); nova versão commitada em `limpo-flatpak` (`d0e98cc`). Validação: `bash -n` ×4 ok, grep neofetch funcional zerado.

## 2026-10-12 — P2-2/P2-3 testes+reviews (Fase 4)
- `bash -n` ×4 ok; `shellcheck` limpo (2 infos SC2086 falso-positivas, word-splitting intencional); fastfetch JSON ok; greps zerados; zero segredos; contagens ok (42/3/1/11). Security sem achados bloqueantes (residual: clones sem pin). Onde: branch `limpo-flatpak` (não commitado; merge P2-1 aguarda dono).

## 2026-10-12 — P1-4 docs (Fase 3)
- README PT/EN (`gsconnect`, 42 pkgs, fastfetch, AppImage); `.gitignore` limpo; duplicados intencionais documentados no `AGENTS.md`; `extensoes.txt` validado como manifesto. Motivo: zerar inconsistências docs×código sem enxugar ambiente. Onde: branch `limpo-flatpak`.

## 2026-10-12 — P1-1/P1-2/P1-3-base (Fase 2)
- `configs/fastfetch/config.jsonc` criado (logo linux + cores `white/red/yellow` = `7 1 3 7 1 3`, 17 módulos); `config.fish` → `fastfetch`; bloco neofetch removido do `instalar.sh`; `docker` removido dos READMEs; `libfuse2t64` adicionado (41→42 pkgs). Motivo: migração aprovada sem perder ASCII; AppImages tipo 2 no Trixie. Backup: `Bekaps/Debian-configs-pre-p0-2026-10-12/{neofetch-orig,fish-orig}/`. Validação: JSON ok, `bash -n` ok, grep neofetch/docker zerados em scripts. Onde: branch `limpo-flatpak`. Pendente: lista de AppImages p/ `fuse3`/extras; decisão apagar `configs/neofetch/` do repo.

## 2026-10-12 — P0 robustez (Fase 1)
- `flatpak.sh` + `set -e`; `configs.sh` `pkill || true`; `instalar.sh` + `apt update` + `trap`/`TMP_WORK` + `--depth 1` neofetch; `mimeapps.list` MissionCenter→SystemMonitor; `--depth 1` XMousePasteBlock/autoscroll + guarda `sed`. Motivo: quebras em re-run/máquina limpa. Backup: `Bekaps/Debian-configs-pre-p0-2026-10-12/`. Validação: `bash -n` ×4 ok. Onde: branch `limpo-flatpak`.

## 2026-10-12 — Docs base (Fase 0)
- Criados `AGENTS.md` (workflow, branches, validação, exceção `local/` versionado, Aprendizados), `ROADMAP.md` (objetivo + próximos passos P0/P1/P2 + concluído) e este `CHANGELOG.md`. Motivo: projeto sem nenhum doc de IA/roadmap; `PROJETOS.md` apontava `rdeb/` inexistente. Onde: `Debian-configs/`, `Projetos/PROJETOS.md`.

## 2026-10-06 — Limpeza limpo-flatpak (8 commits, não mergeado na main)
- `d72bbdb` Limpeza: removido lixo (apt-min, backup, deb-legacy, programas-removidos); só produção permanece.
- `eca1dd6` `pacotes.txt` → 41 comentados; `.deb` legado removido; mantido só `nautilus-extension-any-terminal`.
- `a2d1f96` `pacotes.txt` limpo (execução) + `listadepacotes.txt` documentado (comentários).
- `e798af7` Fix: removido `nautilus-python` (inexistente no Debian 13), mantido `python3-nautilus`.
- `b41f586` + `gir1.2-gmenu-3.0` (dep arcmenu); greeting fish só neofetch; GNOME Terminal padrão (kitty removido).
- `15d72ab` Removido MissionCenter → volta `gnome-system-monitor` (flatpaks 4→3).
- `0809149` Config limpa Debian 13: apt-min 41 pkgs, flatpak-first, sem kitty, autoscroll com ícone Xorg, fish+neofetch.
- `4d9352e` Removido swap do `configs.sh`; READMEs (41 APT, 3 flatpak, 1 .deb); `gir1.2-gmenu-3.0`.
- Onde: branch `limpo-flatpak`, 8 commits à frente de `main`.

## 2026-09-13 (aprox.) — Initial commit
- `7efb06e` Scripts, dotfiles e extensões iniciais Debian. Onde: `main`.
