#!/bin/bash

# Este script instala Ruby, Ruby on Rails y dependencias opcionales
# usando el gestor de paquetes de Arch Linux, pacman.

# Salir inmediatamente si un comando falla.
set -e

echo "--- Actualizando la base de datos de paquetes ---"
sudo pacman -Syu

echo "--- Instalando Ruby y dependencias opcionales ---"
# Instala el paquete principal de Ruby y todas las dependencias adicionales.
# --needed: Solo instala los paquetes que faltan.
# --noconfirm: No pide confirmación para instalar.
sudo pacman -S --needed --noconfirm ruby tk ruby-docs ruby-default-gems ruby-bundled-gems ruby-stdlib

echo "--- Instalando Ruby on Rails como gema ---"
# El paquete 'ruby' ya incluye la herramienta 'gem'.
# Se usa 'sudo' para instalar la gema a nivel de sistema.
sudo gem install rails
gem install rails

echo "--- ¡Instalación completada! ---"
echo "Puedes verificar las versiones de Ruby y Rails con los siguientes comandos:"
echo "ruby -v"
echo "rails -v"
echo "También puedes verificar la disponibilidad de los paquetes instalados."
