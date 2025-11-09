#!/usr/bin/env bash

realizar_backup() {
    local directorio="$1"
    echo "Haciendo Copia de Seguridad de $directorio"
    rsync -avh --exclude="$DESTINO" "$directorio" "$DESTINO"
}

if [ "$EUID" -ne 0 ]; then
    echo "Debes ejecutar este script como root."
else
    GUARDAR="/mnt/copias_seguridad"
    FECHA=$(date +%Y-%m-%d)
    DESTINO="$GUARDAR/$FECHA"
    DIRECTORIOS=(/etc /var /home /root /usr/local /opt /srv /boot /etc/apt/sources.list*)
    PAQUETE="rsync"

    for i in ${!DIRECTORIOS[@]}; do
        echo "Los directorios son ${DIRECTORIOS[$i]}"
    done

    mkdir -p "$DESTINO"

    if dpkg -s "$PAQUETE" &> /dev/null; then
        echo "$PAQUETE ya está instalado"
        for directorio in "${DIRECTORIOS[@]}"; do
            if [ -e "$directorio" ]; then
                realizar_backup "$directorio" &> /dev/null
            	echo "$directorio copiado."
		else
                echo "$directorio no existe"
            fi
        done
    else
        read -p "rsync no está instalado. ¿Instalar ahora? (s/n): " RESPUESTA
        if [[ "$RESPUESTA" == "s" || "$RESPUESTA" == "S" ]]; then
            sudo apt install -y "$PAQUETE"
            echo "$PAQUETE instalado."
            for directorio in "${DIRECTORIOS[@]}"; do
                if [ -e "$directorio" ]; then
                    realizar_backup "$directorio" &> /dev/null
                    echo "Copia de Seguridad Realizada."
                else
                    echo "$directorio no existe"
                fi
            done
        else
            echo "No se puede continuar sin $PAQUETE"
        fi
    fi

    echo "Guardando paquetes instalados..."
    dpkg --get-selections > "$DESTINO/paquetes_instalados.txt"
    echo "La copia de seguridad se ha creado en $DESTINO"
fi
