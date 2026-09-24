#!/usr/bin/env bash
#
# hola.sh - el script mas chico posible, bien hecho.
# Corrélo con:  chmod +x hola.sh && ./hola.sh
#
set -euo pipefail

NOMBRE="mundo"

echo "Hola, ${NOMBRE}. Hoy es $(date +%F) y estoy en $(pwd)."

exit 0
