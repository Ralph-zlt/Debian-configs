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

# install-autoscroll.sh — instala o autoscroll (linux-autoscroll, com ícone, Xorg)
# para MÁQUINA VIRGEM (passo 4 do README; após flatpak.sh/instalar.sh/configs.sh).
#   Para máquina que JÁ rodou o setup (retomada/local) use `bash autoscroll.sh` no root.
# Requer sessão "GNOME on Xorg" (Wayland puro não suporta).
# Knobs (env, p/ testes — desnecessários no dia a dia; defaults ligam tudo):
#   AS_SKIP_APT=1      assume deps APT presentes (não roda apt)
#   AS_SKIP_PIP=1      assume pynput/PyQt5 presentes (não roda pip)
#   AS_CLONE_SRC=<caminho|url>  sobrescreve origem do clone (fixture de teste)
set -e

TARGET="$HOME/linux-autoscroll"
VENV="$TARGET/.autoscroll"
SCRIPT="$TARGET/autoscroll.py"
REPO="${AS_CLONE_SRC:-https://github.com/TWolczanski/linux-autoscroll.git}"

# Libs runtime Qt5-xcb: o PyQt5 via pip embute o Qt mas não puxa deps de
# sistema — sem elas o plugin "xcb" não inicializa no boot do motor.
DEPS=(python3-dev python3-venv xsel git \
      libgl1 libegl1 libxkbcommon0 \
      libxkbcommon-x11-0 libxcb-cursor0 libxcb-xinerama0 \
      libxcb-xkb1 libxcb-icccm4 libxcb-image0 libxcb-keysyms1 \
      libxcb-render-util0 libxcb-randr0 libxcb-shape0)

echo "== autoscroll (Xorg, máquina virgem) =="
if [ "${XDG_SESSION_TYPE:-}" = "wayland" ]; then
  echo "AVISO: sessão Wayland detectada. O script só funciona em Xorg. Troque no GDM para 'GNOME on Xorg'."
fi

# 1. Dependências APT
if [ "${AS_SKIP_APT:-}" = "1" ]; then
  echo "[deps] AS_SKIP_APT=1 — assumindo dependências APT presentes"
else
  echo "[deps] apt update + install (${#DEPS[@]} pkgs — inclui runtime Qt5-xcb)"
  sudo apt update
  sudo apt install -y "${DEPS[@]}"
fi

# 2. Motor (clone idempotente)
if [ ! -d "$TARGET/.git" ]; then
  echo "[motor] clonando $REPO → $TARGET"
  rm -rf "$TARGET"
  git clone --depth 1 "$REPO" "$TARGET"
else
  echo "[motor] já existe — atualizando (--ff-only)"
  git -C "$TARGET" pull --ff-only || true
fi

# 3. Venv + pynput/PyQt5 (só instala o que faltar)
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

# 4. Config do dono (seds com guarda — re-run não duplica)
grep -q 'self.CLEAR_CLIPBOARD = True' "$SCRIPT" || sed -i 's/self.CLEAR_CLIPBOARD = False/self.CLEAR_CLIPBOARD = True/' "$SCRIPT"
grep -q 'self.TRIGGER_DELAY = 0.5' "$SCRIPT" || sed -i 's/self.TRIGGER_DELAY = 0$/self.TRIGGER_DELAY = 0.5/' "$SCRIPT"
chmod u+x "$SCRIPT"

# 5. Autostart correto + limpeza de resíduos fantasma do setup antigo
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

echo "OK. Faça logout -> entre em 'GNOME on Xorg' -> segure botão-do-meio 0.5s e arraste para rolar."
echo "Teste manual: $VENV/bin/python $SCRIPT"
