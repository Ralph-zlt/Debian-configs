#!/bin/bash
# Instala linux-autoscroll (TWolczanski) para Xorg — corrige .desktop quebrado do setup antigo
# Uso: bash scripts/install-autoscroll.sh
# Requer: sessão "GNOME on Xorg" (não funciona em Wayland puro)
set -e

TARGET="$HOME/linux-autoscroll"
VENV="$TARGET/.autoscroll"
SCRIPT="$TARGET/autoscroll.py"
REPO="https://github.com/TWolczanski/linux-autoscroll.git"

echo "== autoscroll (Xorg) =="
if [ "${XDG_SESSION_TYPE:-}" = "wayland" ]; then
  echo "AVISO: sessão Wayland detectada. O script só funciona em Xorg. Troque no GDM para 'GNOME on Xorg'."
fi

sudo apt update
# Libs runtime Qt5-xcb: o PyQt5 via pip embute o Qt mas não puxa deps de
# sistema — sem elas o plugin "xcb" não inicializa no boot do motor.
sudo apt install -y python3-dev python3-venv xsel git libgl1 libegl1 libxkbcommon0 \
    libxkbcommon-x11-0 libxcb-cursor0 libxcb-xinerama0 \
    libxcb-xkb1 libxcb-icccm4 libxcb-image0 libxcb-keysyms1 \
    libxcb-render-util0 libxcb-randr0 libxcb-shape0

if [ ! -d "$TARGET/.git" ]; then
  rm -rf "$TARGET"
  git clone --depth 1 "$REPO" "$TARGET"
else
  git -C "$TARGET" pull --ff-only || true
fi

if [ ! -x "$VENV/bin/python" ]; then
  python3 -m venv "$VENV"
fi
"$VENV/bin/python" -m pip install --upgrade pip wheel
"$VENV/bin/python" -m pip install pynput PyQt5

# Config recomendada: não colar ao entrar/sair (middle-click), meio-segundo de hold evita cliques acidentais
# Guardas grep -q garantem idempotência (re-run não duplica nem falha)
grep -q 'self.CLEAR_CLIPBOARD = True' "$SCRIPT" || sed -i 's/self.CLEAR_CLIPBOARD = False/self.CLEAR_CLIPBOARD = True/' "$SCRIPT"
grep -q 'self.TRIGGER_DELAY = 0.5' "$SCRIPT" || sed -i 's/self.TRIGGER_DELAY = 0$/self.TRIGGER_DELAY = 0.5/' "$SCRIPT"
chmod u+x "$SCRIPT"

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

# Limpa resíduos legados do repo antigo: autostart fantasma + atalho de menu
# quebrado (configs/autostart/autoscroll.desktop e local/share/applications/
# autoscroll.desktop foram removidos do repo em 2026-10-22 — teste de regressão 04)
rm -f ~/.config/autostart/autoscroll.desktop
rm -f ~/.local/share/applications/autoscroll.desktop

echo "OK. Faça logout -> entre em 'GNOME on Xorg' -> segure botão-do-meio 0.5s e arraste para rolar."
echo "Teste manual: $VENV/bin/python $SCRIPT"
