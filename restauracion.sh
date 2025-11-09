#!/usr/bin/env bash

if [ "$EUID" -ne 0 ]; then
    echo "Debes ejecutar este script como root."
    exit 1
fi

BASE_DIR="/mnt/copias_seguridad"
INCR_DIR="/mnt/copias_seguridad/incrementales"

COPIAS_COMPLETAS=($(find "$BASE_DIR" -maxdepth 1 -type d -name "20*" | sort))
COPIAS_INCREMENTALES=($(find "$INCR_DIR" -maxdepth 1 -type d -name "20*" 2>/dev/null | sort))

if [ ${#COPIAS_COMPLETAS[@]} -eq 0 ] && [ ${#COPIAS_INCREMENTALES[@]} -eq 0 ]; then
    echo "No hay copias de seguridad."
    exit 1
fi

echo "Copias disponibles:"
echo ""
contador=1
declare -A MAPA_COPIAS

for copia in "${COPIAS_COMPLETAS[@]}"; do
    echo "[$contador] $(basename "$copia") - Completa"
    MAPA_COPIAS[$contador]="$copia"
    ((contador++))
done

for copia in "${COPIAS_INCREMENTALES[@]}"; do
    echo "[$contador] $(basename "$copia") - Incremental"
    MAPA_COPIAS[$contador]="$copia"
    ((contador++))
done

echo ""
read -p "Selecciona número: " SELECCION

if [ -z "${MAPA_COPIAS[$SELECCION]}" ]; then
    echo "Selección inválida."
    exit 1
fi

COPIA="${MAPA_COPIAS[$SELECCION]}"

echo ""
echo "Vas a restaurar: $(basename "$COPIA")"
read -p "Escribe SI para confirmar: " CONFIRMACION

if [ "$CONFIRMACION" != "SI" ]; then
    echo "Cancelado."
    exit 0
fi

echo ""
DIRECTORIOS=(etc var home root usr/local opt srv boot)

for dir in "${DIRECTORIOS[@]}"; do
    if [ -d "$COPIA/$dir" ]; then
        echo "Restaurando /$dir..."
        rsync -ah --delete "$COPIA/$dir/" "/$dir/"
    fi
done

[ -f "$COPIA/sources.list" ] && cp "$COPIA/sources.list" /etc/apt/sources.list
[ -d "$COPIA/sources.list.d" ] && rsync -ah --delete "$COPIA/sources.list.d/" /etc/apt/sources.list.d/

echo ""
echo "Restauración completada."
echo ""
read -p "Reiniciar ahora? (s/n): " REINICIO

[[ "$REINICIO" == "s" ]] && reboot || echo "Reinicia manualmente."
