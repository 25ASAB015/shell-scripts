#!/bin/bash

# ====================================================================
# SCRIPT DE MONTAJE AUTOMATIZADO PARA DISCOS NTFS EN LINUX
#
# Autor: Gemini
# Descripción: Monta una partición NTFS con permisos de escritura
#              para el usuario actual, resolviendo problemas de
#              propietario y permisos.
# ====================================================================

# Colores para la salida en pantalla
VERDE='\033[0;32m'
ROJO='\033[0;31m'
AZUL='\033[0;34m'
AMARILLO='\033[1;33m'
NORMAL='\033[0m'

# ==================== Funciones de utilidad ========================

# Imprime un mensaje de éxito
function exito() {
    echo -e "${VERDE}[✓]${NORMAL} $1"
}

# Imprime un mensaje de error y sale del script
function error_y_salir() {
    echo -e "${ROJO}[✗]${NORMAL} $1"
    exit 1
}

# Imprime un mensaje de advertencia
function advertencia() {
    echo -e "${AMARILLO}[!]${NORMAL} $1"
}

# Imprime un encabezado de sección
function encabezado() {
    echo -e "\n${AZUL}====================================================================${NORMAL}"
    echo -e "${AZUL}  $1${NORMAL}"
    echo -e "${AZUL}====================================================================${NORMAL}\n"
}

# ==================== Lógica principal del script ==================

encabezado "Automatización de Montaje de Dispositivos NTFS"

# 1. Comprobar permisos de root
if [[ $EUID -ne 0 ]]; then
   error_y_salir "Este script debe ejecutarse como root. Usa 'sudo'."
fi

# 2. Definir el dispositivo, el punto de montaje y el usuario
#    El usuario debe introducir el nombre del dispositivo, por ejemplo 'sdb'
read -p "Ingresa el nombre del dispositivo a montar (ej. sdb): " DISPOSITIVO

#PUNTO_MONTAJE="/run/media/$USER/NTFS_Externo"
PUNTO_MONTAJE="/run/media/$USER/1D8A846764B72660"
USUARIO=$(id -u)
GRUPO=$(id -g)

# 3. Validar si el dispositivo existe
if [[ ! -e "/dev/$DISPOSITIVO" ]]; then
    error_y_salir "El dispositivo /dev/$DISPOSITIVO no existe. Verifica el nombre con 'lsblk'."
fi

encabezado "Analizando y Preparando el Dispositivo"

# 4. Encontrar la partición NTFS automáticamente
PARTICION=$(lsblk -no NAME,FSTYPE "/dev/$DISPOSITIVO" | grep -i "ntfs" | awk '{print $1}')

if [[ -z "$PARTICION" ]]; then
    error_y_salir "No se encontró una partición NTFS en /dev/$DISPOSITIVO."
else
    exito "Partición NTFS encontrada: /dev/$PARTICION"
fi

# 5. Desmontar la partición si ya está montada
if mountpoint -q "/dev/$PARTICION"; then
    advertencia "El dispositivo /dev/$PARTICION ya está montado. Desmontando..."
    sudo umount "/dev/$PARTICION" 2>/dev/null
    if [[ $? -eq 0 ]]; then
        exito "Dispositivo desmontado correctamente."
    else
        error_y_salir "Fallo al desmontar el dispositivo. Por favor, desmonta manualmente."
    fi
fi

# 6. Crear el punto de montaje si no existe
if [[ ! -d "$PUNTO_MONTAJE" ]]; then
    advertencia "El punto de montaje $PUNTO_MONTAJE no existe. Creando..."
    mkdir -p "$PUNTO_MONTAJE"
    if [[ $? -eq 0 ]]; then
        exito "Directorio de montaje creado."
    else
        error_y_salir "Fallo al crear el directorio de montaje. Verifica los permisos."
    fi
fi

# 7. Montar la partición con permisos de escritura
encabezado "Montando la Partición"
echo -e "Comando a ejecutar: sudo mount -t ntfs-3g -o uid=$USUARIO,gid=$GRUPO /dev/$PARTICION $PUNTO_MONTAJE"
mount -t ntfs-3g -o uid=$USUARIO,gid=$GRUPO "/dev/$PARTICION" "$PUNTO_MONTAJE"

if [[ $? -eq 0 ]]; then
    exito "¡Éxito! El disco se ha montado correctamente en $PUNTO_MONTAJE"
    exito "Ahora puedes acceder y escribir en el disco."
else
    error_y_salir "Fallo al montar el disco. Revisa la salida para más detalles."
fi

echo -e "\n${AZUL}¡Proceso completado!${NORMAL}"
