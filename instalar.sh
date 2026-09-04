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

set -e

echo "======================================="
echo " Instalções"
echo "======================================="

BASE="$(cd "$(dirname "$0")" && pwd)"

########################################
# Solicita sudo uma única vez
########################################
echo
echo "Solicitando privilégios de administrador..."
sudo -v

# Mantém o sudo ativo durante toda a execução
while true; do
    sudo -v
    sleep 60
    kill -0 "$$" || exit
done 2>/dev/null &
SUDO_KEEPALIVE_PID=$!
trap 'kill "$SUDO_KEEPALIVE_PID" 2>/dev/null' EXIT

########################################
# Instala aplicativos Flatpak
########################################
echo
echo "Instalando aplicativos Flatpak..."
ARQUIVO_FLATPAK="pacotes/flatpaks.txt"

if [ -f "$ARQUIVO_FLATPAK" ]; then
    # Lê todos os apps ignorando linhas vazias ou comentários
    APPS_FLATPAK=$(grep -v '^#' "$ARQUIVO_FLATPAK" | grep -v '^$')
    if [ -n "$APPS_FLATPAK" ]; then
        # Instala tudo em um único comando (muito mais rápido)
        sudo flatpak install -y flathub $APPS_FLATPAK
    fi
else
    echo "Arquivo não encontrado: $ARQUIVO_FLATPAK"
    exit 1
fi
echo "Instalação dos aplicativos Flatpak concluída!"

########################################
# Instala Neofetch
########################################
echo
echo " Instalando Neofetch..."
sudo apt install -y git make
TMPDIR=$(mktemp -d)
git clone https://github.com/dylanaraps/neofetch.git "$TMPDIR/neofetch"
cd "$TMPDIR/neofetch"
sudo make install
cd "$BASE"
rm -rf "$TMPDIR"
echo "Neofetch instalado com sucesso."

########################################
# Pacotes Debian
########################################
ARQUIVO_PACOTES="$BASE/pacotes/pacotes.txt"
if [ -f "$ARQUIVO_PACOTES" ]; then
    echo
    echo "Instalando pacotes Debian..."
    PACOTES_APT=$(grep -v '^#' "$ARQUIVO_PACOTES" | grep -v '^$')
    if [ -n "$PACOTES_APT" ]; then
        # Instala todos os pacotes de uma vez só
        sudo apt install -y $PACOTES_APT
    fi
fi

########################################
# Pacotes externos (.deb)
########################################
if compgen -G "$BASE/pacotes/*.deb" > /dev/null; then
    echo
    echo "Instalando pacotes externos..."
    # O apt aceita múltiplos arquivos .deb direto, sem precisar de 'for'
    sudo apt install -y "$BASE"/pacotes/*.deb
    sudo apt --fix-broken install -y
fi

########################################
# Extensões GNOME
########################################
if [ -d "$BASE/extensoes" ]; then
    echo
    echo " Instalando extensões..."
    mkdir -p ~/.local/share/gnome-shell/extensions
    cp -a "$BASE/extensoes/." ~/.local/share/gnome-shell/extensions/
fi

########################################
# Pasta .local
########################################
if [ -d "$BASE/local" ]; then
    echo
    echo " Restaurando ~/.local..."
    mkdir -p ~/.local
    cp -a "$BASE/local/." ~/.local/
fi

echo
echo "======================================="
echo " Instalação concluída!"
echo " Faça logout ou reinicie a sessão do GNOME."
echo "======================================="
