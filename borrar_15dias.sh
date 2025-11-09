#!/usr/bin/env bash

BASE_DIR="/mnt/copias_seguridad"
INCR_DIR="/mnt/copias_seguridad/incrementales"

find "$BASE_DIR" -maxdepth 1 -type d -name "20*" -mtime +15 -exec rm -rf {} \;
find "$INCR_DIR" -maxdepth 1 -type d -name "20*" -mtime +15 -exec rm -rf {} \;

echo "Copias antiguas eliminadas."

