# Scripts para crear copias de seguridad.

## Todos los scripts contemplan los siguientes directorios.

- /etc
- /var
- /home
- /root
- /usr/local
- /opt
- /srv
- /boot/grub/grub.cfg (o todo /boot)
- /etc/apt/sources.list*

## Información

- Al hacer la copia de seguridad, el nombre de la misma es el día de la creación.

- Las copias completas se crean en /mnt/copias_seguridad

- Las copias Incrementales se crean en /mnt/copias_seguridad/incrementales 

### copia_completa - Crea una copia completa sobre los directorios indicados.

### copia_incremental - Crea una copia incremental sobre la última completa, si no encuentra una copia completa la crea.

### restauración - Te muestra todas las copias de seguridad y te indica si son completas o incrementales, puedes escoger una y restaurar el sistema.

### borrar_15dia - Borra las copias de seguridad que tienen más de 15 días de antigueadad.
