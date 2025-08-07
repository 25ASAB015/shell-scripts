#!/bin/bash

# =============================================================================
# Script Generador de Llaves SSH y GPG para GitHub
# Versión: 2.0
# Autor: Asistente Claude
# Descripción: Script profesional para generar llaves SSH y GPG optimizadas
#              para GitHub con validación completa de errores y guías para
#              usuarios sin experiencia previa.
# =============================================================================

# Configuración de colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Configuración global
SCRIPT_DIR="$HOME/.github-keys-setup"
BACKUP_DIR="$SCRIPT_DIR/backup-$(date +%Y%m%d_%H%M%S)"
LOG_FILE="$SCRIPT_DIR/setup.log"

# =============================================================================
# FUNCIONES AUXILIARES
# =============================================================================

# Función para logging
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Función para mostrar encabezado
show_header() {
    clear
    echo -e "${CYAN}=============================================================================${NC}"
    echo -e "${WHITE}                 🔐 GENERADOR DE LLAVES SSH Y GPG PARA GITHUB${NC}"
    echo -e "${CYAN}=============================================================================${NC}"
    echo -e "${YELLOW}Versión 2.0 - Script Profesional para Configuración Completa${NC}"
    echo -e "${CYAN}=============================================================================${NC}"
    echo ""
}

# Función para mostrar separador
show_separator() {
    echo -e "${BLUE}─────────────────────────────────────────────────────────────────────────────${NC}"
}

# Función para mostrar mensajes de éxito
success() {
    echo -e "${GREEN}✅ $1${NC}"
    log "SUCCESS: $1"
}

# Función para mostrar mensajes de error
error() {
    echo -e "${RED}❌ ERROR: $1${NC}"
    log "ERROR: $1"
}

# Función para mostrar advertencias
warning() {
    echo -e "${YELLOW}⚠️  ADVERTENCIA: $1${NC}"
    log "WARNING: $1"
}

# Función para mostrar información
info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
    log "INFO: $1"
}

# Función para preguntar sí/no con valor por defecto
ask_yes_no() {
    local prompt="$1"
    local default="${2:-y}"
    local response

    while true; do
        if [[ "$default" == "y" ]]; then
            echo -ne "${CYAN}$prompt [Y/n]: ${NC}"
        else
            echo -ne "${CYAN}$prompt [y/N]: ${NC}"
        fi

        read -r response
        response=${response:-$default}

        case ${response,,} in
            y|yes) return 0 ;;
            n|no) return 1 ;;
            *) echo -e "${RED}Por favor responde 'y' o 'n'${NC}" ;;
        esac
    done
}

# Función para validar email
validate_email() {
    local email="$1"
    local regex="^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"

    if [[ $email =~ $regex ]]; then
        return 0
    else
        return 1
    fi
}

# Función para verificar dependencias
check_dependencies() {
    info "Verificando dependencias del sistema..."

    local missing_deps=()
    local deps=("ssh-keygen" "gpg" "git" "xclip")

    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing_deps+=("$dep")
        fi
    done

    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        error "Faltan las siguientes dependencias:"
        for dep in "${missing_deps[@]}"; do
            echo -e "  ${RED}• $dep${NC}"
        done

        echo ""
        info "Para instalar las dependencias faltantes:"
        echo -e "${YELLOW}Ubuntu/Debian:${NC} sudo apt update && sudo apt install -y git openssh-client gnupg xclip"
        echo -e "${YELLOW}CentOS/RHEL:${NC}  sudo yum install -y git openssh-clients gnupg2 xclip"
        echo -e "${YELLOW}Fedora:${NC}       sudo dnf install -y git openssh-clients gnupg2 xclip"
        echo -e "${YELLOW}macOS:${NC}        brew install git gnupg"
        echo ""
        return 1
    fi

    success "Todas las dependencias están instaladas"
    return 0
}

# Función para crear directorio de trabajo
setup_directories() {
    info "Configurando directorios de trabajo..."

    if [[ ! -d "$SCRIPT_DIR" ]]; then
        mkdir -p "$SCRIPT_DIR" || {
            error "No se pudo crear el directorio $SCRIPT_DIR"
            return 1
        }
    fi

    mkdir -p "$BACKUP_DIR" || {
        error "No se pudo crear el directorio de backup"
        return 1
    }

    success "Directorios configurados correctamente"
    return 0
}

# Función para hacer backup de llaves existentes
backup_existing_keys() {
    info "Verificando llaves SSH existentes..."

    local ssh_files=("$HOME/.ssh/id_rsa" "$HOME/.ssh/id_rsa.pub" "$HOME/.ssh/id_ed25519" "$HOME/.ssh/id_ed25519.pub")
    local backup_made=false

    for file in "${ssh_files[@]}"; do
        if [[ -f "$file" ]]; then
            if [[ "$backup_made" == false ]]; then
                warning "Se encontraron llaves SSH existentes"
                if ask_yes_no "¿Deseas hacer un backup de las llaves existentes antes de continuar?"; then
                    info "Creando backup de llaves existentes..."
                fi
                backup_made=true
            fi

            cp "$file" "$BACKUP_DIR/" 2>/dev/null && {
                success "Backup creado: $(basename "$file")"
            }
        fi
    done

    return 0
}

# Función para recopilar información del usuario
collect_user_info() {
    show_separator
    echo -e "${WHITE}📝 INFORMACIÓN DEL USUARIO${NC}"
    show_separator

    while true; do
        echo -ne "${CYAN}Ingresa tu email de GitHub: ${NC}"
        read -r USER_EMAIL

        if [[ -z "$USER_EMAIL" ]]; then
            error "El email no puede estar vacío"
            continue
        fi

        if validate_email "$USER_EMAIL"; then
            break
        else
            error "Email inválido. Por favor ingresa un email válido"
        fi
    done

    while true; do
        echo -ne "${CYAN}Ingresa tu nombre completo para Git: ${NC}"
        read -r USER_NAME

        if [[ -n "$USER_NAME" ]]; then
            break
        else
            error "El nombre no puede estar vacío"
        fi
    done

    success "Información del usuario recopilada"
    return 0
}

# Función para generar llave SSH
generate_ssh_key() {
    show_separator
    echo -e "${WHITE}🔑 GENERACIÓN DE LLAVE SSH${NC}"
    show_separator

    info "Generando llave SSH Ed25519 (recomendada por GitHub)..."

    # Asegurar que existe el directorio .ssh
    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"

    # Generar llave SSH
    ssh-keygen -t ed25519 -C "$USER_EMAIL" -f "$HOME/.ssh/id_ed25519" -N "" || {
        error "No se pudo generar la llave SSH"
        return 1
    }

    # Configurar permisos
    chmod 600 "$HOME/.ssh/id_ed25519"
    chmod 644 "$HOME/.ssh/id_ed25519.pub"

    success "Llave SSH generada exitosamente"

    # Preguntar si desea copiar la llave SSH al portapapeles
    if ask_yes_no "¿Deseas copiar la llave SSH al portapapeles ahora?"; then
        if command -v xclip &> /dev/null; then
            cat "$HOME/.ssh/id_ed25519.pub" | xclip -selection clipboard
            success "Llave SSH copiada al portapapeles"
        elif command -v pbcopy &> /dev/null; then
            cat "$HOME/.ssh/id_ed25519.pub" | pbcopy
            success "Llave SSH copiada al portapapeles"
        else
            warning "No se pudo copiar automáticamente. Copia manualmente la llave SSH mostrada más adelante."
        fi
    fi

    # Iniciar ssh-agent y agregar llave
    info "Configurando ssh-agent..."
    eval "$(ssh-agent -s)" &>/dev/null
    ssh-add "$HOME/.ssh/id_ed25519" &>/dev/null || {
        warning "No se pudo agregar la llave al ssh-agent automáticamente"
    }

    success "Llave SSH configurada en ssh-agent"
    return 0
}

# Función para generar llave GPG
generate_gpg_key() {
    show_separator
    echo -e "${WHITE}🔐 GENERACIÓN DE LLAVE GPG${NC}"
    show_separator

    info "Generando llave GPG para firmar commits..."

    # Crear archivo de configuración temporal para GPG
    local gpg_config=$(mktemp)
    cat > "$gpg_config" << EOF
%echo Generando llave GPG para GitHub
Key-Type: RSA
Key-Length: 4096
Subkey-Type: RSA
Subkey-Length: 4096
Name-Real: $USER_NAME
Name-Email: $USER_EMAIL
Expire-Date: 2y
%no-protection
%commit
%echo Llave GPG generada exitosamente
EOF

    # Generar llave GPG
    if gpg --batch --generate-key "$gpg_config" &>/dev/null; then
        success "Llave GPG generada exitosamente"
        rm "$gpg_config"
    else
        error "No se pudo generar la llave GPG"
        rm "$gpg_config"
        return 1
    fi

    # Obtener ID de la llave GPG
    GPG_KEY_ID=$(gpg --list-secret-keys --keyid-format=long "$USER_EMAIL" 2>/dev/null | grep 'sec' | head -n1 | sed 's/.*\/\([A-Z0-9]*\).*/\1/')

    if [[ -z "$GPG_KEY_ID" ]]; then
        error "No se pudo obtener el ID de la llave GPG"
        return 1
    fi

    success "ID de llave GPG obtenido: $GPG_KEY_ID"
    return 0
}

# Función para instalar Git Credential Manager
install_git_credential_manager() {
    info "Verificando Git Credential Manager..."

    # Verificar si ya está instalado
    if git config --global --get credential.helper | grep -q "manager"; then
        success "Git Credential Manager ya está configurado"
        return 0
    fi

    local os_type=$(uname -s)
    case $os_type in
        "Linux")
            info "Detectado sistema Linux"
            if command -v apt &> /dev/null; then
                info "Instalando Git Credential Manager via apt..."
                if ask_yes_no "¿Deseas instalar Git Credential Manager? (Recomendado para evitar solicitudes de contraseña)"; then
                    echo -e "${YELLOW}Ejecutando: sudo apt update && sudo apt install -y git-credential-manager${NC}"
                    sudo apt update && sudo apt install -y git-credential-manager &>/dev/null || {
                        warning "No se pudo instalar via apt. Intentando descarga directa..."
                        install_gcm_direct_linux
                    }
                fi
            elif command -v yum &> /dev/null || command -v dnf &> /dev/null; then
                info "Sistema RedHat/CentOS/Fedora detectado"
                if ask_yes_no "¿Deseas descargar e instalar Git Credential Manager manualmente?"; then
                    install_gcm_direct_linux
                fi
            else
                warning "Gestor de paquetes no soportado. Configurando credential helper básico."
                git config --global credential.helper store
            fi
            ;;
        "Darwin")
            info "Detectado macOS"
            if command -v brew &> /dev/null; then
                if ask_yes_no "¿Deseas instalar Git Credential Manager via Homebrew?"; then
                    brew install --cask git-credential-manager &>/dev/null || {
                        warning "No se pudo instalar via Homebrew"
                    }
                fi
            else
                info "Homebrew no encontrado. Usando credential helper nativo de macOS"
                git config --global credential.helper osxkeychain
            fi
            ;;
        *)
            warning "Sistema operativo no reconocido. Configurando credential helper básico."
            git config --global credential.helper store
            ;;
    esac

    return 0
}

# Función para instalar GCM directamente en Linux
install_gcm_direct_linux() {
    info "Descargando Git Credential Manager directamente..."
    local gcm_version="2.4.1"
    local gcm_url="https://github.com/git-ecosystem/git-credential-manager/releases/download/v${gcm_version}/gcm-linux_amd64.${gcm_version}.deb"
    local temp_deb=$(mktemp)

    if command -v wget &> /dev/null; then
        wget -q "$gcm_url" -O "$temp_deb" && {
            sudo dpkg -i "$temp_deb" &>/dev/null || {
                warning "Error instalando .deb. Configurando credential helper básico."
                git config --global credential.helper store
            }
        }
    elif command -v curl &> /dev/null; then
        curl -sL "$gcm_url" -o "$temp_deb" && {
            sudo dpkg -i "$temp_deb" &>/dev/null || {
                warning "Error instalando .deb. Configurando credential helper básico."
                git config --global credential.helper store
            }
        }
    else
        warning "No se encontró wget o curl. Configurando credential helper básico."
        git config --global credential.helper store
    fi

    rm -f "$temp_deb"
}

# Función para generar archivo .gitconfig completo
generate_gitconfig() {
    info "Generando archivo .gitconfig profesional..."

    local gitconfig_path="$HOME/.gitconfig"
    local backup_suffix=".backup-$(date +%Y%m%d_%H%M%S)"

    # Hacer backup del .gitconfig existente
    if [[ -f "$gitconfig_path" ]]; then
        warning "Se encontró un archivo .gitconfig existente"
        if ask_yes_no "¿Deseas hacer backup del .gitconfig actual antes de reemplazarlo?"; then
            cp "$gitconfig_path" "${gitconfig_path}${backup_suffix}"
            success "Backup creado: ${gitconfig_path}${backup_suffix}"
        fi
    fi

    # Determinar credential helper
    local credential_helper="manager"
    local os_type=$(uname -s)

    case $os_type in
        "Darwin")
            if ! command -v git-credential-manager &> /dev/null; then
                credential_helper="osxkeychain"
            fi
            ;;
        "Linux")
            if ! command -v git-credential-manager &> /dev/null; then
                credential_helper="store"
            fi
            ;;
    esac

    # Generar .gitconfig completo
    cat > "$gitconfig_path" << EOF
# ============================================================================
# Configuración Git Profesional
# Generado automáticamente el $(date)
# Usuario: $USER_NAME <$USER_EMAIL>
# ============================================================================

[user]
	name = $USER_NAME
	email = $USER_EMAIL$(if [[ -n "$GPG_KEY_ID" ]]; then echo "
	signingkey = $GPG_KEY_ID"; fi)

[commit]$(if [[ -n "$GPG_KEY_ID" ]]; then echo "
	gpgsign = true"; fi)
	template = ~/.gitmessage

[credential]
	helper = $credential_helper

[init]
	defaultBranch = main

[core]
	editor = nano
	autocrlf = false
	filemode = true
	ignorecase = false
	precomposeUnicode = true
	quotepath = false

[push]
	default = simple
	followTags = true
	autoSetupRemote = true

[pull]
	rebase = false
	ff = only

[fetch]
	prune = true
	pruneTags = true

[merge]
	tool = vimdiff
	conflictstyle = diff3

[diff]
	tool = vimdiff
	algorithm = histogram
	colorMoved = default

[status]
	showUntrackedFiles = all

[branch]
	autoSetupMerge = always
	autoSetupRebase = never

[rerere]
	enabled = true

[help]
	autoCorrect = 1

[color]
	ui = auto
	branch = auto
	diff = auto
	status = auto
	showBranch = auto

[color "branch"]
	current = yellow reverse
	local = yellow
	remote = green

[color "diff"]
	meta = yellow bold
	frag = magenta bold
	old = red bold
	new = green bold

[color "status"]
	added = yellow
	changed = green
	untracked = cyan

[alias]
	# Aliases básicos
	st = status -s
	co = checkout
	br = branch
	ci = commit
	df = diff
	dc = diff --cached
	lg = log --oneline --decorate --graph --all
	ls = log --pretty=format:"%C(yellow)%h%Cred%d\\\\ %Creset%s%Cblue\\\\ [%cn]" --decorate
	ll = log --pretty=format:"%C(yellow)%h%Cred%d\\\\ %Creset%s%Cblue\\\\ [%cn]" --decorate --numstat

	# Aliases avanzados
	unstage = reset HEAD --
	last = log -1 HEAD
	visual = !gitk
	type = cat-file -t
	dump = cat-file -p

	# Aliases para trabajo con ramas
	branches = branch -a
	remotes = remote -v
	tags = tag -l

	# Aliases para limpieza
	cleanup = "!git branch --merged | grep -v '\\*\\|main\\|master\\|develop' | xargs -n 1 git branch -d"

	# Aliases para estadísticas
	stats = shortlog -sn
	contributors = shortlog -s -n

	# Aliases para GitHub
	hub = !gh
	pr = !gh pr
	issue = !gh issue

[url "git@github.com:"]
	insteadOf = https://github.com/

[github]
	user = $(echo "$USER_EMAIL" | cut -d'@' -f1)

# Configuración específica para diferentes repositorios
# Descomenta y modifica según necesites:
# [includeIf "gitdir:~/work/"]
#     path = ~/.gitconfig-work
# [includeIf "gitdir:~/personal/"]
#     path = ~/.gitconfig-personal
EOF

    success "Archivo .gitconfig generado exitosamente"

    # Crear plantilla de mensaje de commit
    create_commit_template

    return 0
}

# Función para crear plantilla de mensaje de commit
create_commit_template() {
    local gitmessage_path="$HOME/.gitmessage"

    info "Creando plantilla de mensaje de commit..."

    cat > "$gitmessage_path" << 'EOF'
# <tipo>(<alcance>): <descripción corta>
#
# <descripción detallada>
#
# <footer>

# Tipos válidos:
# feat:     Nueva funcionalidad
# fix:      Corrección de bug
# docs:     Cambios en documentación
# style:    Cambios de formato (espacios, comas, etc)
# refactor: Refactorización de código
# test:     Agregando tests
# chore:    Cambios en build, herramientas auxiliares, etc
#
# Ejemplo:
# feat(auth): agregar autenticación con Google OAuth
#
# Implementa login/logout usando Google OAuth 2.0
# - Agrega botón de login con Google
# - Maneja tokens y refresh automático
# - Agrega middleware de autenticación
#
# Closes #123
EOF

    success "Plantilla de commit creada en ~/.gitmessage"
}

# Función para configurar Git
configure_git() {
    show_separator
    echo -e "${WHITE}⚙️  CONFIGURACIÓN DE GIT${NC}"
    show_separator

    info "Configurando Git con información profesional..."

    # Instalar/configurar Git Credential Manager
    install_git_credential_manager

    # Generar archivo .gitconfig completo
    generate_gitconfig || {
        error "No se pudo generar el archivo .gitconfig"
        return 1
    }

    # Configurar Git Credential Manager específicamente
    if command -v git-credential-manager &> /dev/null; then
        git config --global credential.helper manager
        success "Git Credential Manager configurado correctamente"
    fi

    success "Configuración Git completada exitosamente"
    return 0
}

# Función para mostrar las llaves generadas
display_keys() {
    show_separator
    echo -e "${WHITE}📋 LLAVES GENERADAS${NC}"
    show_separator

    echo -e "${YELLOW}1. LLAVE SSH PÚBLICA (para agregar a GitHub):${NC}"
    echo -e "${CYAN}─────────────────────────────────────────────────────────────────${NC}"

    if [[ -f "$HOME/.ssh/id_ed25519.pub" ]]; then
        cat "$HOME/.ssh/id_ed25519.pub"
        echo ""

        # Intentar copiar al clipboard
        if command -v xclip &> /dev/null; then
            cat "$HOME/.ssh/id_ed25519.pub" | xclip -selection clipboard
            success "Llave SSH copiada al portapapeles"
        elif command -v pbcopy &> /dev/null; then
            cat "$HOME/.ssh/id_ed25519.pub" | pbcopy
            success "Llave SSH copiada al portapapeles"
        fi
    else
        error "No se encontró la llave SSH pública"
    fi

    echo ""
    echo -e "${YELLOW}2. LLAVE GPG PÚBLICA (para agregar a GitHub):${NC}"
    echo -e "${CYAN}─────────────────────────────────────────────────────────────────${NC}"

    if [[ -n "$GPG_KEY_ID" ]]; then
        gpg --armor --export "$GPG_KEY_ID"
        echo ""

        # Crear archivo temporal con la llave GPG
        local gpg_temp=$(mktemp)
        gpg --armor --export "$GPG_KEY_ID" > "$gpg_temp"

        # Intentar copiar al clipboard (para la segunda copia)
        if ask_yes_no "¿Deseas copiar la llave GPG al portapapeles ahora?"; then
            if command -v xclip &> /dev/null; then
                cat "$gpg_temp" | xclip -selection clipboard
                success "Llave GPG copiada al portapapeles"
            elif command -v pbcopy &> /dev/null; then
                cat "$gpg_temp" | pbcopy
                success "Llave GPG copiada al portapapeles"
            else
                warning "No se pudo copiar automáticamente. Copia manualmente el texto de arriba."
            fi
        fi

        rm "$gpg_temp"
    else
        warning "No se generó llave GPG"
    fi
}

# Función para guardar llaves en archivos
save_keys_to_files() {
    show_separator
    echo -e "${WHITE}💾 GUARDANDO LLAVES EN ARCHIVOS${NC}"
    show_separator

    local output_dir="$SCRIPT_DIR/keys-$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$output_dir"

    # Guardar llave SSH
    if [[ -f "$HOME/.ssh/id_ed25519.pub" ]]; then
        cp "$HOME/.ssh/id_ed25519.pub" "$output_dir/ssh_public_key.txt"
        success "Llave SSH guardada en: $output_dir/ssh_public_key.txt"
    fi

    # Guardar llave GPG
    if [[ -n "$GPG_KEY_ID" ]]; then
        gpg --armor --export "$GPG_KEY_ID" > "$output_dir/gpg_public_key.txt"
        success "Llave GPG guardada en: $output_dir/gpg_public_key.txt"
    fi

    # Crear archivo de información
    cat > "$output_dir/key_info.txt" << EOF
INFORMACIÓN DE LLAVES GENERADAS
===============================

Fecha de generación: $(date)
Usuario: $USER_NAME
Email: $USER_EMAIL
GPG Key ID: $GPG_KEY_ID

INSTRUCCIONES:
1. Agrega la llave SSH a tu cuenta de GitHub en: https://github.com/settings/ssh/new
2. Agrega la llave GPG a tu cuenta de GitHub en: https://github.com/settings/gpg/new
3. Las llaves están guardadas en este directorio para referencia futura

NOTA: Mantén estos archivos seguros y no los compartas públicamente.
EOF

    success "Información guardada en: $output_dir/key_info.txt"
    info "Directorio de salida: $output_dir"
}

# Función para mostrar instrucciones finales
show_final_instructions() {
    show_separator
    echo -e "${WHITE}📚 INSTRUCCIONES PARA GITHUB${NC}"
    show_separator

    echo -e "${CYAN}Para completar la configuración en GitHub:${NC}"
    echo ""
    echo -e "${YELLOW}1. AGREGAR LLAVE SSH:${NC}"
    echo -e "   • Ve a: ${BLUE}https://github.com/settings/ssh/new${NC}"
    echo -e "   • Título: $(hostname) - $(date +%Y-%m-%d)"
    echo -e "   • Pega la llave SSH pública mostrada arriba"
    echo ""
    echo -e "${YELLOW}2. AGREGAR LLAVE GPG:${NC}"
    echo -e "   • Ve a: ${BLUE}https://github.com/settings/gpg/new${NC}"
    echo -e "   • Pega la llave GPG pública mostrada arriba"
    echo ""
    echo -e "${YELLOW}3. VERIFICAR CONFIGURACIÓN:${NC}"
    echo -e "   • SSH: ${BLUE}ssh -T git@github.com${NC}"
    echo -e "   • GPG: Haz un commit y verifica que aparezca como 'Verified'"
    echo ""
    echo -e "${YELLOW}4. ARCHIVOS GENERADOS:${NC}"
    echo -e "   • ${BLUE}~/.gitconfig${NC} - Configuración profesional de Git"
    echo -e "   • ${BLUE}~/.gitmessage${NC} - Plantilla para mensajes de commit"
    echo -e "   • ${BLUE}~/.ssh/config${NC} - Configuración SSH para GitHub"
    echo ""
    echo -e "${YELLOW}5. CREDENTIAL MANAGER:${NC}"
    echo -e "   • Git Credential Manager configurado para evitar solicitud de contraseñas"
    echo -e "   • En el primer push, se abrirá el navegador para autenticar con GitHub"
    echo ""
    echo -e "${GREEN}¡Configuración completada exitosamente!${NC}"
    echo -e "${CYAN}Tu entorno de desarrollo está listo para trabajar con GitHub de forma profesional.${NC}"
}

# Función para crear script de configuración del ssh-agent
create_ssh_agent_script() {
    local ssh_config="$HOME/.ssh/config"
    local bashrc_addition="$SCRIPT_DIR/bashrc_addition.txt"

    info "Creando configuración permanente para ssh-agent..."

    # Crear configuración SSH si no existe
    if [[ ! -f "$ssh_config" ]]; then
        cat > "$ssh_config" << EOF
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519
    IdentitiesOnly yes
EOF
        chmod 600 "$ssh_config"
        success "Archivo de configuración SSH creado"
    fi

    # Crear adición para .bashrc/.zshrc
    cat > "$bashrc_addition" << 'EOF'
# GitHub SSH Agent Configuration (generado automáticamente)
if [ -f ~/.ssh/id_ed25519 ]; then
    eval "$(ssh-agent -s)" &>/dev/null
    ssh-add ~/.ssh/id_ed25519 &>/dev/null
fi
EOF

    echo -e "${YELLOW}Para que ssh-agent se inicie automáticamente, agrega estas líneas a tu ~/.bashrc o ~/.zshrc:${NC}"
    echo -e "${CYAN}─────────────────────────────────────────────────────────────────${NC}"
    cat "$bashrc_addition"
    echo -e "${CYAN}─────────────────────────────────────────────────────────────────${NC}"

    if ask_yes_no "¿Deseas que el script agregue automáticamente esta configuración a tu ~/.bashrc?"; then
        if [[ -f "$HOME/.bashrc" ]]; then
            echo "" >> "$HOME/.bashrc"
            cat "$bashrc_addition" >> "$HOME/.bashrc"
            success "Configuración agregada a ~/.bashrc"
        else
            warning "No se encontró ~/.bashrc. Agrega manualmente la configuración mostrada arriba."
        fi
    fi
}

# Función para test de conectividad
test_github_connection() {
    show_separator
    echo -e "${WHITE}🧪 PRUEBA DE CONECTIVIDAD${NC}"
    show_separator

    if ask_yes_no "¿Deseas probar la conexión SSH con GitHub ahora?"; then
        info "Probando conexión SSH con GitHub..."

        # Test SSH connection
        ssh_output=$(ssh -T git@github.com 2>&1)
        ssh_exit_code=$?

        if [[ $ssh_exit_code -eq 1 ]] && [[ $ssh_output == *"successfully authenticated"* ]]; then
            success "¡Conexión SSH con GitHub exitosa!"
            echo -e "${GREEN}$ssh_output${NC}"
        else
            warning "La conexión SSH falló o está pendiente de configuración"
            echo -e "${YELLOW}Salida: $ssh_output${NC}"
            echo -e "${BLUE}Asegúrate de haber agregado la llave SSH a tu cuenta de GitHub${NC}"
        fi
    fi
}

# =============================================================================
# FUNCION PRINCIPAL
# =============================================================================

main() {
    # Mostrar encabezado
    show_header

    # Crear archivo de log
    mkdir -p "$(dirname "$LOG_FILE")"
    log "=== INICIO DE SESIÓN ==="

    # Verificar dependencias
    if ! check_dependencies; then
        exit 1
    fi

    # Configurar directorios
    if ! setup_directories; then
        exit 1
    fi

    # Hacer backup de llaves existentes
    backup_existing_keys

    # Recopilar información del usuario
    if ! collect_user_info; then
        exit 1
    fi

    # Generar llave SSH
    if ! generate_ssh_key; then
        exit 1
    fi

    # Generar llave GPG
    if ask_yes_no "¿Deseas generar también una llave GPG para firmar commits?"; then
        generate_gpg_key
    fi

    # Configurar Git
    if ! configure_git; then
        exit 1
    fi

    # Crear configuración ssh-agent
    create_ssh_agent_script

    # Mostrar llaves generadas
    display_keys

    # Guardar llaves en archivos
    if ask_yes_no "¿Deseas guardar las llaves en archivos para referencia futura?"; then
        save_keys_to_files
    fi

    # Probar conectividad
    test_github_connection

    # Mostrar instrucciones finales
    show_final_instructions

    log "=== FIN DE SESIÓN EXITOSA ==="

    echo ""
    success "¡Script completado exitosamente!"
    info "Log guardado en: $LOG_FILE"
}

# Función para manejo de señales
cleanup() {
    echo ""
    warning "Script interrumpido por el usuario"
    log "Script interrumpido por señal"
    exit 130
}

# Configurar manejo de señales
trap cleanup SIGINT SIGTERM

# Ejecutar función principal
main "$@"
