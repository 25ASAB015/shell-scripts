#!/bin/bash

# Verificar que el script se ejecute como root
if [[ $EUID -ne 0 ]]; then
    echo "Este script debe ejecutarse como root. Usa 'sudo' o inicia sesión como root."
    exit 1
fi

# Solicitar nombre de usuario
read -p "Ingrese el nombre del nuevo usuario: " username

# Verificar si el usuario ya existe
if id "$username" &>/dev/null; then
    echo "El usuario '$username' ya existe. Abortando."
    exit 1
fi

# Solicitar contraseña de forma segura
read -sp "Ingrese la contraseña para $username: " password
echo ""
read -sp "Confirme la contraseña: " password_confirm
echo ""

# Verificar que las contraseñas coincidan
if [[ "$password" != "$password_confirm" ]]; then
    echo "Las contraseñas no coinciden. Abortando."
    exit 1
fi

# Crear el usuario
useradd -m -s /bin/bash "$username"

# Establecer la contraseña
echo "$username:$password" | chpasswd

# Definir grupos del sistema a excluir (grupos críticos que no deben modificarse)
excluded_groups=("root" "bin" "daemon" "mail" "ftp" "http" "nobody" "dbus" "systemd-journal" "systemd-network" "systemd-resolve" "systemd-timesync")

# Obtener todos los grupos existentes (excluyendo los del sistema y el grupo del usuario)
mapfile -t groups < <(getent group | awk -F: '{print $1}' | grep -v "^${username}$")

# Filtrar grupos excluidos
for exclude in "${excluded_groups[@]}"; do
    groups=("${groups[@]/$exclude}")
done

# Eliminar elementos vacíos del array
groups=("${groups[@]/}")

# Agregar el usuario a todos los grupos restantes
for group in "${groups[@]}"; do
    if getent group "$group" &>/dev/null; then
        usermod -aG "$group" "$username"
    fi
done

echo "✅ Usuario '$username' creado exitosamente."
echo "✅ Agregado a todos los grupos disponibles."

# Verificar grupos del usuario
echo "Grupos del usuario:"
groups "$username"
