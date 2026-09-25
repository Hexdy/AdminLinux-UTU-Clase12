#!/usr/bin/env bash
# primero.sh - mi primer script de verdad (Laboratorio 1 de la Clase 12).
# Uso: ./primero.sh
# Salida: 0 = ok | 2 = no encuentro el log
set -euo pipefail

LOG="${1:-datos/app_demo.log}"
readonly LOG

[[ -f "$LOG" && -r "$LOG" ]] || { printf 'ERROR: no puedo leer "%s"\n' "$LOG" >&2; exit 2; }

TOTAL="$(grep -c '\[ERROR\]' "$LOG" || true)"

echo "== Reporte del $(date +%F) =="
echo "Archivo : ${LOG}   Lineas [ERROR] : ${TOTAL}"
