#!/usr/bin/env bash

realizar_backup() {
    local origen="$1"
    local destino="$2"
    local opciones="$3"
    echo "Haciendo copia de seguridad de $origen → $destino"
    rsync -avh $opciones --exclude="$destino" "$origen" "$destino"
}

if [ "$EUID" -ne 0 ]; then
    echo "Debes ejecutar este script como root."
    exit 1
fi

BASE_DIR="/mnt/copias_seguridad"
INCR_DIR="/mnt/copias_seguridad/incrementales"
FECHA=$(date +%Y-%m-%d)
DESTINO=""

DIRECTORIOS=(/etc /var /home /root /usr/local /opt /srv /boot /etc/apt/sources.list*)

ULTIMA_COMPLETA=$(find "$BASE_DIR" -maxdepth 1 -type d -name "20*" | sort | tail -n 1)

if [ -n "$ULTIMA_COMPLETA" ]; then
    echo "Se ha encontrado una copia completa previa en: $ULTIMA_COMPLETA"
    mkdir -p "$INCR_DIR"
    DESTINO="$INCR_DIR/$FECHA"
    mkdir -p "$DESTINO"
    OPCIONES="--link-dest=$ULTIMA_COMPLETA"
    TIPO_COPIA="incremental"
else
    echo "No se ha encontrado copia completa. Creando una nueva copia completa..."
    DESTINO="$BASE_DIR/$FECHA"
    mkdir -p "$DESTINO"
    OPCIONES=""
    TIPO_COPIA="completa"
fi

echo ""
echo "Los directorios que se copiarán son:"
for dir in "${DIRECTORIOS[@]}"; do
    echo "  - $dir"
done
echo ""

for directorio in "${DIRECTORIOS[@]}"; do
    if [ -e "$directorio" ]; then
        realizar_backup "$directorio" "$DESTINO" "$OPCIONES" &> /dev/null
        echo "$directorio copiado."
    else
        echo "$directorio no existe, se omite."
    fi
done

echo ""
echo "Guardando lista de paquetes instalados..."
dpkg --get-selections > "$DESTINO/paquetes_instalados.txt"

echo "Copia de seguridad $TIPO_COPIA completada"
echo "Ubicación: $DESTINO"

