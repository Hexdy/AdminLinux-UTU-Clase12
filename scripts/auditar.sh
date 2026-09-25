#!/usr/bin/env bash
# auditar.sh <ruta_log> [umbral] - avisa si los errores pasan el umbral.
# Laboratorio 2 de la Clase 12.
# Salida: 0 = bajo el umbral | 1 = umbral superado | 2 = error de uso
set -euo pipefail

[[ $# -ge 1 && $# -le 2 ]] || { printf 'Uso: %s <ruta_log> [umbral]\n' "$0" >&2; exit 2; }

LOG="$1"; UMBRAL="${2:-20}"; readonly LOG UMBRAL

[[ "$UMBRAL" =~ ^[0-9]+$ ]] || { printf 'ERROR: umbral no entero\n' >&2; exit 2; }
[[ -f "$LOG" && -r "$LOG" ]] || { printf 'ERROR: no leo "%s"\n' "$LOG" >&2; exit 2; }

errores="$(grep -c '\[ERROR\]' "$LOG" || true)"

printf '=== Auditoria de %s (%s) ===\nErrores : %s\nUmbral  : %s\n' \
       "$LOG" "$(date +%F)" "$errores" "$UMBRAL"

if [[ "$errores" -gt "$UMBRAL" ]]; then
    printf 'ALERTA: %s errores superan el umbral de %s\n' "$errores" "$UMBRAL" >&2
    exit 1
fi

printf 'OK: dentro del umbral\n'
