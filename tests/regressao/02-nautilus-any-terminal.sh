#!/bin/bash
# Debian-configs (RDEB) - GPL v3
# Copyright (C) 2026 Ralph (Ralph-zlt)
#
# Suíte de regressão 02 — Tilix como terminal padrão + extensão Nautilus
# Open Any Terminal funcionando com terminais diferentes.
# Bug/feature (2026-10-20): o padrão era gnome-terminal; política do dono é
# tilix como padrão (com fish via shell de login). A extensão do Nautilus
# (nautilus-extension-any-terminal .deb vendored) precisa ficar coerente com
# o padrão (gsettings com.github.stunkymonkey.nautilus-open-any-terminal).
#
# Uso:
#   ./02-nautilus-any-terminal.sh --static   # offline: valida repo (pacotes, lists, configs.sh, dconf.ini)
#   ./02-nautilus-any-terminal.sh --vm       # sessão GNOME: valida gsettings + arquivo .py + shell de login
#
# Baseline = arquivos ATUAIS do repo (mudanças intencionais do dono são o esperado).

set -u

BASE="$(cd "$(dirname "$0")/../.." && pwd)"
PACOTES="$BASE/pacotes/pacotes.txt"
LIST_XDG="$BASE/configs/xdg-terminals.list"
LIST_GNOME="$BASE/configs/gnome-xdg-terminals.list"
CONFIGS_SH="$BASE/configs.sh"
DCONF_INI="$BASE/gnome/dconf.ini"

DESKTOP_TILIX="com.gexperts.Tilix.desktop"
GSET_SCHEMA="com.github.stunkymonkey.nautilus-open-any-terminal"

pass=0
fail=0
ok() { echo "PASS: $1"; pass=$((pass + 1)); }
no() { echo "FAIL: $1"; fail=$((fail + 1)); }

resumo() {
    echo
    echo "======================================="
    echo " Suíte 02 (Tilix/Nautilus): $pass PASS, $fail FAIL"
    [ "$fail" -eq 0 ] && echo " RESULTADO: TUDO VERDE" || echo " RESULTADO: FALHAS ACIMA"
    echo "======================================="
    [ "$fail" -eq 0 ]
}

mode="${1:---static}"

case "$mode" in
--static)
    # --- 1. tilix presente na lista de pacotes APT -------------------------
    if grep -qx "tilix" "$PACOTES"; then
        ok "pacotes.txt ordena tilix"
    else
        no "pacotes.txt NÃO lista 'tilix' — instalação limpa ficaria sem o terminal padrão"
    fi

    # --- 2. xdg-terminals.list × gnome-xdg-terminals.list apontam pro tilix -
    for f in "$LIST_XDG" "$LIST_GNOME"; do
        if [ "$(tr -d '[:space:]' < "$f")" = "$DESKTOP_TILIX" ]; then
            ok "$(basename "$f") == $DESKTOP_TILIX"
        else
            no "$(basename "$f") aponta para '$(cat "$f")' — padrão deveria ser $DESKTOP_TILIX"
        fi
    done
    if [ "$(tr -d '[:space:]' < "$LIST_XDG")" = "$(tr -d '[:space:]' < "$LIST_GNOME")" ]; then
        ok "xdg-terminals.list × gnome-xdg-terminals.list idênticos (transição intencional)"
    else
        no "xdg-terminals.list × gnome-xdg-terminals.list divergem"
    fi

    # --- 3. configs.sh: heredoc + gsettings da extensão em coerência ------
    if grep -q "^$DESKTOP_TILIX$" "$CONFIGS_SH"; then
        ok "configs.sh heredoc do xdg-terminals.list == $DESKTOP_TILIX"
    else
        no "configs.sh heredoc NÃO aponta para $DESKTOP_TILIX (fonte efetiva em runtime)"
    fi
    if grep -qE "^ *org\.gnome\.Terminal\.desktop$" "$CONFIGS_SH"; then
        no "configs.sh ainda sobrescreve o padrão para org.gnome.Terminal.desktop no heredoc"
    else
        ok "configs.sh: heredoc sem resíduo de gnome-terminal como padrão"
    fi
    if grep -qE "gsettings set $GSET_SCHEMA terminal tilix" "$CONFIGS_SH"; then
        ok "configs.sh gsettings '$GSET_SCHEMA terminal' == tilix"
    else
        no "configs.sh gsettings '$GSET_SCHEMA terminal' NÃO é tilix — extensão do Nautilus abriria outro terminal"
    fi
    if grep -qE "gsettings set $GSET_SCHEMA terminal gnome-terminal" "$CONFIGS_SH"; then
        no "configs.sh ainda define 'terminal gnome-terminal' na extensão"
    else
        ok "configs.sh: sem resíduo de gnome-terminal no gsettings da extensão"
    fi
    if grep -qE "nautilus -q" "$CONFIGS_SH"; then
        ok "configs.sh reinicia o Nautilus (recarrega a extensão)"
    else
        no "configs.sh não roda 'nautilus -q' — mudança do gsettings não recarrega a extensão na sessão atual"
    fi

    # --- 4. dconf.ini: atalho Ctrl+Alt+T abre tilix ------------------------
    if grep -A3 "\\[org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0\\]" "$DCONF_INI" \
        | grep -q "command='tilix'"; then
        ok "dconf.ini custom0 (Ctrl+Alt+T) command == 'tilix'"
    else
        no "dconf.ini custom0 (Ctrl+Alt+T) NÃO abre tilix"
    fi

    # --- 5. .deb vendored da extensão presente -----------------------------
    if compgen -G "$BASE/pacotes/nautilus-extension-any-terminal*.deb" >/dev/null; then
        ok ".deb vendored da extensão presente"
    else
        no ".deb nautilus-extension-any-terminal ausente — 'Abrir terminal aqui' não instalará"
    fi

    echo
    if [ "$fail" -eq 0 ]; then
        echo "Suíte 02 --static: TUDO VERDE"
    else
        echo "Suíte 02 --static: FALHAS ACIMA"
    fi
    exit $(( fail > 0 ? 1 : 0 ))
    ;;
--vm)
    # --- 0. Pré-requisitos --------------------------------------------------
    if [ -z "${DBUS_SESSION_BUS_ADDRESS:-}" ]; then
        no "sem DBUS_SESSION_BUS_ADDRESS — rode dentro da sessão GNOME"
        resumo
        exit 1
    fi
    ok "sessão D-Bus detectada"
    if ! command -v gsettings >/dev/null 2>&1; then
        no "gsettings ausente"
        resumo
        exit 1
    fi

    # --- 1. gsettings da extensão == tilix ---------------------------------
    terminal_atual=$(gsettings get "$GSET_SCHEMA" terminal 2>/dev/null | tr -d "'")
    if [ "$terminal_atual" = "tilix" ]; then
        ok "gsettings $GSET_SCHEMA terminal == tilix"
    else
        no "gsettings $GSET_SCHEMA terminal = '${terminal_atual:-<vazio>}' (esperado 'tilix' — rodar configs.sh antes)"
    fi

    # --- 2. xdg-terminal-exec resolve para Tilix ---------------------------
    if command -v xdg-terminal-exec >/dev/null 2>&1; then
        ok "xdg-terminal-exec presente"
        if [ -f "$HOME/.config/xdg-terminals.list" ]; then
            if [ "$(tr -d '[:space:]' < "$HOME/.config/xdg-terminals.list")" = "$DESKTOP_TILIX" ]; then
                ok "$HOME/.config/xdg-terminals.list == $DESKTOP_TILIX"
            else
                no "$HOME/.config/xdg-terminals.list = '$(cat "$HOME/.config/xdg-terminals.list")' (esperado $DESKTOP_TILIX)"
            fi
        else
            no "$HOME/.config/xdg-terminals.list ausente (rodar configs.sh antes)"
        fi
    else
        no "xdg-terminal-exec ausente (Debian 13 deve tê-lo)"
    fi

    # --- 3. Extensão Python do Nautilus instalada --------------------------
    if dpkg -s nautilus-extension-any-terminal >/dev/null 2>&1; then
        ok "pacote nautilus-extension-any-terminal instalado"
    else
        no "pacote nautilus-extension-any-terminal NÃO instalado (rodar instalar.sh antes)"
    fi
    if dpkg -s python3-nautilus >/dev/null 2>&1; then
        ok "python3-nautilus instalado"
    else
        no "python3-nautilus ausente — extensões Python do Nautilus não carregam"
    fi
    py_encontrado=$(dpkg -L nautilus-extension-any-terminal 2>/dev/null | grep -m1 '\.py$' || true)
    if [ -f "$py_encontrado" ]; then
        ok "extensão .py presente: $py_encontrado"
    else
        no "extensão .py do any-terminal não encontrada via dpkg -L"
    fi

    # --- 4. Shell de login é fish (tilix abre o shell de login) ------------
    shell_login=$(getent passwd "$USER" | cut -d: -f7)
    if [ "$(basename "$shell_login")" = "fish" ]; then
        ok "shell de login do usuário é fish ($shell_login) — Tilix abrirá fish"
    else
        no "shell de login é '$shell_login' — Tilix abriria outro shell (rodar configs.sh antes)"
    fi

    # --- 5. Atalho Ctrl+Alt+T apontando para tilix -------------------------
    custom0=$(dconf read /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/command 2>/dev/null | tr -d "'")
    if [ "$custom0" = "tilix" ]; then
        ok "custom0 (Ctrl+Alt+T) command == tilix"
    else
        no "custom0 (Ctrl+Alt+T) command = '${custom0:-<vazio>}' (esperado 'tilix')"
    fi

    # --- 6. A extensão troca o terminal na prática (multi-terminal) --------
    # Troca tilix <-> gnome-terminal no gsettings e confirma persistência.
    for t in tilix gnome-terminal; do
        gsettings set "$GSET_SCHEMA" terminal "$t"
        lido=$(gsettings get "$GSET_SCHEMA" terminal | tr -d "'")
        if [ "$lido" = "$t" ]; then
            ok "extensão aceita terminal '$t' (multi-terminal)"
        else
            no "gsettings não persistiu '$t' (leu '$lido')"
        fi
    done
    # restaura o padrão do dono
    gsettings set "$GSET_SCHEMA" terminal tilix

    # --- 7. Recarregamento do Nautilus -------------------------------------
    if command -v nautilus >/dev/null 2>&1; then
        if nautilus -q >/dev/null 2>&1; then
            ok "nautilus -q executado (extensão recarregará no próximo início do Nautilus)"
        else
            no "nautilus -q falhou"
        fi
    else
        no "nautilus ausente?"
    fi

    resumo
    ;;
*)
    echo "Uso: $0 --static | --vm" >&2
    exit 2
    ;;
esac
