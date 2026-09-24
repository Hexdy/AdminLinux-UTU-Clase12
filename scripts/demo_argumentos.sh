#!/usr/bin/env bash
#
# demo_argumentos.sh - para ver con tus ojos la diferencia entre "$@" y "$*".
#
# Probalo asi (fijate en las comillas del primer argumento):
#   ./demo_argumentos.sh "mi informe.txt" notas.txt
#
set -euo pipefail

echo "--- Lo basico ---"
printf '%-6s %s\n' '$0'  "$0"
printf '%-6s %s\n' '$#'  "$#"
printf '%-6s %s\n' '$1'  "${1:-(no vino)}"
printf '%-6s %s\n' '$2'  "${2:-(no vino)}"

echo
echo '--- "$@" : cada argumento es UNA pieza (printf repite el formato) ---'
printf '   [%s]\n' "$@"

echo
echo '--- "$*" : todos PEGADOS en una sola pieza ---'
printf '   [%s]\n' "$*"

echo
echo '--- shift: corre todo un lugar a la izquierda ---'
if [[ $# -ge 1 ]]; then
    shift
    printf '   despues de shift, $1 es: %s\n' "${1:-(ya no queda nada)}"
fi

exit 0
