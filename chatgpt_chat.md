🧩 ¿Qué es un archivo .asc?

Un archivo .asc es un archivo ASCII que contiene una clave pública PGP exportada. Puedes importarlo localmente sin necesidad de contactar servidores externos.

✅ Paso a paso: Importar claves GPG desde un archivo .asc
🔽 1. **Descarga la clave pública en formato .asc

Desde una máquina que tenga acceso (o desde tu navegador), ve a estos enlaces y descarga las claves públicas de Chaotic AUR:

Clave 1: 3A40CB5E7E5CBC30

URL: https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x3A40CB5E7E5CBC30

Clave 2: 349BC7808577C592

URL: https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x349BC7808577C592


URL: https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x3056513887B78AEB

sudo pacman-key --lsign-key 3A40CB5E7E5CBC30
sudo pacman-key --lsign-key 349BC7808577C592
sudo pacman-key --lsign-key 3056513887B78AEB


En cada enlace, se te mostrará el contenido ASCII de la clave.

Copia el contenido completo, incluyendo las líneas:


📥 2. Importar las claves al keyring de pacman

sudo pacman-key --add chaotic-key1.asc
sudo pacman-key --lsign-key 3A40CB5E7E5CBC30

sudo pacman-key --add chaotic-key2.asc
sudo pacman-key --lsign-key 349BC7808577C592

Esto:

    Añade las claves al keyring de pacman.

    Las firma localmente para que pacman confíe en ellas.


sudo pacman -Sy
sudo pacman -S chaotic-keyring chaotic-mirrorlist

Perfecto, estás muy cerca de resolverlo. Ya lograste importar dos claves, pero te falta una más: la del mantenedor principal del repositorio, Pedro Henrique Lara Campos, con ID:

    3056513887B78AEB

Esta clave es obligatoria para verificar la firma del paquete chaotic-keyring, y como aún no está en tu keyring confiado, pacman marca el paquete como corrupto por una firma no confiable.
✅ Paso final: Importar y confiar en la clave de Pedro Henrique Lara Campos
🔑 1. Importar manualmente la clave pública desde archivo o keyserver

Puedes hacerlo de dos formas:

Opción B: 📄 Usar archivo .asc si prefieres sin red

    Ve a esta URL y copia el contenido completo (igual que antes):

👉 https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x3056513887B78AEB

    Guarda el contenido en un archivo, por ejemplo:

sudo pacman-key --add pedrohlc.asc
sudo pacman-key --lsign-key 3056513887B78AEB

sudo pacman -S chaotic-keyring chaotic-mirrorlist

sudo pacman -S google-chrome

sudo mkdir -p /etc/pacman.d/
nano /etc/pacman.d/chaotic-mirrorlist
Server = https://geo-mirror.chaotic.cx/$repo/$arch

sudo nano /etc/pacman.conf
[chaotic-aur]
Include = /etc/pacman.d/chaotic-mirrorlist

