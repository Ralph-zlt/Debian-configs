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

echo "Iniciando a configuração do Flatpak..."

########################################
# Instala o Flatpak
########################################
echo
echo "Instalando Flatpak..."

#  Para o instalador em segundo plano para liberar o APT imediatamente
sudo systemctl stop packagekit || true

sudo apt update
sudo apt install -y flatpak gnome-software-plugin-flatpak

########################################
# Adiciona o Flathub
########################################
echo
echo "Configurando o Flathub..."
# Estes comandos usam o cache do sudo, rodando direto
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Atualiza os metadados para o sistema reconhecer os pacotes
sudo flatpak update -y

########################################
# Fim do Script e Aviso de Reinício
########################################
echo
echo "Flatpak configurado com sucesso!"
echo "------------------------------------------------------------"
echo "AVISO: Para que o Flatpak funcione 100%, você precisa"
echo "reiniciar a sua sessão (fazer logoff) agora."
echo "Depois de reiniciar, você pode rodar o próximo script."
echo "------------------------------------------------------------"
