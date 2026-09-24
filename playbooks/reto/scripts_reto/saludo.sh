#!/usr/bin/env bash
# saludo.sh — heredado. El clasico "hola" con un argumento.
# Es el unico de la carpeta que casi esta bien: fijate que le falta.

NOMBRE=$1

if [ -z "$NOMBRE" ]; then
  echo "Uso: $0 <nombre>"
  exit 1
fi

echo "Hola, $NOMBRE. Bienvenido al turno."
