#!/usr/bin/env bash
# funciones_demo.sh [directorio] - local, return vs echo, y la estructura main().
# Escalon 4 de la Clase 12.
# Salida: 0 = ok | 1 = hubo fallos | 2 = error de uso
set -euo pipefail

TAG="funciones-demo"

# --- herramientas ------------------------------------------------------------
log() {                                   # los mensajes van a stderr, NO al reporte
    local nivel="$1"; shift
    printf '[%s] [%s] %s\n' "$(date '+%F %T')" "${nivel^^}" "$*" >&2
}

uso() { echo "uso: $0 [directorio]" >&2; exit 2; }

# --- return: devuelve ESTADO (se usa en un if) -------------------------------
validar_log() {
    local archivo="$1"
    [[ -f "$archivo" && -r "$archivo" && -s "$archivo" ]] || return 1
}

# --- echo: devuelve DATO (se captura con $( )) -------------------------------
contar_errores() {
    local archivo="$1"
    grep -c '\[ERROR\]' "$archivo" || true
}

# --- main: el indice del script ----------------------------------------------
main() {
    (( $# <= 1 )) || uso
    local dir="${1:-datos}" f n total=0 fallos=0

    [[ -d "$dir" ]] || { log err "no existe el directorio $dir"; return 2; }
    log info "arranco en $dir"

    for f in "$dir"/*.log; do
        [[ -e "$f" ]] || continue
        if validar_log "$f"; then                   # <- estado
            n="$(contar_errores "$f")"              # <- dato
            printf '%-24s %4s\n' "$(basename "$f")" "$n"
            total=$(( total + n ))
        else
            log warning "salteo $f (vacio o ilegible)"
            fallos=$(( fallos + 1 ))
        fi
    done

    printf '%-24s %4s\n' "TOTAL" "$total"
    log info "listo: ${total} lineas [ERROR], ${fallos} archivos salteados"
    (( fallos == 0 )) || return 1
}

main "$@"
