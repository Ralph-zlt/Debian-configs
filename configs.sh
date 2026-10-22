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
echo " Aplicando Configurações do Sistema"
echo "======================================="

BASE="$(cd "$(dirname "$0")" && pwd)"
# Configurações de Usuário (.config)
########################################
if [ -d "$BASE/configs" ]; then
    echo
    echo " Copiando arquivos de configuração..."
    mkdir -p ~/.config
    cp -a "$BASE/configs/." ~/.config/
fi

########################################
# Restauração do dconf (GNOME)
########################################
# BUG 2026-10-19: `dconf load ... || echo` engolia o erro — na VM as configs das
# extensões (arcmenu, dash-to-panel, etc.) subiam com defaults. Agora a falha é
# explícita e o dconf é garantido. Deve rodar DENTRO da sessão GNOME do usuário.
if [ -f "$BASE/gnome/dconf.ini" ]; then
    echo
    echo " Restaurando configurações do GNOME..."
    if ! command -v dconf >/dev/null 2>&1; then
        echo "--> 'dconf' não encontrado; instalando dconf-cli..."
        sudo apt update
        sudo apt install -y dconf-cli
    fi
    if ! dconf load / < "$BASE/gnome/dconf.ini"; then
        echo "ERRO: dconf load falhou — configs do GNOME/extensões NÃO foram aplicadas." >&2
        echo "Rode este script dentro da sessão GNOME do usuário (com D-Bus ativo)." >&2
        exit 1
    fi
    if [ -z "$(dconf read /org/gnome/shell/enabled-extensions)" ]; then
        echo "ERRO: enabled-extensions vazio após o load — restauração incompleta." >&2
        exit 1
    fi
    echo " dconf restaurado e verificado (extensões habilitadas aplicadas)."
fi

########################################
# Extensão do Nautilus: Criar Doc com Nome
########################################
echo "Configurando extensão de criação de arquivos no Nautilus..."

# Cria a pasta de extensões Python do Nautilus, caso não exista
mkdir -p ~/.local/share/nautilus-python/extensions

# Cria a extensão em Python
cat > ~/.local/share/nautilus-python/extensions/criar_texto.py << 'EOF'
import os
import subprocess
from gi.repository import Nautilus, GObject

class CriarTextoExtension(GObject.Object, Nautilus.MenuProvider):
    def __init__(self):
        super().__init__()

    # Esta função controla o menu que aparece ao clicar no fundo/espaço em branco
    def get_background_items(self, *args):
        current_folder = args[-1]
        
        item = Nautilus.MenuItem(
            name="NautilusExtension::CriarTexto",
            label="Novo Documento de Texto...",
            tip="Criar um novo arquivo de texto nesta pasta"
        )
        item.connect("activate", self.menu_activate_cb, current_folder)
        return [item]

    def menu_activate_cb(self, menu, current_folder):
        # Pega o caminho real da pasta atual
        gfile = current_folder.get_location()
        path = gfile.get_path()
        
        # Abre a janelinha do Zenity pedindo o nome
        res = subprocess.run(
            ['zenity', '--entry', '--title=Criar Documento', '--text=Digite o nome do arquivo:', '--entry-text=Texto.txt'],
            capture_output=True, text=True
        )
        
        # Se o usuário digitou e confirmou, cria o arquivo
        if res.returncode == 0:
            filename = res.stdout.strip()
            if filename:
                filepath = os.path.join(path, filename)
                try:
                    with open(filepath, 'w') as f:
                        pass
                except Exception:
                    pass
EOF

########################################
# Configurações de Terminal e Shell
########################################
echo
echo " Aplicando configurações de terminal..."

# Define o Fish como shell padrão do usuário
if command -v fish >/dev/null 2>&1; then
    sudo usermod -s "$(command -v fish)" "$USER"
fi

# Define o Tilix como terminal padrão (xdg-terminal-exec) — kitty removido;
# GNOME Terminal continua instalado como alternativo.
mkdir -p ~/.config
cat > ~/.config/xdg-terminals.list << 'EOF'
com.gexperts.Tilix.desktop
EOF

# Configura a extensão Open Any Terminal do Nautilus para usar o Tilix
if command -v gsettings >/dev/null 2>&1; then
    gsettings set com.github.stunkymonkey.nautilus-open-any-terminal terminal tilix || true
fi

# Recarrega o Nautilus para a extensão (e o novo padrão) valerem na sessão atual
nautilus -q 2>/dev/null || true
#############################################

echo "Iniciando a instalação e configuração do xmousepasteblock..."

# 1. Instalar dependências necessárias
echo "--> Instalando pacotes básicos..."
sudo apt update
sudo apt install -y make gcc pkg-config libev-dev libx11-dev libxi-dev git

# 2. Baixar o código-fonte em uma pasta temporária
echo "--> Baixando o repositório..."
cd /tmp
rm -rf XMousePasteBlock
git clone --depth 1 https://github.com/milaq/XMousePasteBlock.git
cd XMousePasteBlock

# 3. Compilar e instalar o programa
echo "--> Compilando e instalando no sistema..."
make
sudo make install

# 4. Configurar o Autostart para o usuário atual
echo "--> Criando regra de inicialização automática..."
mkdir -p ~/.config/autostart

cat <<EOF > ~/.config/autostart/xmousepasteblock.desktop
[Desktop Entry]
Type=Application
Exec=xmousepasteblock
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=XMousePasteBlock
Comment=Bloqueia a colagem indesejada do mouse
EOF

# 5. Iniciar o programa na sessão atual
echo "--> Iniciando o bloqueador..."
pkill -f xmousepasteblock || true
xmousepasteblock &
# Kitty removido do setup — trava middle-click fica só no GNOME Terminal/GTK abaixo.
echo "Sucesso! O clique-do-meio não vai mais colar textos e o bloqueio iniciará junto com o sistema."
# ==========================================
# Bloqueio de Colagem no Terminal Padrão / GTK
# ==========================================
echo "Desabilitando colagem via clique no terminal padrão..."

# 1. Configurações Globais da Interface GNOME (GSettings)
gsettings set org.gnome.desktop.interface gtk-enable-primary-paste false 2>/dev/null || true
gsettings set org.gnome.Terminal.Legacy.Settings middle-click-paste false 2>/dev/null || true

# 2. Forçar a diretiva nas bibliotecas GTK 3 e GTK 4 (base do terminal padrão)
for GTK_VER in "gtk-3.0" "gtk-4.0"; do
    GTK_DIR="$HOME/.config/$GTK_VER"
    GTK_CONF="$GTK_DIR/settings.ini"

    mkdir -p "$GTK_DIR"

    if [ ! -f "$GTK_CONF" ]; then
        echo -e "[Settings]\ngtk-enable-primary-paste=false" > "$GTK_CONF"
    elif ! grep -q "gtk-enable-primary-paste" "$GTK_CONF"; then
        if grep -q "\[Settings\]" "$GTK_CONF"; then
            sed -i '/\[Settings\]/a gtk-enable-primary-paste=false' "$GTK_CONF"
        else
            echo -e "\n[Settings]\ngtk-enable-primary-paste=false" >> "$GTK_CONF"
        fi
    else
        sed -i 's/gtk-enable-primary-paste=.*/gtk-enable-primary-paste=false/' "$GTK_CONF"
    fi
done

# 3. Aplicar diretamente em todos os perfis do GNOME Terminal via Dconf
if command -v dconf &> /dev/null; then
    PROFILES=$(dconf list /org/gnome/terminal/legacy/profiles:/ 2>/dev/null | grep '^:')
    for PROFILE in $PROFILES; do
        dconf write "/org/gnome/terminal/legacy/profiles:/${PROFILE}middle-click-paste" "false" 2>/dev/null || true
    done
fi

echo "-> Trava de colagem aplicada no terminal padrão do sistema."
echo
echo "======================================="
echo " Configurações aplicadas com sucesso!"
echo " Recomenda-se reiniciar o computador."
echo "======================================="
