README.md
Markdown

# Guía: Solución para permisos de escritura en discos externos NTFS en Linux

## Problema

No se puede crear, modificar o eliminar archivos en un disco duro externo con formato NTFS. Al intentar, se produce un error de permisos. Esto ocurre porque el sistema de archivos NTFS no es compatible con el sistema de permisos nativo de Linux.

## Solución

La solución consiste en desmontar el disco duro y volver a montarlo con permisos de escritura, asignando tu usuario como propietario del sistema de archivos.

### 1. Identificar el dispositivo y la partición

Usa el comando `lsblk` para encontrar la partición correcta de tu disco duro. En este ejemplo, el disco es `sdb` y la partición es `sdb1`.

```bash
lsblk
Ejemplo de salida:

sdb        8:16   0   1.8T  0 disk 
└─**sdb1** 8:17   0   1.8T  0 part
2. Desmontar el disco duro
Antes de volver a montarlo, es necesario desmontarlo.

Bash

sudo umount /run/media/final/1D8A846764B72660
Nota: El error mountpoint not mounted es normal si el disco ya estaba desmontado.

3. Crear el punto de montaje
Si el directorio donde se monta el disco no existe, debes crearlo. El nombre de la ruta es crucial.

Bash

sudo mkdir -p /run/media/final/1D8A846764B72660
4. Montar el disco con permisos de escritura
Ahora, monta la partición con los permisos de tu usuario. Esto permite que el sistema operativo trate tu usuario como el propietario del disco, dándote control total sobre los archivos.

Bash

sudo mount -t ntfs-3g -o uid=$(id -u),gid=$(id -g) /dev/sdb1 /run/media/final/1D8A846764B72660
Explicación de las opciones:

uid=$(id -u): Asigna tu ID de usuario como propietario.

gid=$(id -g): Asigna tu ID de grupo como propietario.

Posibles errores y soluciones
NTFS signature is missing: Estás intentando montar el disco completo (/dev/sdb) en lugar de una partición (/dev/sdb1). Usa lsblk para verificar la partición correcta.

No such file or directory: El directorio de montaje no existe. Debes crearlo con sudo mkdir -p.

Con estos pasos, el disco duro quedará montado y podrás crear, modificar y eliminar archivos sin problemas de permisos.

