#!/bin/bash

# Script para instalar herramientas de desarrollo para shell scripting
# Arch Linux

echo "Instalando herramientas de desarrollo para shell scripting..."

# Instalar shellcheck y shfmt
sudo pacman -S --noconfirm shellcheck shfmt

# Verificar instalación
echo ""
echo "Verificando instalación:"
echo "========================"

if command -v shellcheck >/dev/null 2>&1; then
    echo "✅ shellcheck instalado correctamente"
    shellcheck --version
else
    echo "❌ Error: shellcheck no se instaló"
fi

echo ""

if command -v shfmt >/dev/null 2>&1; then
    echo "✅ shfmt instalado correctamente"
    shfmt --version
else
    echo "❌ Error: shfmt no se instaló"
fi

echo ""
echo "¡Instalación completada!"
echo "Ahora puedes usar estas herramientas en Cursor para mejor soporte de shell scripting."
