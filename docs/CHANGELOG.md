# CHANGELOG — Debian-configs (RDEB)

> Entradas no topo (mais recente primeiro). Formato: data + o que mudou + por quê + onde.

## 2026-10-21 — sincronização GitHub×local + `assets/` ignorado
- **Verificação:** `origin/main` = local (`07bfac8`); `origin/limpo-flatpak` estava em `c51094f`, 3 commits atrás do local (`330ade6`). Sem divergência remota; push fast-forward.
- **Sincronização:** enviados `514648a`, `26a8586` e `330ade6` para `origin/limpo-flatpak` (fix dconf, Tilix + suíte 02, tema Yaru-bark-dark + suíte 03).
- **`assets/`:** imagens pessoais do dono (3 arquivos) passam a ser ignoradas no `.gitignore`; não versionadas.
- **Docs:** `AGENTS.md` corrigido (estado real das branches; nota duplicada/obsoleta do `dconf.ini` removida; `assets/` registrado em "Não versionar").
- **`main`:** autorização explícita do dono → merge de `limpo-flatpak` na `main` (merge commit, sem force/rewrite) e push; a `main` passa a conter a versão atual.
- Validação: `bash -n` + `shellcheck` + suítes 01/02/03 `--static`. Onde: `limpo-flatpak` → `main`. Testes `--vm` seguem pendentes do dono.

## 2026-10-20 — tema Yaru-bark-dark (ícones Yaru-dark) + suíte 03
- **Pedido do dono:** trocar todas as configs de `Yaru-dark`, exceto os ícones (que ficam `Yaru-dark`). Decisões tomadas em consulta: variante **dark** conservada → `Yaru-bark-dark`; tema do Shell (`user-theme`, era `Yaru-purple-dark`) entra na troca; `accent-color` de `purple` → `bark`; `color-scheme` `prefer-dark` mantido (os ícones hoje eram `Yaru` claro).
- **Fix (`gnome/dconf.ini`):** `accent-color` `purple`→`bark` (L27), `gtk-theme` `Yaru-dark`→`Yaru-bark-dark` (L31), `icon-theme` `Yaru`→`Yaru-dark` (L32), `user-theme name` `Yaru-purple-dark`→`Yaru-bark-dark` (L298). Nenhum pacote novo: variantes verificadas nos debs do Debian 13 (`yaru-theme-gtk`/`-gnome-shell` 24.04.3 têm `Yaru-bark(-dark)`; `yaru-theme-icon` tem `Yaru-dark`).
- **Suíte 03 (teste primeiro):** `tests/regressao/03-themes.sh --static` valida as 5 chaves (accent/gtk/icon/color-scheme/user-theme). Prova: 4 FAIL antes do fix × 5 PASS / 0 FAIL depois.
- Validação: `bash -n` + `shellcheck` + suítes 01/02/03 `--static` verdes. Onde: branch `limpo-flatpak`. Pendente: dono aplica (`dconf load`) na sessão GNOME e valida o look.

## 2026-10-20 — Tilix como terminal padrão + suíte 02 (extensão Nautilus)
- **Pedido do dono:** Tilix como terminal padrão, fish automático nele (igual ao GNOME Terminal, via shell de login) e verificação da extensão Nautilus Open Any Terminal com terminais diferentes. Decisões: GNOME Terminal **mantido** (alternativo, perfis dconf preservados); fish via shell de login (sem dconf próprio do Tilix); teste nascendo FAIL antes do fix (política bug→teste).
- **Fix:** `pacotes.txt` + `tilix` (44→45) + `listadepacotes.txt`; `configs.sh` heredoc do `~/.config/xdg-terminals.list` → `com.gexperts.Tilix.desktop`, gsettings `com.github.stunkymonkey.nautilus-open-any-terminal terminal` → `tilix`, `nautilus -q` ao final (recarrega a extensão na sessão atual); `configs/xdg-terminals.list` × `configs/gnome-xdg-terminals.list` → Tilix; `gnome/dconf.ini` custom0 (Ctrl+Alt+T) → `command='tilix'`. Coments do GNOME Terminal como padrão atualizados.
- **Suíte 02:** `tests/regressao/02-nautilus-any-terminal.sh` (--static: valida tilix em pacotes/lists/heredoc/gsettings/dconf + `.deb` vendored; --vm: gsettings, xdg-terminal-exec, `.py` via dpkg, fish como shell de login, troca tilix↔gnome-terminal no gsettings, `nautilus -q`). Prova: 9 FAIL antes do fix × 11 PASS / 0 FAIL depois.
- Backup: `Bekaps/Debian-configs-pre-tilix-2026-10-20/` (+ `ORIGEM.txt`, `Debian-configs-HISTORICO.md` dos backups). Validação: `bash -n` + `shellcheck` + suítes 01 e 02 `--static` verdes. Pendente: dono roda ambas as suítes em `--vm` na sessão GNOME. Onde: branch `limpo-flatpak`.

## 2026-10-19 — causa raiz do bug dconf confirmada na VM: `[]` nu aborta o load
- **Teste do dono na VM (log em `erro`, apagado após diagnóstico):** `dconf load` abortou na linha 150 — `error: [org/gnome/shell]: disabled-extensions: invalid value: []: 0-2:unable to infer type`. O dconf do Debian 13 (Trixie) é estrito: **array vazio sem anotação de tipo (`[]` nu) é rejeitado, e `dconf load` é all-or-nothing** — por isso NENHUMA das 252 chaves era aplicada (sintoma: arcmenu/dash-to-panel com defaults). O fix de mecanismo da sessão funcionou: agora o erro aparece em vez de ser engolido pelo `|| echo`.
- **Fix:** `gnome/dconf.ini:150` `disabled-extensions=@as []` e `:177` `recently-installed-apps=@as []` (`@as` = array de strings; forma canônica do `dconf dump`; compatível com dconf antigo também). Nenhum outro valor alterado.
- **Suíte apertada (teste primeiro, prova do fix):** `tests/regressao/01-dconf-extensions.sh --static` agora reprova `[]` nu e exige `@as []`. Antes do fix: 2 FAILs nas exatas chaves do erro da VM; depois: 29 PASS / 0 FAIL.
- Validação: `bash -n` + `shellcheck` ok. Pendente: dono sincroniza o `dconf.ini` corrigido (Syncthing) na VM e roda o `--vm` (comparação chave a chave confirma). Onde: branch `limpo-flatpak` (não commitado).
- Lição registrada no `AGENTS.md` (Aprendizados): dconf do Trixie é estrito; dump deve sempre usar tipos explícitos em vazios (`@as []`).

## 2026-10-19 — fix dconf (configs das extensões não aplicavam) + suíte de regressão
- **Bug relatado pelo dono (teste em VM):** `configs.sh` não aplicava as configs das extensões GNOME salvas em `gnome/dconf.ini` — arcmenu e dash-to-panel subiam com defaults. Causa no código: `dconf load ... || echo "Aviso..."` engolia qualquer falha silenciosamente. Causas prováveis no ambiente: `dconf-cli` ausente (binário `dconf` não é garantido no Debian 13 GNOME) ou execução fora da sessão D-Bus. **Nenhum valor do dconf foi alterado** — mudanças intencionais do dono (fish+fastfetch, firefox, gnome-terminal, 11 UUIDs) preservadas.
- **Fix:** `configs.sh` agora verifica `command -v dconf` (instala `dconf-cli` se faltar), roda `dconf load` com erro explícito (aborta com `exit 1`), e valida pós-load (`enabled-extensions` não vazio). `instalar.sh`: `ARQUIVO_FLATPAK` ganhou `$BASE` (caminho relativo quebrava se rodado de fora da pasta).
- **Nova suíte de regressão (política REGRAS.md §2 / AGENTS.UNIVERSAL.md Regra 8 — bug → teste determinístico primeiro):** `tests/regressao/01-dconf-extensions.sh` com dois modos: `--static` (offline: parse do dconf.ini, GVariant válido, enabled-extensions == extensoes.txt, 11 UUIDs vendored, seções × schemas, zero refs a programas removidos) e `--vm` (dentro da sessão GNOME: diagnóstico de causa, `dconf load` com erro visível, comparação chave a chave `dconf dump` × `dconf.ini`, end-to-end via gsettings). Estado `--static`: 29 PASS, 0 FAIL.
- **Comparativo pré↔pós transição flatpak (pedido do dono):** GitHub = local (`c51094f` na `limpo-flatpak`; `main` remota só tem o merge do PR #1 `07bfac8`). Pré-transição = `7efb06e` (era APT). Diffs conferidos: remoções intencionais (kitty/stacer/MissionCenter/blur-my-shell/notification-center/`Rounded_Corners@lennart-k`→`rounded-window-corners@fxgn`), brave→firefox, kitty→gnome-terminal, YaST/Pardus removidos — nada de valor perdido além do intencional; schemas vendored × paths do dconf conferem.
- Backup: `Bekaps/Debian-configs-pre-fix-dconf-2026-10-19/` (20 MB, `ORIGEM.txt`). Validação: `bash -n` + `shellcheck` nos scripts alterados + suíte `--static` verde. Pendente: dono roda `01-dconf-extensions.sh --vm` na VM para confirmar o fix. Onde: branch `limpo-flatpak` (não commitado; aguarda dono).

## 2026-10-12 — limpeza dconf (programas removidos/ausentes)
- `gnome/dconf.ini` (−52/+8 linhas): removidos Pardus/YaST, blur-my-shell ×6, notificações brave/virtualboxvm, portais chromium/waveterm, pinned virtualbox/discover/kdeconnect/stacer, calamares, disabled-extensions; `enabled-extensions` = 11 UUIDs do `extensoes.txt`; brave→firefox (atalho+favoritos); `configs/discoverrc` apagado. Mantidos: `rounded-window-corners-reborn` (schema real da fxgn), eds, libreoffice. Motivo: sistema limpo, regra config-de-programa-removido. Backup: `Bekaps/Debian-configs-pre-dconf-2026-10-12/`. Validação: parse 54 seções, greps zerados, enabled==11. Onde: branch `limpo-flatpak`.

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
