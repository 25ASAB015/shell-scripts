#!/bin/bash
set -e

echo "[1/7] Agregando el repositorio chaotic-aur a /etc/pacman.conf..."
if ! grep -q "\\[chaotic-aur\\]" /etc/pacman.conf; then
    echo -e "\\n[chaotic-aur]\\nInclude = /etc/pacman.d/chaotic-mirrorlist" | sudo tee -a /etc/pacman.conf
fi

echo "[2/7] Creando el archivo chaotic-mirrorlist..."
echo "Server = https://geo-mirror.chaotic.cx/\\$repo/\\$arch" | sudo tee /etc/pacman.d/chaotic-mirrorlist

echo "[4/7] Firmando las claves localmente..."
sudo pacman-key --lsign-key 3A40CB5E7E5CBC30
sudo pacman-key --lsign-key 349BC7808577C592
sudo pacman-key --lsign-key 3056513887B78AEB

echo "[5/7] Actualizando la base de datos de paquetes..."
sudo pacman -Sy

echo "[6/7] Instalando chaotic-keyring y chaotic-mirrorlist..."
sudo pacman -S --noconfirm chaotic-keyring chaotic-mirrorlist

echo "[7/7] Verificación opcional: Instalando paquete de prueba (google-chrome)..."
read -p "¿Deseas instalar google-chrome como prueba? [y/N]: " confirm
if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
    sudo pacman -S google-chrome
else
    echo "Instalación de prueba omitida."
fi

echo "✅ Todo listo. Chaotic AUR está funcionando."
