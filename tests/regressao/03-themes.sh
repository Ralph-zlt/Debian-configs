#!/bin/bash
# Debian-configs (RDEB) - GPL v3
# Copyright (C) 2026 Ralph (Ralph-zlt)
#
# Suíte de regressão 03 — temas (Yaru-bark-dark, ícones Yaru-dark)
# Mudança (2026-10-20): decisão do dono de trocar todas as configs de
# Yaru-dark para Yaru-bark-dark, exceto os ícones, que viram Yaru-dark.
# Guarda o dconf.ini contra regressões de tema (troca acidental de dump).
#
# Uso:
#   ./03-themes.sh --static   # offline: valida as chaves de tema do dconf.ini

set -u

BASE="$(cd "$(dirname "$0")/../.." && pwd)"
DCONF_INI="$BASE/gnome/dconf.ini"

pass=0
fail=0
ok() { echo "PASS: $1"; pass=$((pass + 1)); }
no() { echo "FAIL: $1"; fail=$((fail + 1)); }

verificar() {
    local secao="$1" chave="$2" esperado="$3"
    local valor
    valor=$(grep -A20 "\\[$secao\\]" "$DCONF_INI" | grep -m1 "^$chave=" | cut -d= -f2-)
    if [ "$valor" = "$esperado" ]; then
        ok "[$secao] $chave == $esperado"
    else
        no "[$secao] $chave = '${valor:-<ausente>}' (esperado $esperado)"
    fi
}

# --- Valores-alvo da decisão do dono (2026-10-20) ------------------------
verificar "org/gnome/desktop/interface" "accent-color" "'bark'"
verificar "org/gnome/desktop/interface" "gtk-theme" "'Yaru-bark-dark'"
verificar "org/gnome/desktop/interface" "icon-theme" "'Yaru-dark'"
verificar "org/gnome/desktop/interface" "color-scheme" "'prefer-dark'"
verificar "org/gnome/shell/extensions/user-theme" "name" "'Yaru-bark-dark'"

echo
if [ "$fail" -eq 0 ]; then
    echo "Suíte 03 --static: TUDO VERDE"
else
    echo "Suíte 03 --static: FALHAS ACIMA"
fi
exit $(( fail > 0 ? 1 : 0 ))
