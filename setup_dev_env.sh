#!/bin/bash

# Este script automatiza la instalación de herramientas de desarrollo
# y configura las variables de entorno PATH en Arch Linux.
# Está diseñado para ser fácil de entender para usuarios sin experiencia técnica.

# --- Sección 1: Colores para una Salida más Bonita (solo para visualización) ---
# Usamos colores para que los mensajes en la terminal sean más claros:
# - verde para éxito, amarillo para advertencias, rojo para errores.
COLOR_GREEN='\033[0;32m'
COLOR_YELLOW='\033[0;33m'
COLOR_RED='\033[0;31m'
COLOR_NC='\033[0m' # No Color (restablece el color normal)

# Función para imprimir mensajes de estado
print_status() {
    echo -e "${COLOR_GREEN}✅ INFO: $1${COLOR_NC}" # Mensajes informativos en verde
}

print_warning() {
    echo -e "${COLOR_YELLOW}⚠️ WARNING: $1${COLOR_NC}" # Advertencias en amarillo
}

print_error() {
    echo -e "${COLOR_RED}❌ ERROR: $1${COLOR_NC}" # Errores en rojo
}

# --- Sección 2: Comprobaciones Iniciales (lo primero es lo primero) ---
# Nos aseguramos de que el script se ejecute con los permisos correctos
if [ "$EUID" -ne 0 ]; then
    print_warning "No estás ejecutando el script como root (sudo). Algunas instalaciones pueden fallar."
    print_warning "Considera ejecutarlo con 'sudo bash setup_dev_env.sh' o prepárate para introducir tu contraseña."
    sleep 3 # Espera 3 segundos para que el usuario lea el mensaje
fi

print_status "¡Hola! Empezando la configuración de tu entorno de desarrollo en Arch Linux. 🚀"
print_status "Primero, vamos a asegurarnos de que tu sistema esté al día."

# --- Sección 3: Actualizar el Sistema (mantener todo fresco) ---
# 'sudo pacman -Syu' actualiza la lista de paquetes y los paquetes instalados.
# Esto es como actualizar las apps en tu teléfono antes de instalar nuevas.
sudo pacman -Syu --noconfirm || print_error "Error al actualizar el sistema."

# --- Sección 4: Instalar Runtimes de Lenguajes (las bases) ---
# Estas son las herramientas fundamentales que otras utilidades necesitan para funcionar.
print_status "Instalando runtimes de lenguajes (Python, Node.js, Ruby, Elixir, Go, Rust, Lua)..."

# Python y Pip (para proselint, vint)
# 'python' es el lenguaje, 'python-pip' es su gestor de paquetes.
sudo pacman -S --noconfirm python python-pip || print_error "Error al instalar Python/Pip."

# Node.js y Npm (para prettier)
# 'nodejs' es el entorno, 'npm' es su gestor de paquetes.
sudo pacman -S --noconfirm nodejs npm || print_error "Error al instalar Node.js/Npm."

# Ruby (para reek)
sudo pacman -S --noconfirm ruby || print_error "Error al instalar Ruby."

# Erlang y Elixir (para credo, mix)
# Elixir necesita Erlang para funcionar.
sudo pacman -S --noconfirm erlang elixir || print_error "Error al instalar Erlang/Elixir."

# Go (para actionlint, golangci-lint, shfmt)
sudo pacman -S --noconfirm go || print_error "Error al instalar Go."

# Rust y Cargo (para stylua)
# 'rust' instala el compilador y 'cargo', su gestor de paquetes.
sudo pacman -S --noconfirm rust || print_error "Error al instalar Rust/Cargo."

# Lua (para stylua si no se usa cargo)
sudo pacman -S --noconfirm lua || print_error "Error al instalar Lua."

# Ctags (para 'tags' si es una utilidad general de etiquetas)
sudo pacman -S --noconfirm ctags || print_error "Error al instalar ctags."

# Aspell (para 'spell' y 'dictionary')
sudo pacman -S --noconfirm aspell aspell-en || print_error "Error al instalar Aspell."

# Pipx (para instalar aplicaciones Python de forma segura como proselint, vint)
# Es como un "app store" para herramientas de Python.
sudo pacman -S --noconfirm python-pipx || print_error "Error al instalar pipx."

# --- Sección 5: Instalar Herramientas Específicas (tus ayudantes de código) ---
print_status "Instalando herramientas de linting y formateo..."

# proselint (linter para prosa en inglés)
# Usamos pipx para instalarlo de forma aislada.
print_status "Instalando proselint..."
pipx install proselint || print_error "Error al instalar proselint con pipx."

# actionlint (linter para GitHub Actions)
print_status "Instalando actionlint..."
go install github.com/rhysd/actionlint/cmd/actionlint@latest || print_error "Error al instalar actionlint."

# credo (análisis de código para Elixir)
# Mix es el gestor de paquetes de Elixir. Lo instalamos en su entorno.
print_status "Instalando credo..."
mix local.hex --force || print_warning "No se pudo instalar hex para mix."
mix local.rebar --force || print_warning "No se pudo instalar rebar para mix."
# Esto instala credo a nivel global para Elixir
mix archive.install hex credo --force || print_error "Error al instalar credo."


# golangci-lint (agregador de linters para Go)
print_status "Instalando golangci-lint..."
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest || print_error "Error al instalar golangci-lint."

# hadolint (linter para Dockerfiles)
# Descargamos el binario y lo movemos a una ubicación en el PATH.
print_status "Instalando hadolint..."
HADOLINT_VERSION="2.12.0" # Puedes cambiar a la última versión
sudo wget -O /usr/local/bin/hadolint "https://github.com/hadolint/hadolint/releases/download/v${HADOLINT_VERSION}/hadolint-Linux-x86_64" \
    && sudo chmod +x /usr/local/bin/hadolint || print_error "Error al instalar hadolint."

# reek (detector de "olores" de código Ruby)
print_status "Instalando reek..."
gem install reek || print_error "Error al instalar reek."

# vint (linter para Vimscript)
# También usamos pipx para este.
print_status "Instalando vint..."
pipx install vim-vint || print_error "Error al instalar vint con pipx."

# prettier (formateador de código universal)
print_status "Instalando prettier..."
npm install -g prettier || print_error "Error al instalar prettier."

# shfmt (formateador de scripts de shell)
print_status "Instalando shfmt..."
go install mvdan.cc/sh/v3/cmd/shfmt@latest || print_error "Error al instalar shfmt."

# stylua (formateador de código Lua)
print_status "Instalando stylua..."
cargo install stylua || print_error "Error al instalar stylua."

# --- Sección 6: Configurar el PATH (¡la clave para que todo funcione!) ---
# 'PATH' le dice a tu terminal dónde buscar los programas que quieres ejecutar.
# Añadimos los directorios donde se instalan las herramientas.
print_status "Configurando las variables de entorno PATH en ~/.bashrc..."

# La variable BASHRC_CONFIG_START/END nos ayuda a mantener el archivo ordenado
BASHRC_CONFIG_START="# --- INICIO DE CONFIGURACION DE DEVTOOLS (gestionado por script) ---"
BASHRC_CONFIG_END="# --- FIN DE CONFIGURACION DE DEVTOOLS ---"

# Eliminar cualquier configuración anterior para evitar duplicados
sed -i "/$BASHRC_CONFIG_START/,/$BASHRC_CONFIG_END/d" ~/.bashrc

# Contenido a añadir al .bashrc
BASHRC_CONTENT="
${BASHRC_CONFIG_START}
# Asegurarse de que ~/.local/bin está en el PATH para herramientas como pipx, proselint, vint
[ -d \"\${HOME}/.local/bin\" ] && { export PATH=\"\${HOME}/.local/bin\${PATH:+:\${PATH}}\"; }

# Asegurarse de que los binarios de Go instalados por 'go install' estén en el PATH
[ -d \"\${HOME}/go/bin\" ] && { export PATH=\"\${HOME}/go/bin\${PATH:+:\${PATH}}\"; }

# Asegurarse de que los binarios de Cargo (Rust) estén en el PATH
[ -d \"\${HOME}/.cargo/bin\" ] && { export PATH=\"\${HOME}/.cargo/bin\${PATH:+:\${PATH}}\"; }

# Asegurarse de que los paquetes globales de NPM estén en el PATH
# (Si configuraste un prefijo npm diferente, ajusta la ruta)
[ -d \"\$(npm config get prefix)/bin\" ] && { export PATH=\"\$(npm config get prefix)/bin\${PATH:+:\${PATH}}\"; }

# Asegurarse de que los binarios de Ruby Gems estén en el PATH
# (La versión de Ruby puede variar, ajusta si es necesario)
[ -d \"\${HOME}/.local/share/gem/ruby/$(ruby -v | grep -oP 'ruby \K\d\.\d\.\d' | cut -d'.' -f1-2)\.0/bin\" ] && { export PATH=\"\${HOME}/.local/share/gem/ruby/$(ruby -v | grep -oP 'ruby \K\d\.\d\.\d' | cut -d'.' -f1-2)\.0/bin\${PATH:+:\${PATH}}\"; }

${BASHRC_CONFIG_END}
"
# Añadir el contenido al final de ~/.bashrc
echo "${BASHRC_CONTENT}" >> ~/.bashrc

# --- Sección 7: Recargar .bashrc (para que los cambios se apliquen) ---
# 'source ~/.bashrc' le dice a tu terminal que "lea" el archivo de nuevo.
# Es como refrescar la página de una web para ver los cambios.
print_status "Recargando ~/.bashrc para aplicar los cambios en el PATH. 🔄"
source ~/.bashrc

# --- Sección 8: Verificación Final (¡la prueba de fuego!) ---
print_status "Verificando que las herramientas están ahora disponibles..."
# Intentamos ejecutar cada comando para ver si se encuentran.
# No te preocupes si alguna falla, el script reportará qué pasó.

# Funciones de verificación
check_command() {
    COMMAND=$1
    if command -v "$COMMAND" &> /dev/null; then
        print_status "✔ '$COMMAND' encontrado y ejecutable."
    else
        print_error "❌ '$COMMAND' NO encontrado. Revisa la instalación."
    fi
}


      pipx install beautysh
      pipx install black
      pipx install ruff

check_command proselint
check_command actionlint
check_command mix
check_command credo # Credo usa mix, pero es bueno verificarlo directamente
check_command golangci-lint
check_command hadolint
check_command reek
check_command vint
check_command prettier
check_command shfmt
check_command stylua
check_command ctags # Para 'tags'
check_command aspell # Para 'spell' y 'dictionary'
check_command printenv # Utilidad básica, debería estar siempre

print_status "¡Configuración completada! 🎉"
print_status "Por favor, abre una NUEVA terminal para asegurarte de que todos los cambios estén activos."
print_status "Si alguna herramienta sigue sin encontrarse, revisa los mensajes de error anteriores."
