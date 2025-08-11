#!/usr/bin/env bash
# ================================================================
#  Instalador Automático de Herramientas de Desarrollo
#  Profesional - Robusto - Con estilo empresarial
# ================================================================

set -euo pipefail

LOG_FILE="$HOME/instalador_dev.log"
ZSHRC="$HOME/.zshrc"

# --- Colores y estilos ---
BOLD="\033[1m"
DIM="\033[2m"
RESET="\033[0m"
GREEN="\033[32m"
RED="\033[31m"
YELLOW="\033[33m"
BLUE="\033[34m"

# --- Funciones utilitarias ---
log() { echo -e "${DIM}[$(date '+%Y-%m-%d %H:%M:%S')]${RESET} $*" | tee -a "$LOG_FILE"; }
info() { echo -e "${BLUE}${BOLD}ℹ $*${RESET}"; }
success() { echo -e "${GREEN}${BOLD}✔ $*${RESET}"; }
warn() { echo -e "${YELLOW}${BOLD}⚠ $*${RESET}"; }
error() { echo -e "${RED}${BOLD}✖ $*${RESET}" >&2; exit 1; }

check_command() {
    command -v "$1" >/dev/null 2>&1
}

is_npm_pkg_installed() {
    npm list -g --depth=0 "$1" >/dev/null 2>&1
}

is_pacman_pkg_installed() {
    pacman -Qi "$1" >/dev/null 2>&1
}

is_snap_pkg_installed() {
    snap list | grep -q "^$1 "
}

# --- Verificaciones previas ---
info "Verificando dependencias esenciales..."
if ! check_command npm; then
    error "npm no está instalado. Instálalo antes de continuar."
fi

if ! check_command paru; then
    warn "Paru no está instalado. Procediendo a instalarlo..."
    if ! check_command git; then
        info "Instalando git..."
        sudo pacman -S --needed --noconfirm git
    fi
    if ! is_pacman_pkg_installed base-devel; then
        info "Instalando base-devel..."
        sudo pacman -S --needed --noconfirm base-devel
    fi
    tmp_dir=$(mktemp -d)
    log "Clonando paru desde AUR en $tmp_dir..."
    git clone https://aur.archlinux.org/paru.git "$tmp_dir/paru"
    cd "$tmp_dir/paru"
    makepkg -si --noconfirm
    cd - >/dev/null
    rm -rf "$tmp_dir"
    success "Paru instalado correctamente."
fi

if ! check_command snap; then
    error "snap no está instalado. Instálalo antes de continuar."
fi

success "Todas las dependencias básicas están presentes."

log "Inicio de instalación..."

# --- Instalar paquetes npm ---
declare -A NPM_TOOLS=(
    ["task-master-ai"]="task-master --version"
    ["@qwen-code/qwen-code"]="qwen --version"
    ["@google/gemini-cli"]="gemini --version"
    ["@anthropic-ai/claude-code"]="claude --version"
)

info "Instalando paquetes npm globales..."
for pkg in "${!NPM_TOOLS[@]}"; do
    if is_npm_pkg_installed "$pkg"; then
        success "NPM: $pkg ya está instalado."
    else
        log "Instalando $pkg..."
        npm install -g "$pkg" && success "NPM: $pkg instalado correctamente."
    fi
    eval "${NPM_TOOLS[$pkg]}" || warn "No se pudo verificar la versión de $pkg."
done

# --- Instalar paquetes con paru ---
info "Instalando paquetes con paru..."
PARU_PKGS=(
    cursor-bin
    windsurf windsurf-features windsurf-marketplace
    kiro-bin
    crush-bin
    visual-studio-code-bin visual-studio-code-insiders-bin
)
for pkg in "${PARU_PKGS[@]}"; do
    if is_pacman_pkg_installed "$pkg"; then
        success "Paru: $pkg ya está instalado."
    else
        paru -S --needed --noconfirm "$pkg"
    fi
done


# --- Instalar snaps ---
info "Instalando paquetes con snap..."
declare -A SNAP_PKGS=(
    [intellij-idea-ultimate]="--classic"
    [datagrip]="--classic"
    [webstorm]="--classic"
    [rubymine]="--classic"
)
for pkg in "${!SNAP_PKGS[@]}"; do
    if is_snap_pkg_installed "$pkg"; then
        success "Snap: $pkg ya está instalado."
    else
        sudo snap install "$pkg" ${SNAP_PKGS[$pkg]}
    fi
done

log "Instalación finalizada."
success "✅ Todas las herramientas fueron instaladas correctamente."
info "Revisa el log en: $LOG_FILE"
info "Recuerda reiniciar tu terminal para aplicar los cambios."
