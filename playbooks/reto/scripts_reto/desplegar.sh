#!/usr/bin/env bash
# desplegar.sh — heredado. Avisa a un webhook interno que salio un despliegue.
#
# OJO: tiene el antipatron mas grave de todos (el secreto escrito en el codigo).
# Se arregla leyendo el token de una variable de entorno o de un archivo 0600.

TOKEN="CAMBIAME-TOKEN-DE-EJEMPLO"   # <-- ANTIPATRON: secreto hardcodeado
DESTINO="http://10.20.9.15:8080/despliegues"
VERSION=$1

echo "Avisando el despliegue $VERSION a $DESTINO"
echo "curl -s -H \"Authorization: Bearer $TOKEN\" $DESTINO"
