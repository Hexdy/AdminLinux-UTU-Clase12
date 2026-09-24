#!/usr/bin/env bash
# respaldo_config.sh — heredado del compañero que se fue.
# Copia los .conf de una carpeta a un respaldo con la fecha del dia.
#
# OJO: este script NO es un ejemplo de lo que hay que hacer. Leelo, encontrale
# los problemas (comillas, validaciones, encabezado) y NO lo corras a ciegas.

ORIGEN=$1
DESTINO=$HOME/respaldos/$(date +%F)

mkdir -p $DESTINO
cp $ORIGEN/*.conf $DESTINO
echo "Respaldo hecho en $DESTINO"
