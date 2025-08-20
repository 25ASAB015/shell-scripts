#!/bin/bash

# Verificar que el script se ejecute como root
if [[ $EUID -ne 0 ]]; then
    echo "Este script debe ejecutarse como root. Usa 'sudo' o inicia sesión como root."
    exit 1
fi

# Obtener el nombre del usuario que ejecutó el script con sudo (el usuario 'arch' en tu caso)
CALLING_USER=$(logname)
if [ -z "$CALLING_USER" ]; then
    echo "No se pudo determinar el usuario que invocó sudo. Saliendo."
    exit 1
fi

echo "El script está siendo ejecutado por el usuario: $CALLING_USER"

# --- Solicitar Contraseña para Todos los Usuarios ---
read -sp "Ingrese la contraseña común para todos los usuarios: " common_password
echo ""
read -sp "Confirme la contraseña común: " common_password_confirm
echo ""

if [[ "$common_password" != "$common_password_confirm" ]]; then
    echo "Las contraseñas no coinciden. Abortando."
    exit 1
fi

# --- Nombres de Usuarios a Crear ---
declare -a usernames=(
    "usuario_uno"
    "usuario_dos"
    "usuario_tres"
    "usuario_cuatro"
    "usuario_cinco"
    "usuario_seis"
    "usuario_siete"
    "usuario_ocho"
    "usuario_nueve"
    "usuario_diez"
    "usuario_once"
    "usuario_doce"
    "usuario_trece"
    "usuario_catorce"
    "usuario_quince"
    "usuario_dieciséis"
    "usuario_diecisiete"
    "usuario_dieciocho"
    "usuario_diecinueve"
    "usuario_veinte"
    "usuario_veintiuno"
    "usuario_veintidos"
    "usuario_veintitres"
    "usuario_veinticuatro"
    "usuario_veinticinco"
    "usuario_veintiseis"
    "usuario_veintisiete"
    "usuario_veintiocho"
    "usuario_veintinueve"
    "usuario_treinta"
    "usuario_treintayuno"
)

declare -a created_users # Array para almacenar los nombres de los usuarios realmente creados en esta ejecución

echo "Iniciando la creación de usuarios..."

# --- Crear Usuarios y Añadir a Grupos Clave ---
for username in "${usernames[@]}"; do
    if id "$username" &>/dev/null; then
        echo "⚠️ El usuario '$username' ya existe. Saltando su creación."
    else
        useradd -m -s /bin/bash "$username"
        echo "$username:$common_password" | chpasswd
        echo "✅ Usuario '$username' creado exitosamente con directorio home."
        created_users+=("$username") # Añadir al array de usuarios creados
    fi
    
    # Añadir a todos los usuarios creados al grupo 'wheel' para acceso sudo
    if ! id -nG "$username" | grep -qw "wheel"; then
        usermod -aG wheel "$username"
        echo "✅ Usuario '$username' añadido al grupo 'wheel' (para sudo)."
    else
        echo "ℹ️ Usuario '$username' ya pertenece al grupo 'wheel'."
    fi
done

# --- Configurar Directorio Compartido en /opt ---
echo "Configurando el directorio compartido en /opt..."

SHARED_DIR="/opt/shared_data"
GROUP_NAME="sharedusers" # Nombre del grupo para controlar el acceso al directorio

# Crear el grupo si no existe
if ! getent group "$GROUP_NAME" &>/dev/null; then
    groupadd "$GROUP_NAME"
    echo "✅ Grupo '$GROUP_NAME' creado."
else
    echo "ℹ️ El grupo '$GROUP_NAME' ya existe."
fi

# Añadir todos los usuarios creados al nuevo grupo compartido
for user in "${created_users[@]}"; do
    if ! id -nG "$user" | grep -qw "$GROUP_NAME"; then
        usermod -aG "$GROUP_NAME" "$user"
        echo "✅ Usuario '$user' añadido al grupo '$GROUP_NAME'."
    else
        echo "ℹ️ Usuario '$user' ya pertenece al grupo '$GROUP_NAME'."
    fi
done

# Añadir el usuario que ejecutó el script (e.g., 'arch') al grupo sharedusers
if ! id -nG "$CALLING_USER" | grep -qw "$GROUP_NAME"; then
    usermod -aG "$GROUP_NAME" "$CALLING_USER"
    echo "✅ Usuario '$CALLING_USER' añadido al grupo '$GROUP_NAME'."
else
    echo "ℹ️ Usuario '$CALLING_USER' ya pertenece al grupo '$GROUP_NAME'."
fi


# Crear el directorio si no existe
if [ ! -d "$SHARED_DIR" ]; then
    mkdir -p "$SHARED_DIR"
    echo "✅ Directorio '$SHARED_DIR' creado."
else
    echo "ℹ️ Directorio '$SHARED_DIR' ya existe."
fi

# Establecer la propiedad del directorio al usuario root y al grupo compartido
chown root:"$GROUP_NAME" "$SHARED_DIR"

# Establecer permisos: rwx para el propietario y el grupo, nada para otros
# La 'g+s' (setgid) asegura que los nuevos archivos/directorios creados dentro hereden el grupo 'sharedusers'
chmod 2770 "$SHARED_DIR"
echo "✅ Permisos de '$SHARED_DIR' establecidos a 2770 (rwx para propietario/grupo, setgid)."
echo "✅ Propiedad de '$SHARED_DIR' establecida a root:$GROUP_NAME."

# --- Instalar acl y Configurar ACLs automáticamente ---
echo "Verificando e instalando el paquete 'acl'..."
if ! pacman -Qs acl &>/dev/null; then
    echo "Paquete 'acl' no encontrado. Intentando instalar..."
    pacman -S --noconfirm acl # --noconfirm para instalación silenciosa
    if [ $? -ne 0 ]; then
        echo "❌ Error: No se pudo instalar el paquete 'acl'. Por favor, instálelo manualmente y vuelva a ejecutar."
        exit 1
    fi
    echo "✅ Paquete 'acl' instalado exitosamente."
else
    echo "ℹ️ El paquete 'acl' ya está instalado."
fi

echo "Configurando ACLs en el directorio compartido para herencia de permisos..."
setfacl -Rdm g:"$GROUP_NAME":rwx "$SHARED_DIR"
setfacl -Rm g:"$GROUP_NAME":rwx "$SHARED_DIR"
echo "✅ ACLs configuradas exitosamente en '$SHARED_DIR'."


# --- Configurar Sudoers para acceso con contraseña al grupo wheel ---
# Eliminar el archivo que permitía NOPASSWD para el grupo wheel si existe
SUDOERS_FILE_NOPASSWD="/etc/sudoers.d/wheel_nopasswd"

echo "Asegurando que el grupo 'wheel' requiera contraseña para sudo..."
if [ -f "$SUDOERS_FILE_NOPASSWD" ]; then
    rm -f "$SUDOERS_FILE_NOPASSWD"
    echo "✅ Archivo '$SUDOERS_FILE_NOPASSWD' eliminado para asegurar que se pida contraseña."
else
    echo "ℹ️ El archivo '$SUDOERS_FILE_NOPASSWD' no existe, no es necesario eliminarlo."
fi

# Nota importante: La configuración por defecto de /etc/sudoers en Arch Linux (línea %wheel ALL=(ALL) ALL)
# es la que debería estar activa (o descomentada) para que esto funcione.
# Asumimos que tu sistema ya está configurado así, dado que tu usuario principal ya pide contraseña.
echo "✅ Se asume que /etc/sudoers ya tiene la línea '%wheel ALL=(ALL) ALL' activa."


# --- Configurar Grupos Adicionales (añadir usuarios a los grupos de los demás) ---
echo "Configurando grupos adicionales para los usuarios creados..."

for user_to_modify in "${created_users[@]}"; do
    echo "  -> Procesando grupos para '$user_to_modify'..."
    declare -a groups_to_add # Array temporal para grupos a añadir a este usuario

    # Añadir al grupo de cada uno de los *otros* usuarios creados por el script
    for other_user_group in "${created_users[@]}"; do
        if [[ "$user_to_modify" != "$other_user_group" ]]; then # No agregarse a su propio grupo primario
            if getent group "$other_user_group" &>/dev/null; then # Asegurarse de que el grupo primario del otro usuario exista
                groups_to_add+=("$other_user_group")
            fi
        fi
    done

    # Si hay grupos para añadir, aplicar
    if [ ${#groups_to_add[@]} -gt 0 ]; then
        # Obtener grupos actuales del usuario para no duplicar ni eliminar
        current_user_groups=$(id -nG "$user_to_modify" | tr ' ' '\n')
        
        # Filtrar solo los grupos que no están ya asignados al usuario
        declare -a final_groups_to_add
        for group in "${groups_to_add[@]}"; do
            if ! echo "$current_user_groups" | grep -qw "$group"; then
                final_groups_to_add+=("$group")
            fi
        done

        if [ ${#final_groups_to_add[@]} -gt 0 ]; then
            usermod -aG "$(IFS=,; echo "${final_groups_to_add[*]}")" "$user_to_modify"
            echo "     ✅ '$user_to_modify' agregado a los grupos: $(IFS=,; echo "${final_groups_to_add[*]}")"
        else
            echo "     ℹ️ '$user_to_modify' ya pertenece a todos los grupos de los otros usuarios."
        fi
    else
        echo "     ℹ️ No se encontraron otros usuarios creados para agregar a los grupos de '$user_to_modify'."
    fi
done

echo "----------------------------------------------------"
echo "🎉 ¡Script completado!"
echo "🎉 Se han creado/actualizado los usuarios de usuario_quince a usuario_treintayuno (si no existían)."
echo "🎉 Todos los usuarios tienen la misma contraseña y pertenecen a los grupos de los demás usuarios creados."
echo "🎉 **Los usuarios creados ahora tienen acceso 'sudo' y se les pedirá la contraseña.**"
echo "🎉 El directorio '$SHARED_DIR' ha sido configurado para escritura compartida por estos usuarios, con ACLs."
echo "----------------------------------------------------"

# Mensaje importante para el usuario que ejecutó el script
echo ""
echo "❗ IMPORTANTE: Para que los cambios de grupo para los nuevos usuarios surtan efecto,"
echo "❗ y para que puedan usar 'sudo' con contraseña,"
echo "❗ debes CERRAR Y VOLVER A INICIAR SESIÓN (o reiniciar tu sistema)."
echo ""

# --- Verificación final sin errores de subscript ---
echo "Verificación rápida de grupos y permisos:"
echo "---------------------------------------"

# Mostrar grupos de los usuarios creados (si hay alguno)
if [ ${#created_users[@]} -gt 0 ]; then
    echo "Grupos de algunos usuarios creados:"
    # Intentar mostrar los primeros 2 y los últimos 2 si existen
    if [ ${#created_users[@]} -ge 2 ]; then
        echo "  ${created_users[0]}: $(groups "${created_users[0]}")"
        echo "  ${created_users[1]}: $(groups "${created_users[1]}")"
        if [ ${#created_users[@]} -gt 2 ]; then # If more than 2 users, show the last two
            echo "  ${created_users[${#created_users[@]}-2]}: $(groups "${created_users[${#created_users[@]}-2]}")"
            echo "  ${created_users[${#created_users[@]}-1]}: $(groups "${created_users[${#created_users[@]}-1]}")"
        fi
    else # If only one user created, show that one
        echo "  ${created_users[0]}: $(groups "${created_users[0]}")"
    fi
else
    echo "ℹ️ No se crearon nuevos usuarios en esta ejecución (todos ya existían)."
fi

# Siempre mostrar grupos del usuario que ejecutó el script
echo "Grupos de $CALLING_USER: $(groups "$CALLING_USER")"

# Siempre mostrar permisos del directorio compartido y ACLs
echo "Permisos de $SHARED_DIR: $(ls -ld "$SHARED_DIR")"
echo "ACLs por defecto de $SHARED_DIR:"
getfacl "$SHARED_DIR" | grep '^default:'
