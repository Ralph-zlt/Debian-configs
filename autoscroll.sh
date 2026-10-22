#!/bin/bash
# Debian-configs (RDEB) - GPL v3
# Copyright (C) 2026 Ralph (Ralph-zlt)
# https://github.com/Ralph-zlt/Debian-configs
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

# autoscroll.sh — aplica o autoscroll (linux-autoscroll, com ícone, Xorg) numa
# máquina que JÁ rodou o fluxo completo do Debian-configs (flatpak.sh →
# instalar.sh → configs.sh). Reaproveita o ambiente: não restaura as configurações
# do GNOME e não mexe em GNOME/fish/Tilix — só motor + autostart + limpeza de
# resíduos + início imediato na sessão atual (sem logout, quando em Xorg).
#   Para máquina VIRGEM use scripts/install-autoscroll.sh (passo 4 do README).
# Uso: bash autoscroll.sh
# Knobs (env, p/ testes e casos especiais — desnecessários no dia a dia):
#   AS_SKIP_APT=1    assume deps APT presentes (não roda apt)
#   AS_SKIP_PIP=1    assume pynput/PyQt5 presentes (não roda pip)
#   AS_NO_LAUNCH=1   não inicia na sessão atual (só prepara)
#   AS_CLONE_SRC=<caminho|url>  sobre onde clonar (fixture de teste)
set -e

BASE="$(cd "$(dirname "$0")" && pwd)"
TARGET="$HOME/linux-autoscroll"
VENV="$TARGET/.autoscroll"
SCRIPT="$TARGET/autoscroll.py"
REPO="${AS_CLONE_SRC:-https://github.com/TWolczanski/linux-autoscroll.git}"
RUNPATTERN="linux-autoscroll/autoscroll.py"

# DEPS=(xsel python3-dev python3-pip python3-venv git) + libs runtime do Qt5-xcb
# O PyQt5 instalado via pip EMBUTE o Qt, mas não puxa dependências de sistema —
# sem libs abaixo o plugin "xcb" não inicializa ("Could not load the Qt platform plugin").
DEPS=(xsel python3-dev python3-pip python3-venv git \
      libgl1 libegl1 libxkbcommon0 \
      libxkbcommon-x11-0 libxcb-cursor0 libxcb-xinerama0 \
      libxcb-xkb1 libxcb-icccm4 libxcb-image0 libxcb-keysyms1 \
      libxcb-render-util0 libxcb-randr0 libxcb-shape0)

echo "== autoscroll local (motor + autostart + limpeza + início) =="
echo "repo-de-origem: $BASE"

# Sessão: só Xorg funciona (pynput/PyQt5 falam X11)
if [ "${XDG_SESSION_TYPE:-}" = "wayland" ]; then
    echo "AVISO: sessão Wayland detectada — o motor rola só em Xorg."
    echo "       Instalar mesmo assim; iniciarei apenas dentro de 'GNOME on Xorg'."
fi

########################################
# 1. Dependências APT (já vêm dos 45 pkgs; instala só o que faltar)
########################################
if [ "${AS_SKIP_APT:-}" = "1" ]; then
    echo "[deps] AS_SKIP_APT=1 — assumindo dependências APT presentes"
else
    MISSING=()
    for D in "${DEPS[@]}"; do
        if ! dpkg -s "$D" >/dev/null 2>&1; then
            MISSING+=("$D")
        fi
    done
    if [ "${#MISSING[@]}" -gt 0 ]; then
        echo "[deps] instalando faltantes: ${MISSING[*]}"
        sudo apt update
        sudo apt install -y "${MISSING[@]}"
    else
        echo "[deps] todas presentes (fluxo principal já as instalou)"
    fi
fi

########################################
# 2. Motor: clone/pull idempotente
########################################
if [ ! -d "$TARGET/.git" ]; then
    echo "[motor] clonando $REPO → $TARGET"
    rm -rf "$TARGET"
    git clone --depth 1 "$REPO" "$TARGET"
else
    echo "[motor] já existe — atualizando (--ff-only)"
    git -C "$TARGET" pull --ff-only || true
fi

########################################
# 3. Venv + pynput/PyQt5 (apenas se faltar)
########################################
if [ ! -x "$VENV/bin/python" ]; then
    echo "[venv] criando $VENV"
    python3 -m venv "$VENV"
fi
if [ "${AS_SKIP_PIP:-}" = "1" ]; then
    echo "[venv] AS_SKIP_PIP=1 — assumindo pynput/PyQt5 presentes"
elif "$VENV/bin/python" -c "import pynput, PyQt5" >/dev/null 2>&1; then
    echo "[venv] pynput/PyQt5 ok (nada a instalar)"
else
    echo "[venv] instalando pynput/PyQt5 (pode demorar)..."
    "$VENV/bin/python" -m pip install --upgrade pip wheel
    "$VENV/bin/python" -m pip install pynput PyQt5
fi

########################################
# 4. Config do dono + chmod (seds com guarda — re-run não duplica)
########################################
grep -q 'self.CLEAR_CLIPBOARD = True' "$SCRIPT" \
    || sed -i 's/self.CLEAR_CLIPBOARD = False/self.CLEAR_CLIPBOARD = True/' "$SCRIPT"
grep -q 'self.TRIGGER_DELAY = 0.5' "$SCRIPT" \
    || sed -i 's/self.TRIGGER_DELAY = 0$/self.TRIGGER_DELAY = 0.5/' "$SCRIPT"
chmod u+x "$SCRIPT"
echo "[config] CLEAR_CLIPBOARD=True (não colar ao entrar/sair) + TRIGGER_DELAY=0.5 (segurar meio 0,5s)"

########################################
# 5. Autostart correto + limpeza dos resíduos fantasma do setup antigo
########################################
mkdir -p ~/.config/autostart
cat > ~/.config/autostart/linux-autoscroll.desktop <<EOF
[Desktop Entry]
Type=Application
Name=Linux AutoScroll (Xorg)
Exec=bash -c "sleep 3 && $VENV/bin/python $SCRIPT"
Icon=input-mouse
Terminal=false
X-GNOME-Autostart-enabled=true
X-GNOME-Autostart-Delay=3
EOF

rm -f ~/.config/autostart/autoscroll.desktop
rm -f ~/.local/share/applications/autoscroll.desktop
echo "[autostart] linux-autoscroll.desktop pronto; resíduos fantasma removidos (autostart + menu)"

########################################
# 6. Início na sessão atual (sem logout, quando Xorg)
########################################
if [ "${AS_NO_LAUNCH:-}" = "1" ]; then
    echo "[início] AS_NO_LAUNCH=1 — não inicio agora; faça logout e entre em 'GNOME on Xorg'."
elif [ "${XDG_SESSION_TYPE:-}" = "wayland" ]; then
    echo "[início] Wayland não suportado — faça logout, escolha 'GNOME on Xorg' na engrenagem do GDM."
elif [ -z "${DISPLAY:-}" ]; then
    echo "[início] sem DISPLAY (sessão gráfica indisponível) — rode de novo dentro da sessão Xorg."
elif pgrep -f "$RUNPATTERN" >/dev/null 2>&1; then
    echo "[início] autoscroll já está rodando nesta sessão — nada a fazer."
else
    nohup "$VENV/bin/python" "$SCRIPT" > "$TARGET/autoscroll.log" 2>&1 &
    sleep 1
    if pgrep -f "$RUNPATTERN" >/dev/null 2>&1; then
        echo "[início] motor iniciado NESTA sessão (log: $TARGET/autoscroll.log) — teste segurando o botão do meio 0,5s e arrastando."
    else
        echo "[início] processo NÃO subiu — cauda do log ($TARGET/autoscroll.log):"
        tail -n 8 "$TARGET/autoscroll.log" 2>/dev/null || true
        echo
        echo "hint: 'Could not load the Qt platform plugin' = faltam as libs runtime Qt5-xcb:"
        echo "      sudo apt install -y libxkbcommon-x11-0 libxcb-cursor0 libxcb-xinerama0"
        exit 1
    fi
fi

echo "OK. Uso: segure o botão do MEIO ~0,5s e arraste para rolar (clique rápido não dispara, por design)."
