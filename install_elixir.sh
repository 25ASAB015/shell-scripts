#!/bin/bash

# Este script instala Erlang y Elixir usando pacman,
# y también incluye las dependencias de desarrollo para funcionalidades adicionales.

# Salir inmediatamente si un comando falla.
set -e

echo "--- Actualizando el sistema e instalando dependencias ---"

# Instala las dependencias de desarrollo y funcionalidades opcionales.
# 'jdk-openjdk': Para la interoperabilidad con Java (jinterface).
# 'unixodbc': Para la conectividad a bases de datos con ODBC.
# 'wxwidgets': Para las herramientas gráficas de Erlang, como el Observer.
sudo pacman -Syu --needed --noconfirm jdk-openjdk unixodbc wxwidgets

echo "--- Instalando Erlang y Elixir con pacman ---"

# Instala los paquetes principales de Erlang y Elixir.
sudo pacman -S --needed --noconfirm erlang elixir

echo "--- ¡Instalación completada! ---"
echo "Erlang y Elixir han sido instalados junto con las dependencias opcionales."
echo "Puedes verificar las versiones con los siguientes comandos:"
echo "erl -version"
echo "iex -v"
