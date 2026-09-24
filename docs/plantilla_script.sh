#!/usr/bin/env bash
#
# plantilla_script.sh — el encabezado profesional, listo para copiar.
#
# Uso:
#   cp docs/plantilla_script.sh mi_script.sh
#   chmod +x mi_script.sh
#   ./mi_script.sh <argumento>
#
# Autor: <tu nombre>            Curso: AdminLinux UTU 2026 - Clase 12
# ---------------------------------------------------------------------------

# -e          corta el script si un comando falla
# -u          usar una variable no definida es error (mata el rm -rf "$VACIA")
# -o pipefail en a | b | c, falla si falla CUALQUIERA de los tres
set -euo pipefail

# --- 1. Uso y validacion de argumentos -------------------------------------

if [[ $# -lt 1 ]]; then
    echo "Uso: $0 <ruta-archivo> [umbral]" >&2
    exit 2
fi

ARCHIVO="$1"              # siempre entre comillas
UMBRAL="${2:-10}"         # valor por defecto si no vino el segundo argumento

# --- 2. Validar lo que entra ANTES de usarlo -------------------------------

if [[ ! -f "$ARCHIVO" ]]; then
    echo "ERROR: ${ARCHIVO} no existe o no es un archivo comun." >&2
    exit 2
fi

if [[ ! -r "$ARCHIVO" ]]; then
    echo "ERROR: no tengo permiso de lectura sobre ${ARCHIVO}." >&2
    exit 2
fi

# --- 3. Cuerpo: lo que ya sabes hacer a mano -------------------------------

lineas=$(wc -l < "$ARCHIVO")

printf '%-12s %s\n' "ARCHIVO:" "$ARCHIVO"
printf '%-12s %s\n' "LINEAS:"  "$lineas"

# --- 4. Veredicto ----------------------------------------------------------

if [[ "$lineas" -gt "$UMBRAL" ]]; then
    echo "AVISO: ${lineas} lineas superan el umbral de ${UMBRAL}." >&2
    exit 1
fi

exit 0

# ---------------------------------------------------------------------------
# Antes de decir "listo":
#   shellcheck mi_script.sh     -> tiene que salir limpio
#   bash -n mi_script.sh        -> sintaxis OK
#   file mi_script.sh           -> NO debe decir "with CRLF line terminators"
# ---------------------------------------------------------------------------
