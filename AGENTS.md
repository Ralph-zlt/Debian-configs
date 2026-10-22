# AGENTS.md — Debian-configs (RDEB)

Instruções para **IAs e colaboradores** que forem editar este repositório.

## Antes de editar (obrigatório)
- Leia **`README.md`** — objetivo, ordem dos scripts, o que está incluído.
- Leia **`ROADMAP.md`** — objetivo do projeto, próximos passos (fonte de verdade do estado), concluído.
- Leia **`docs/CHANGELOG.md`** — histórico do que foi feito e por quê.
- Consulte `../PROJETOS.md` para estado geral e metodologia.
- Só altere o que a tarefa pede; preserve a intenção do dono (“gosto do chef”, não minimalismo extremo).

## Metodologia e fases
Segue o nível `profissional + segurança` da programação automatizada (`../AGENTS.md` + `../AGENTS.UNIVERSAL.md`):
uma fase por vez, sem implementar com dúvidas que causem retrabalho. Ao encerrar
cada fase: resultado, arquivos alterados, validações, backup usado, riscos,
pendências e próximo passo. Atualize `ROADMAP.md` (mova concluídos de “próximos
passos” para “concluído”) e `docs/CHANGELOG.md` (entrada no topo) a cada fase.

## Branches (obrigatório)
- `main` = estável, só o dono valida e mergeia. IA NUNCA pusha direto na `main` sem autorização explícita.
- `dev` = branch de trabalho atual (era `limpo-flatpak`, renomeada em 2026-10-22 a pedido do dono). Todo código novo vai para ela até o dono validar o merge.
- Antes de codar: `git status -sb` + `git log --oneline -5`.

## Onde está o código
- `flatpak.sh` → 1º: instala Flatpak + Flathub (exige logout/login).
- `instalar.sh` → 2º: Flatpaks (`pacotes/flatpaks.txt`), APT (`pacotes/pacotes.txt`), `.deb` (`pacotes/*.deb`), extensões (`extensoes/` → `~/.local/...`), `local/` → `~/.local/`.
- `configs.sh` → 3º: `configs/` → `~/.config/`, `gnome/dconf.ini` via `dconf load` (garante `dconf-cli`, erro explícito, valida pós-load; **rodar dentro da sessão GNOME**), Fish padrão, XMousePasteBlock, travas middle-click.
- `scripts/install-autoscroll.sh` → opcional Xorg **p/ máquina virgem**: clona `linux-autoscroll`, venv PyQt5, autostart.
- `autoscroll.sh` (root) → aplicador local **p/ máquina que já rodou o setup**: fast paths (dpkg/pip/clone), limpa resíduos do setup antigo, inicia o motor na sessão Xorg atual sem logout. Não mexe nas configurações do GNOME (exclusividade do `configs.sh`). Knobs p/ teste: `AS_SKIP_APT`, `AS_SKIP_PIP`, `AS_NO_LAUNCH`, `AS_CLONE_SRC`.
- `pacotes/pacotes.txt` = lista de execução (45 pkgs); `pacotes/listadepacotes.txt` = mesma lista comentada (documentação).
- `configs/fish/`, `configs/fastfetch/` = dotfiles (migrado do `neofetch` em 2026-10-12; original arquivado em `Bekaps/`).
- `extensoes/` (11) + `local/share/gnome-shell/extensions/` (9) = união intencional de 11 extensões vendored (ver Exceção abaixo). `extensoes/extensoes.txt` é o manifesto (11 UUIDs, mesma ordem pode divergir do `ls`).
- `configs/xdg-terminals.list` × `configs/gnome-xdg-terminals.list` = conteúdo idêntico intencional (transição de nome); ambos apontam para `com.gexperts.Tilix.desktop`; `configs.sh` ainda reescreve `~/.config/xdg-terminals.list` via heredoc — fonte efetiva é o heredoc (também Tilix). Fish abre via shell de login (`usermod`), sem dconf próprio do Tilix.
- `gnome/dconf.ini` = dump GNOME limpo em 2026-10-12 (YaST/Pardus e resíduos removidos; `tweak-kitty-terminal=false` é chave de schema da extensão fxgn, não referência ao kitty removido). Mudanças intencionais do dono preservadas: fish+fastfetch, firefox, tilix (custom0 Ctrl+Alt+T; gnome-terminal mantido como alternativo), 11 UUIDs.
- `tests/regressao/` = suíte de regressão obrigatória (política `REGRAS.md` §2 / `AGENTS.UNIVERSAL.md` Regra 8): todo bug vira um teste que falha sem o fix e passa com o fix; suíte só cresce. `01-dconf-extensions.sh` e `02-nautilus-any-terminal.sh` têm modo `--static` (offline) e `--vm` (sessão GNOME). Rodar antes de entregar.

## Exceção documentada à regra UNIVERSAL §5
`AGENTS.UNIVERSAL.md §5` manda nunca versionar `local/`. **Aqui `local/` + `extensoes/` versionados é intencional**: export do ambiente de trabalho, restauração offline/reprodutível. O `conformance-reviewer` NÃO deve marcar isso como violação.

## Não versionar (neste projeto)
- `pacotes/*.deb` de terceiros (exceto os explicitamente liberados no `.gitignore`).
- `assets/` (imagens pessoais do dono; ignorado no `.gitignore` desde 2026-10-21).
- Segredos: chaves, certificados, cookies, histórico de navegador, IPs locais, usernames (ver `README.md` § Segurança).

## Validação de mudanças
Antes de entregar:
1. `bash -n flatpak.sh instalar.sh configs.sh autoscroll.sh scripts/install-autoscroll.sh tests/regressao/*.sh`
2. `shellcheck` nos scripts (instalar se ausente).
3. Suíte de regressão: `tests/regressao/01-dconf-extensions.sh --static` e `tests/regressao/02-nautilus-any-terminal.sh --static` verdes (e `--vm` na sessão GNOME quando aplicável).
4. Re-run idempotente: 2ª execução não pode abortar (`pkill || true`, `sed` com guarda, `apt update` presente).
5. `grep` de conferência: zero refs a removidos (`MissionCenter`, `stacer`, `kitty`, `docker`, `neofetch` após migração).
6. Teste funcional em VM limpa Debian 13 GNOME é do dono (manual).

## Backups
Antes de alteração arriscada: copiar `Debian-configs/` para `../Bekaps/Debian-configs-<motivo>-AAAA-MM-DD/`, verificar `ls` + `du -sh`. Nunca editar/remover o que já está em `Bekaps/`. Se `Bekaps/` estiver pesado, recomendar limpeza manual ao dono — nunca apagar sozinho.

## Aprendizados (seção viva — a IA atualiza)
### ✅ Aprovado / Padrão confirmado
- (2026-10-12) Vendoring `extensoes/`+`local/` intencional, não é violação de minimalismo.
- (2026-10-12) `MissionCenter` removido por decisão; padrão é `gnome-system-monitor`.
- (2026-10-12) Migração `neofetch` → `fastfetch` mantendo pinguim Linux + cores `7 1 3 7 1 3`.
- (2026-10-20) **Tilix é o terminal padrão** (xdg-terminals.list + Ctrl+Alt+T + extensão Nautilus); GNOME Terminal permanece instalado como alternativo (perfis dconf preservados). Fish abre via shell de login — sem dconf próprio do Tilix. `configs.sh` roda `nautilus -q` para recarregar a extensão do Nautilus.
- (2026-10-20) **Tema do dono: `Yaru-bark-dark`** (GTK+Shell, `accent-color='bark'`); **ícones `Yaru-dark`** (exceção intencional às demais partes de tema); `color-scheme='prefer-dark'`. Guardado pela suíte 03.
- (2026-10-22) Padrão aprovado: aplicador local (`autoscroll.sh`) separado do fluxo virgem (`scripts/install-autoscroll.sh`) — máquina já-rodada reaproveita deps (dpkg fast path) e inicia sem logout; teste em sandbox com knobs `AS_*` (HOME redirecionado) valida o script sem tocar a máquina real. Branches: `dev` (trabalho) + `main` (estável).
- (2026-10-22) pip PyQt5 embute o Qt mas não declara deps de sistema — sem as **libs runtime Qt5-xcb** (`libxkbcommon-x11-0`, `libxcb-cursor0`, `libxcb-xinerama0`, família xcb) o plugin `xcb` fica "found" e não inicializa: motor morre no boot (`Could not load the Qt platform plugin`). DEPS dos dois scripts cobrem agora; morte no boot nunca é engolida (cauda do log + hint, rc=1); suíte 04 testa libs (`--static`) e boot do engine (`--vm`).
### ❌ Corrigido / Lição aprendida
- (2026-10-12) Não propor minimalismo extremo neste projeto (intenção é export do ambiente).
- (2026-10-19) Nunca engolir falha de comando crítico com `|| echo` — `dconf load` falhava silencioso e as configs das extensões não aplicavam na VM. Padrão: falha explícita + verificação pós-comando.
- (2026-10-19) **dconf do Debian 13 (Trixie) é estrito:** array vazio sem tipo (`[]` nu) é rejeitado e `dconf load` é all-or-nothing (uma chave ruim zera o restore inteiro). Dump sempre com tipos explícitos: `@as []`. Prova: log `erro` da VM (linha 150) + suíte 01 (FAIL antes, PASS depois).
- (2026-10-19) Todo bug vira teste de regressão antes do fix (`tests/regressao/`, política em `REGRAS.md` §2).
- (2026-10-22) Autoscroll: os scripts principais **nunca instalaram o motor** — apenas copiavam `.desktop`s fantasma apontando para `$HOME/linux-autoscroll` (criado apenas pelo passo opcional `scripts/install-autoscroll.sh`). "Sem autoscroll em Xorg" ≠ quebra aplicada: era autostart falhando em silêncio. XMousePasteBlock/travas de paste não impedem scroll (limpam só a seleção PRIMARY); uso exige segurar o meio ~0,5 s (`TRIGGER_DELAY=0.5`). Fix (opção escolhida do dono): fantasma removido do repo; autoscroll 100% no script opcional, que também limpa os resíduos legados — coberto pela suíte 04.
### 📝 Notas de contexto
- `main` = versão atual (`2026-10-21`, merge da versão, autorizado pelo dono); `dev` (= ex-`limpo-flatpak`, renome 2026-10-22) segue como branch de trabalho. Testes `--vm` ainda pendentes do dono.
- `PROJETOS.md` referenciava `rdeb/` inexistente — corrigido para `Debian-configs/`.
- (2026-10-12) Sessão Fase 0–4 executada: docs base + P0 + fastfetch/docker/AppImage-base + P1-4 + testes. SC2086 do shellcheck são falso-positivos (word-splitting intencional).
- (2026-10-20) Fix dconf (2026-10-19) + Tilix/extensão Nautilus commitados juntos (`514648a` em `limpo-flatpak`); merge para `main` aguarda validação do dono + testes `--vm`.
- (2026-10-21) `limpo-flatpak` sincronizada com o GitHub (3 commits pendentes enviados); `assets/` passou a ser ignorado (imagens pessoais, não versionadas). `main` recebeu a versão atual via merge de `limpo-flatpak` (autorização explícita do dono).
