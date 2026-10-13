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
- `limpo-flatpak` = branch de trabalho atual. Todo código novo vai para ela até o dono validar o merge.
- Antes de codar: `git status -sb` + `git log --oneline -5`.

## Onde está o código
- `flatpak.sh` → 1º: instala Flatpak + Flathub (exige logout/login).
- `instalar.sh` → 2º: Flatpaks (`pacotes/flatpaks.txt`), APT (`pacotes/pacotes.txt`), `.deb` (`pacotes/*.deb`), extensões (`extensoes/` → `~/.local/...`), `local/` → `~/.local/`.
- `configs.sh` → 3º: `configs/` → `~/.config/`, `gnome/dconf.ini` via `dconf load`, Fish padrão, XMousePasteBlock, travas middle-click.
- `scripts/install-autoscroll.sh` → opcional Xorg: clona `linux-autoscroll`, venv PyQt5, autostart.
- `pacotes/pacotes.txt` = lista de execução (44 pkgs); `pacotes/listadepacotes.txt` = mesma lista comentada (documentação).
- `gnome/dconf.ini` = dump GNOME (contém resíduos YaST/Pardus — decisão pendente).
- `configs/fish/`, `configs/fastfetch/` = dotfiles (migrado do `neofetch` em 2026-10-12; original arquivado em `Bekaps/`).
- `extensoes/` (11) + `local/share/gnome-shell/extensions/` (9) = união intencional de 11 extensões vendored (ver Exceção abaixo). `extensoes/extensoes.txt` é o manifesto (11 UUIDs, mesma ordem pode divergir do `ls`).
- `configs/xdg-terminals.list` × `configs/gnome-xdg-terminals.list` = conteúdo idêntico intencional (transição de nome); `configs.sh` ainda reescreve `~/.config/xdg-terminals.list` via heredoc — fonte efetiva é o heredoc.
- `gnome/dconf.ini` contém pastas `YaST`/`Pardus`/`suse-yast` (resíduo de dump de outra máquina) — mantido por ora por ser dump fiel do ambiente; limpeza só com validação do dono em VM.

## Exceção documentada à regra UNIVERSAL §5
`AGENTS.UNIVERSAL.md §5` manda nunca versionar `local/`. **Aqui `local/` + `extensoes/` versionados é intencional**: export do ambiente de trabalho, restauração offline/reprodutível. O `conformance-reviewer` NÃO deve marcar isso como violação.

## Não versionar (neste projeto)
- `pacotes/*.deb` de terceiros (exceto os explicitamente liberados no `.gitignore`).
- Segredos: chaves, certificados, cookies, histórico de navegador, IPs locais, usernames (ver `README.md` § Segurança).

## Validação de mudanças
Antes de entregar:
1. `bash -n flatpak.sh instalar.sh configs.sh scripts/install-autoscroll.sh`
2. `shellcheck` nos 4 scripts (instalar se ausente).
3. Re-run idempotente: 2ª execução não pode abortar (`pkill || true`, `sed` com guarda, `apt update` presente).
4. `grep` de conferência: zero refs a removidos (`MissionCenter`, `stacer`, `kitty`, `docker`, `neofetch` após migração).
5. Teste funcional em VM limpa Debian 13 GNOME é do dono (manual).

## Backups
Antes de alteração arriscada: copiar `Debian-configs/` para `../Bekaps/Debian-configs-<motivo>-AAAA-MM-DD/`, verificar `ls` + `du -sh`. Nunca editar/remover o que já está em `Bekaps/`. Se `Bekaps/` estiver pesado, recomendar limpeza manual ao dono — nunca apagar sozinho.

## Aprendizados (seção viva — a IA atualiza)
### ✅ Aprovado / Padrão confirmado
- (2026-10-12) Vendoring `extensoes/`+`local/` intencional, não é violação de minimalismo.
- (2026-10-12) `MissionCenter` removido por decisão; padrão é `gnome-system-monitor`.
- (2026-10-12) Migração `neofetch` → `fastfetch` mantendo pinguim Linux + cores `7 1 3 7 1 3`.
### ❌ Corrigido / Lição aprendida
- (2026-10-12) Não propor minimalismo extremo neste projeto (intenção é export do ambiente).
### 📝 Notas de contexto
- `main` tem só `Initial commit`; trabalho real está em `limpo-flatpak` (8 commits) — merge pendente de validação do dono.
- `PROJETOS.md` referenciava `rdeb/` inexistente — corrigido para `Debian-configs/`.
- (2026-10-12) Sessão Fase 0–4 executada: docs base + P0 + fastfetch/docker/AppImage-base + P1-4 + testes. SC2086 do shellcheck são falso-positivos (word-splitting intencional). Mudanças não commitadas; commit+merge aguardam dono.
