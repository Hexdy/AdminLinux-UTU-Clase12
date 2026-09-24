#!/usr/bin/env bash
#
# demo_condicionales.sh - cadenas vs numeros, y pruebas de archivo.
#
# Uso:  ./demo_condicionales.sh [ruta-de-archivo]
#
set -euo pipefail

RUTA="${1:-../datos/app.log}"

echo '--- Cadenas vs numeros: LA fuente de bugs ---'
if [[ "9" > "10" ]]; then
    echo '   [[ "9" > "10" ]]  -> VERDADERO   (compara como TEXTO: "9" va despues de "1")'
fi
if [[ 9 -lt 10 ]]; then
    echo '   [[ 9 -lt 10 ]]    -> verdadero   (compara como NUMERO, que es lo que querias)'
fi
echo

echo "--- Pruebas de archivo sobre: ${RUTA} ---"
[[ -e "$RUTA" ]] && echo '   -e  existe'
[[ -f "$RUTA" ]] && echo '   -f  es un archivo comun'
[[ -d "$RUTA" ]] && echo '   -d  es un directorio'
[[ -r "$RUTA" ]] && echo '   -r  lo puedo leer'
[[ -w "$RUTA" ]] && echo '   -w  lo puedo escribir'
[[ -x "$RUTA" ]] && echo '   -x  lo puedo ejecutar'
[[ -s "$RUTA" ]] && echo '   -s  existe y NO esta vacio'
echo

echo '--- Cadena vacia ---'
VACIA=""
[[ -z "$VACIA" ]] && echo '   -z  la variable esta vacia'
[[ -n "${RUTA}" ]] && echo '   -n  esta otra NO esta vacia'

exit 0
