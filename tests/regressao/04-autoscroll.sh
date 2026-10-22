#!/bin/bash
# Debian-configs (RDEB) - GPL v3
# Copyright (C) 2026 Ralph (Ralph-zlt)
#
# Suíte de regressão 04 — Autoscroll (linux-autoscroll, Xorg).
# Bug (2026-10-22): o repo vendora `.desktop` fantasma do autoscroll
# (configs/autostart/autoscroll.desktop + local/share/applications/autoscroll.desktop)
# apontando para $HOME/linux-autoscroll/… que só existe se o script opcional
# scripts/install-autoscroll.sh rodar. Em máquina limpa, configs.sh copia o
# autostart quebrado e o autoscroll falha em silêncio (o motor nunca é instalado
# pelo fluxo principal). Além disso, re-rodar configs.sh APÓS instalar o
# autoscroll devolve o autostart quebrado (sem guarda). Decisão do dono
# (opção 1): os .desktop fantasma saem do repo — autoscroll é 100% conteúdo
# do install-autoscroll.sh, que instala o motor, cria o autostart correto e
# limpa os resíduos legados (autostart e atalho de menu).
#
# Uso:
#   ./04-autoscroll.sh --static   # offline: valida repo (sem fantasma, script corrigido, README)
#   ./04-autoscroll.sh --vm       # sessão GNOME: valida motor + autostart na máquina aplicada

set -u

BASE="$(cd "$(dirname "$0")/../.." && pwd)"
CONFIGS="$BASE/configs"
LOCAL="$BASE/local"
FANTASMA="autoscroll.desktop"
SCRIPT="$BASE/scripts/install-autoscroll.sh"
README="$BASE/README.md"

MOTOR="$HOME/linux-autoscroll"
VENV_PY="$MOTOR/.autoscroll/bin/python"
PY="$MOTOR/autoscroll.py"
AUTOSTART="$HOME/.config/autostart"
DESKTOP_APPS="$HOME/.local/share/applications"

pass=0
fail=0
ok() { echo "PASS: $1"; pass=$((pass + 1)); }
no() { echo "FAIL: $1"; fail=$((fail + 1)); }

resumo() {
    echo
    echo "======================================="
    echo " Suíte 04 (Autoscroll): $pass PASS, $fail FAIL"
    [ "$fail" -eq 0 ] && echo " RESULTADO: TUDO VERDE" || echo " RESULTADO: FALHAS ACIMA"
    echo "======================================="
    [ "$fail" -eq 0 ]
}

mode="${1:---static}"

case "$mode" in
--static)
    # --- 1. Nenhum .desktop fantasma vendored no repo ----------------------
    fantasmas=$(find "$CONFIGS" "$LOCAL" -name "$FANTASMA" 2>/dev/null || true)
    if [ -n "$fantasmas" ]; then
        no "repo ainda vendora $FANTASMA fantasma: $(echo "$fantasmas" | tr '\n' ' ')"
    else
        ok "configs/ e local/ sem $FANTASMA fantasma"
    fi

    # --- 2. Nenhuma referência a $HOME/linux-autoscroll fora do script opcional
    refs=$(grep -rl "linux-autoscroll" "$CONFIGS" "$LOCAL" 2>/dev/null || true)
    if [ -n "$refs" ]; then
        no "referências a linux-autoscroll fora do escopo do script opcional: $(echo "$refs" | tr '\n' ' ')"
    else
        ok "configs/ e local/ sem referências a linux-autoscroll"
    fi
    if git -C "$BASE" rev-parse --git-dir >/dev/null 2>&1; then
        rastreados=$(git -C "$BASE" ls-files | grep -E "(configs/autostart|local/)/$FANTASMA" || true)
        if [ -n "$rastreados" ]; then
            no "arquivos fantasma ainda rastreados no git: $rastreados"
        else
            ok "git não rastreia nenhum $FANTASMA em configs/ ou local/"
        fi
    fi

    # --- 3. configs.sh sem hardcode de autostart do autoscroll -------------
    if grep -q "autoscroll" "$BASE/configs.sh"; then
        no "configs.sh ainda menciona autoscroll: $(grep -n "autoscroll" "$BASE/configs.sh" | tr '\n' ';') — fluxo principal deve ser independente do motor"
    else
        ok "configs.sh sem referência a autoscroll (cp -a de configs/ e local/ já não leva fantasma)"
    fi

    # --- 4. install-autoscroll.sh cobre o ciclo completo -------------------
    if [ ! -f "$SCRIPT" ]; then
        no "scripts/install-autoscroll.sh ausente"
        resumo
        exit 1
    fi
    if grep -q "config/autostart/$FANTASMA" "$SCRIPT" && grep -q "share/applications/$FANTASMA" "$SCRIPT"; then
        ok "install-autoscroll.sh limpa os resíduos legados (autostart + atalho de menu)"
    else
        no "install-autoscroll.sh NÃO limpa algum resíduo legado ($FANTASMA em autostart e/ou applications)"
    fi
    if grep -q "linux-autoscroll.desktop" "$SCRIPT"; then
        ok "install-autoscroll.sh cria linux-autoscroll.desktop (autostart correto)"
    else
        no "install-autoscroll.sh não cria linux-autoscroll.desktop"
    fi
    if grep -q "CLEAR_CLIPBOARD = True" "$SCRIPT" && grep -q "TRIGGER_DELAY = 0.5" "$SCRIPT"; then
        ok "install-autoscroll.sh aplica CLEAR_CLIPBOARD=True e TRIGGER_DELAY=0.5 (com guardas)"
    else
        no "install-autoscroll.sh não aplica guarda/correção de CLEAR_CLIPBOARD/TRIGGER_DELAY"
    fi
    if grep -qi "wayland" "$SCRIPT"; then
        ok "install-autoscroll.sh avisa sobre Wayland (só Xorg)"
    else
        no "install-autoscroll.sh não valida/avisa sessão Wayland"
    fi

    # --- 5. README documenta autoscroll como passo opcional ----------------
    if grep -q "install-autoscroll.sh" "$README" && grep -q "Opcional" "$README"; then
        ok "README documenta o autoscroll como passo opcional"
    else
        no "README não documenta (Opcional) o install-autoscroll.sh"
    fi

    # --- 6. autoscroll.sh (local, máquina já-configurada) ------------------
    LOCALSH="$BASE/autoscroll.sh"
    if [ -f "$LOCALSH" ]; then
        ok "autoscroll.sh presente no repo root (máquina já-rodada)"
    else
        no "autoscroll.sh ausente no root — máquina que já rodou o setup fica sem aplicador local"
    fi
    if [ -x "$LOCALSH" ]; then
        ok "autoscroll.sh executável (bit de execução)"
    else
        no "autoscroll.sh sem bit de execução"
    fi
    if head -5 "$LOCALSH" | grep -q "set -e" || grep -q "^set -e" "$LOCALSH"; then
        ok "autoscroll.sh com set -e"
    else
        no "autoscroll.sh sem set -e (política do repo)"
    fi
    for knob in AS_SKIP_APT AS_SKIP_PIP AS_NO_LAUNCH AS_CLONE_SRC; do
        if grep -q "$knob" "$LOCALSH"; then
            ok "autoscroll.sh knob $knob presente"
        else
            no "autoscroll.sh sem knob $knob (testes/variabilidade quebra)"
        fi
    done
    if grep -q "dpkg -s" "$LOCALSH"; then
        ok "autoscroll.sh verifica deps APT via dpkg (fast path, máquina já-rodada)"
    else
        no "autoscroll.sh roda apt cegamente (deveria checar dpkg antes)"
    fi
    if grep -q "import pynput, PyQt5" "$LOCALSH"; then
        ok "autoscroll.sh fast path do pip (só instala se import faltar)"
    else
        no "autoscroll.sh sem fast path do pip"
    fi
    if grep -q "rm -f" "$LOCALSH" && grep -q "config/autostart/$FANTASMA" "$LOCALSH" && grep -q "share/applications/$FANTASMA" "$LOCALSH"; then
        ok "autoscroll.sh limpa os resíduos fantasma (autostart + menu)"
    else
        no "autoscroll.sh não limpa os resíduos fantasma"
    fi
    if grep -q "pgrep -f" "$LOCALSH" && grep -q "nohup" "$LOCALSH"; then
        ok "autoscroll.sh inicia na sessão atual com guarda pgrep (sem duplicar)"
    else
        no "autoscroll.sh sem início imediato + guarda pgrep"
    fi
    if grep -q "dconf" "$LOCALSH"; then
        no "autoscroll.sh fala com dconf — dconf é exclusividade do configs.sh"
    else
        ok "autoscroll.sh não toca dconf/GNOME (config aplicada pelo configs.sh)"
    fi

    # --- 7. Libs runtime Qt5-xcb (bug 2026-10-22: pip PyQt5 não puxa deps do sistema)
    # Sintoma: "Could not load the Qt platform plugin xcb — even though it was found"
    for arq in "$LOCALSH" "$SCRIPT"; do
        nome=$(basename "$arq")
        for lib in libxkbcommon-x11-0 libxcb-cursor0 libxcb-xinerama0; do
            if grep -q "$lib" "$arq"; then
                ok "$nome instala $lib (runtime Qt5-xcb)"
            else
                no "$nome NÃO instala $lib — pip PyQt5 quebra no boot (plugin xcb)"
            fi
        done
    done
    if grep -q "cauda do log" "$LOCALSH" && grep -q "tail -n" "$LOCALSH"; then
        ok "autoscroll.sh mostra a cauda do log quando o motor não sobe"
    else
        no "autoscroll.sh não diagnostica morte do motor (sem cauda do log)"
    fi
    if grep -q "Could not load the Qt platform plugin" "$LOCALSH"; then
        ok "autoscroll.sh dá hint das libs Qt5-xcb na falha de boot"
    else
        no "autoscroll.sh sem hint das libs Qt5-xcb"
    fi

    echo
    if [ "$fail" -eq 0 ]; then
        echo "Suíte 04 --static: TUDO VERDE"
    else
        echo "Suíte 04 --static: FALHAS ACIMA"
    fi
    exit $(( fail > 0 ? 1 : 0 ))
    ;;
--vm)
    # --- pré-requisito: deve rodar na sessão GNOME (Xorg) do usuário -------
    if [ -z "${DBUS_SESSION_BUS_ADDRESS:-}" ]; then
        no "sem DBUS_SESSION_BUS_ADDRESS — rode dentro da sessão GNOME"
        resumo
        exit 1
    fi
    ok "sessão D-Bus detectada"

    # --- 1. Motor instalado ------------------------------------------------
    if [ -f "$VENV_PY" ] && [ -f "$PY" ]; then
        ok "motor linux-autoscroll presente ($PY)"
    else
        no "motor ausente em $MOTOR — rode: bash $BASE/scripts/install-autoscroll.sh"
        resumo
        exit 1
    fi
    if [ -x "$VENV_PY" ]; then
        ok "venv do autoscroll executável"
    else
        no "venv do autoscroll não executável ($VENV_PY)"
    fi

    # --- 2. Autostart correto e sem fantasma -------------------------------
    if [ -f "$AUTOSTART/linux-autoscroll.desktop" ]; then
        ok "autostart correto presente (linux-autoscroll.desktop)"
    else
        no "autostart correto ausente ($AUTOSTART/linux-autoscroll.desktop)"
    fi
    if [ -f "$AUTOSTART/$FANTASMA" ]; then
        no "resíduo legado presente ($AUTOSTART/$FANTASMA) — rodar install-autoscroll.sh"
    else
        ok "sem resíduo legado no autostart"
    fi
    if [ -f "$DESKTOP_APPS/$FANTASMA" ]; then
        no "resíduo legado no menu ($DESKTOP_APPS/$FANTASMA) — rodar install-autoscroll.sh"
    else
        ok "sem resíduo legado no menu de aplicações"
    fi

    # --- 3. Configurações do dono aplicadas no autoscroll.py ---------------
    if grep -q "CLEAR_CLIPBOARD = True" "$PY"; then
        ok "autoscroll.py CLEAR_CLIPBOARD=True"
    else
        no "autoscroll.py sem CLEAR_CLIPBOARD=True (rodar install-autoscroll.sh)"
    fi
    if grep -q "TRIGGER_DELAY = 0.5" "$PY"; then
        ok "autoscroll.py TRIGGER_DELAY=0.5 (segurar meio 0,5s)"
    else
        no "autoscroll.py sem TRIGGER_DELAY=0.5 (rodar install-autoscroll.sh)"
    fi

    # --- 4. Processo vivo (sessão atual) ------------------------------------
    if pgrep -f "linux-autoscroll/autoscroll.py" >/dev/null 2>&1; then
        ok "autoscroll rodando na sessão atual"
    else
        no "autoscroll NÃO está rodando — logout/login na sessão Xorg (ou iniciar manualmente: $VENV_PY $PY)"
    fi

    # --- 5. Engine sobe sem erro Qt (bug 2026-10-22: Qt-xcb runtime) --------
    # Entrada: executar o motor com timeout 5s. Saída esperada:
    #   rc=124 (timeout matou = processo VIVO) e nada de "Could not load the
    #   Qt platform plugin" — o mesmo teste de entrada→saída do dono, rodando
    #   dentro da sessão GNOME.
    if command -v timeout >/dev/null 2>&1; then
        QTLOG=$(mktemp)
        set +e
        timeout 5 "$VENV_PY" "$PY" >/dev/null 2>"$QTLOG"
        rc_engine=$?
        set -u
        if [ "$rc_engine" = 124 ]; then
            ok "engine vivo após 5s (rc=124=timeout) — Qt/xcb ok"
        elif grep -q "Could not load the Qt platform plugin" "$QTLOG" 2>/dev/null; then
            no "engine morreu no boot (Qt xcb) — correção: apt install -y libxkbcommon-x11-0 libxcb-cursor0 libxcb-xinerama0"
        else
            no "engine saiu antes do timeout (rc=$rc_engine) — log: $(head -2 "$QTLOG" 2>/dev/null)"
        fi
        rm -f "$QTLOG"
    else
        no "timeout ausente — não foi possível testar o boot do engine"
    fi

    resumo
    ;;
*)
    echo "Uso: $0 --static | --vm" >&2
    exit 2
    ;;
esac
