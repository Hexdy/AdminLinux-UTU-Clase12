#!/usr/bin/env bash
# plantilla_script.sh - copiá este archivo como punto de partida de cualquier script.
#
# Uso:    ./plantilla_script.sh <directorio> [umbral]
# Salida: 0 = todo ok | 1 = hubo problemas | 2 = error de uso
# Autor:  <tu nombre>          Fecha: <AAAA-MM-DD>

set -euo pipefail

# --- Configuración (arriba, con nombre, nunca "perdida" en el medio) --------
TAG="$(basename "$0" .sh)"
UMBRAL_POR_DEFECTO=20

# --- Funciones auxiliares ---------------------------------------------------

# log <nivel> <mensaje>    nivel: info | warning | err
log() {
    local nivel="$1"; shift
    printf '[%s] [%s] %s\n' "$(date '+%F %T')" "${nivel^^}" "$*" >&2
    command -v logger >/dev/null 2>&1 && logger -t "$TAG" -p "user.${nivel}" "$*"
}

uso() {
    echo "uso: $0 <directorio> [umbral]" >&2
    exit 2
}

validar_directorio() {
    local dir="$1"
    [[ -n "$dir" && -d "$dir" && -r "$dir" ]] || return 1
}

# --- El trabajo de verdad ---------------------------------------------------

main() {
    (( $# >= 1 && $# <= 2 )) || uso

    local dir="$1"
    local umbral="${2:-$UMBRAL_POR_DEFECTO}"
    [[ "$umbral" =~ ^[0-9]+$ ]] || { log err "el umbral no es un numero: $umbral"; exit 2; }

    validar_directorio "$dir" || { log err "no puedo leer el directorio: $dir"; exit 2; }
    log info "arranco sobre $dir (umbral $umbral)"

    local f procesados=0
    for f in "$dir"/*.log; do
        [[ -e "$f" ]] || continue          # glob vacio -> patron literal
        # ... acá va lo tuyo, siempre con "$f" entre comillas ...
        procesados=$(( procesados + 1 ))
    done

    log info "listo: $procesados archivos procesados"
    (( procesados > 0 )) || return 1
}

main "$@"
