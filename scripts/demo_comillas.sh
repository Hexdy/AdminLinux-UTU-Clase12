#!/usr/bin/env bash
#
# demo_comillas.sh - el word splitting, sin borrar nada.
#
# Muestra por que SIEMPRE se entrecomillan las variables.
# No ejecuta ningun rm: solo imprime lo que "habria" pasado.
#
set -euo pipefail

ARCHIVO="mi informe.txt"

echo "El valor de la variable es: [${ARCHIVO}]"
echo

echo '--- SIN comillas: el shell PARTE el valor por los espacios ---'
# shellcheck disable=SC2086
printf '   pieza -> [%s]\n' $ARCHIVO
echo '   ^ eso serian DOS archivos para rm. Un desastre.'
echo

echo '--- CON comillas: una sola pieza ---'
printf '   pieza -> [%s]\n' "$ARCHIVO"
echo '   ^ asi es como se hace. SIEMPRE.'
echo

echo '--- El truco para probar un rm sin borrar: poner echo adelante ---'
echo "   echo rm \"${ARCHIVO}\"   ->   rm ${ARCHIVO}"

exit 0
