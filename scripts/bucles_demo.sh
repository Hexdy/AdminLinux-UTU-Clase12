#!/usr/bin/env bash
# bucles_demo.sh [directorio] - las 3 formas de repetir, y la trampa clasica.
# Escalon 3 de la Clase 12. Corrélo con: bash -x bucles_demo.sh datos
set -euo pipefail

DIR="${1:-datos}"
[[ -d "$DIR" && -r "$DIR" ]] || { printf 'ERROR: "%s" no es un directorio legible\n' "$DIR" >&2; exit 2; }

echo "--- 1) for sobre un GLOB (la forma correcta) ---"
for f in "$DIR"/*.log; do
    [[ -e "$f" ]] || continue          # si no hay ningun .log, el glob queda literal
    printf '%-24s %6s lineas\n' "$(basename "$f")" "$(wc -l < "$f")"
done

echo
echo "--- 2) while IFS= read -r: linea por linea, SIN romper espacios ---"
if [[ -r "$DIR/hosts.txt" ]]; then
    while IFS=';' read -r host ip ambiente; do
        [[ "$host" =~ ^# || -z "$host" ]] && continue
        printf '%-10s %-15s %s\n' "$host" "$ip" "$ambiente"
    done < "$DIR/hosts.txt"
fi

echo
echo "--- 3) el ACUMULADOR: pipe (mal) vs redireccion de proceso (bien) ---"

total_mal=0
# shellcheck disable=SC2030,SC2031  # el bug del subshell es A PROPOSITO: es la demo.
grep -c '\[ERROR\]' "$DIR"/*.log 2>/dev/null | while read -r linea; do
    total_mal=$(( total_mal + ${linea##*:} ))
done
echo "con pipe          -> ${total_mal}   <- el bucle corrio en un proceso HIJO"

total_bien=0
while read -r linea; do
    total_bien=$(( total_bien + ${linea##*:} ))
done < <(grep -c '\[ERROR\]' "$DIR"/*.log 2>/dev/null || true)
echo "con < <(...)      -> ${total_bien}   <- el bucle corrio en el PADRE"

echo
echo "Explicacion completa en docs/auto_estudio.md, seccion 1."
