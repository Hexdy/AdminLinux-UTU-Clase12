#!/bin/bash
# chequear_servicio.sh — heredado. Mira si una unit de systemd esta activa.
# (Enganche con la Clase 10: systemctl is-active devuelve un codigo de salida.)

SERVICIO=$1

if systemctl is-active --quiet $SERVICIO; then
  echo "$SERVICIO esta activo"
else
  echo "$SERVICIO NO esta activo"
fi
