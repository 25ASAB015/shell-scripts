#!/bin/bash

# Script para instalar extensiones de Cursor para desarrollo JavaScript/React
# Autor: Renaissance
# Fecha: $(date)

echo "🚀 Instalando extensiones de Cursor para JavaScript/React..."
echo "=================================================="

# Array de extensiones a instalar
extensions=(
    "dsznajder.es7-react-js-snippets"
    "xabikos.JavaScriptSnippets"
    "steoates.autoimport"
    "formulahendry.auto-rename-tag"
    "ms-vscode.vscode-typescript-next"
    "esbenp.prettier-vscode"
    "dbaeumer.vscode-eslint"
    "ms-vscode.vscode-json"
    "christian-kohler.path-intellisense"
    "wix.vscode-import-cost"
    "ms-vscode.vscode-js-debug"
    "eamodio.gitlens"
    "orta.vscode-jest"
    "usernamehw.errorlens"
    "streetsidesoftware.code-spell-checker"
    "gruntfuggly.todo-tree"
    "alefragnani.Bookmarks"
    "oderwat.indent-rainbow"
)

# Contador para mostrar progreso
total=${#extensions[@]}
current=0

# Función para mostrar progreso
show_progress() {
    current=$((current + 1))
    echo "[$current/$total] Instalando: $1"
}

# Verificar si Cursor está instalado
if ! command -v cursor &> /dev/null; then
    echo "❌ Error: Cursor no está instalado o no está en el PATH"
    echo "Por favor, instala Cursor primero desde: https://cursor.sh/"
    exit 1
fi

echo "✅ Cursor detectado"
echo "📦 Instalando $total extensiones..."
echo ""

# Instalar cada extensión
for extension in "${extensions[@]}"; do
    show_progress "$extension"

    # Instalar extensión usando el comando de Cursor
    if cursor --install-extension "$extension"; then
        echo "   ✅ $extension instalada correctamente"
    else
        echo "   ❌ Error instalando $extension"
    fi

    echo ""
done

echo "=================================================="
echo "🎉 Instalación completada!"
echo ""
echo "📋 Extensiones instaladas:"
echo ""

# Mostrar lista de extensiones instaladas
for extension in "${extensions[@]}"; do
    echo "   • $extension"
done

echo ""
echo "💡 Consejos:"
echo "   • Reinicia Cursor para asegurar que todas las extensiones estén activas"
echo "   • Configura Prettier y ESLint según tus preferencias"
echo "   • Revisa la configuración de GitLens si usas Git"
echo ""
echo "🔧 Para desinstalar una extensión:"
echo "   cursor --uninstall-extension <extension-id>"
echo ""
echo "📚 Para ver extensiones instaladas:"
echo "   cursor --list-extensions"
echo ""
echo "🔧 Para configurar Code Spell Checker para español:"
echo "   ./configure_cursor_spellcheck.sh"
