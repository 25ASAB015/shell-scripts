#!/bin/bash

# Crear el script de instalación
cat << 'EOF' > chaotic-aur-setup.sh
#!/bin/bash
set -e

echo "[1/7] Agregando el repositorio chaotic-aur a /etc/pacman.conf..."
if ! grep -q "\\[chaotic-aur\\]" /etc/pacman.conf; then
    echo -e "\\n[chaotic-aur]\\nInclude = /etc/pacman.d/chaotic-mirrorlist" | sudo tee -a /etc/pacman.conf
fi

echo "[2/7] Creando el archivo chaotic-mirrorlist..."
echo "Server = https://geo-mirror.chaotic.cx/\\$repo/\\$arch" | sudo tee /etc/pacman.d/chaotic-mirrorlist

echo "[3/7] Importando claves públicas desde archivos .asc..."
for keyfile in chaotic-key1.asc chaotic-key2.asc pedrohlc.asc; do
    if [[ -f "$keyfile" ]]; then
        echo "  -> Agregando $keyfile"
        sudo pacman-key --add "$keyfile"
    else
        echo "  -> Archivo $keyfile no encontrado, abortando."
        exit 1
    fi
done

echo "[4/7] Firmando las claves localmente..."
sudo pacman-key --lsign-key 3A40CB5E7E5CBC30
sudo pacman-key --lsign-key 349BC7808577C592
sudo pacman-key --lsign-key 3056513887B78AEB

echo "[5/7] Actualizando la base de datos de paquetes..."
sudo pacman -Sy

echo "[6/7] Instalando chaotic-keyring y chaotic-mirrorlist..."
sudo pacman -S --noconfirm chaotic-keyring chaotic-mirrorlist

echo "[7/7] Verificación opcional: Instalando paquete de prueba (google-chrome)..."
read -p "¿Deseas instalar google-chrome como prueba? [y/N]: " confirm
if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
    sudo pacman -S google-chrome
else
    echo "Instalación de prueba omitida."
fi

echo "✅ Todo listo. Chaotic AUR está funcionando."
EOF

chmod +x chaotic-aur-setup.sh

# Crear el README
cat << 'EOF' > README.md
# Chaotic AUR Setup Script + Claves PGP manuales (.asc)

Este paquete contiene un script automatizado para configurar el repositorio **Chaotic AUR** en una distribución basada en Arch Linux, junto con instrucciones para importar manualmente claves PGP usando archivos `.asc`.

---

## ¿Qué hace el script (`chaotic-aur-setup.sh`)?

1. Agrega `chaotic-aur` al archivo `/etc/pacman.conf`
2. Crea el archivo de mirrors `/etc/pacman.d/chaotic-mirrorlist`
3. Importa claves públicas GPG desde archivos `.asc`
4. Firma localmente las claves para evitar errores de confianza
5. Instala `chaotic-keyring` y `chaotic-mirrorlist`
6. (Opcional) Instala un paquete de prueba (`google-chrome`)

---

## ¿Qué es un archivo `.asc`?

Un archivo `.asc` es un archivo ASCII que contiene una **clave pública PGP exportada**. Usar `.asc` permite importar claves manualmente **sin depender de servidores externos**, lo cual es útil cuando:

- Estás sin conexión a internet.
- Estás detrás de una red que bloquea puertos/servidores de claves.
- El servidor de claves está caído o no responde.

---

## Cómo usar

1. Coloca los siguientes archivos junto al script:
   - `chaotic-key1.asc` → Clave pública: `3A40CB5E7E5CBC30`
   - `chaotic-key2.asc` → Clave pública: `349BC7808577C592`
   - `pedrohlc.asc`     → Clave pública: `3056513887B78AEB`

2. Dale permisos de ejecución al script:

```bash
chmod +x chaotic-aur-setup.sh
