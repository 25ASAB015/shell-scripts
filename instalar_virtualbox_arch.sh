#!/bin/bash

# --- Actualizar el sistema ---
echo "Actualizando el sistema..."
sudo pacman -Syu --noconfirm
echo "Sistema actualizado."

# --- Instalar VirtualBox, el módulo del kernel, los headers y el Extension Pack ---
echo "Instalando VirtualBox, el módulo del kernel, los headers y el Extension Pack..."
sudo pacman -S --noconfirm virtualbox virtualbox-host-dkms linux-headers 
yay -S virtualbox-ext-oracle
#sudo pacman -S virtualbox virtualbox-host-modules-arch virtualbox-ext-oracle virtualbox-ext-oracle
echo "VirtualBox, el módulo del kernel, los headers y el Extension Pack instalados."

# --- Construir e instalar el módulo del kernel con DKMS ---
# El paquete 'virtualbox-host-dkms' ya hace esto automáticamente
# a través de hooks de pacman. No es necesario un comando manual.

# --- Cargar el módulo del kernel 'vboxdrv' ---
echo "Cargando el módulo del kernel 'vboxdrv'..."
# Intentamos cargar el módulo y capturamos la salida para verificar si hay errores.
if ! sudo modprobe vboxdrv; then
    echo "❗ Error: El módulo 'vboxdrv' no se pudo cargar."
    echo "Por favor, verifica que los 'linux-headers' estén correctamente instalados para tu kernel."
    exit 1
fi
echo "Módulo 'vboxdrv' cargado correctamente."

# --- Añadir el usuario al grupo 'vboxusers' ---
echo "Añadiendo el usuario actual ('$USER') al grupo 'vboxusers'..."
sudo usermod -aG vboxusers "$USER"
echo "Usuario añadido. Es posible que necesites cerrar y volver a iniciar sesión para que los cambios surtan efecto."

echo "✅ La instalación de VirtualBox ha finalizado. El 'VirtualBox Guest Additions ISO' se encuentra en /usr/lib/virtualbox/additions."
echo "✅ Se recomienda reiniciar la sesión para que todos los cambios tengan efecto."
