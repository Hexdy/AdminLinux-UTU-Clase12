# Soluciones — Clase 12 · Shell scripting

> ⚠️ Mirá esto **después** de intentarlo. Copiar sin entender no te sirve para el parcial
> (donde se lee código) ni para el reto (donde el script es tuyo).
> Hay más de una forma correcta: si la tuya pasa `shellcheck` y hace lo mismo, está bien.

## Bloque A — guardar

**A1**
```bash
#!/usr/bin/env bash
# hola.sh - mi primer script.
set -euo pipefail
NOMBRE="Ulyses"
echo "Hola, ${NOMBRE}!"
```
```bash
chmod +x hola.sh && ./hola.sh
```

**A2** Sin `chmod +x` → `Permission denied` y `$?` = **126**. Con el nombre mal escrito →
`command not found` y `$?` = **127**.

**A3**
```bash
#!/usr/bin/env bash
set -euo pipefail
echo "Fecha    : $(date +%F)"
echo "Hostname : $(hostname)"
echo "Archivos : $(ls -1 /etc | wc -l)"
```

**A4**
```bash
DIR="${1:-/etc}"
[[ -d "$DIR" ]] || { echo "ERROR: $DIR no es un directorio" >&2; exit 2; }
echo "Archivos en $DIR : $(ls -1 "$DIR" | wc -l)"
```

**A5** `ls $ARCHIVO` se parte en dos palabras (`mi` y `informe.txt`) y busca **dos**
archivos que no existen. `ls "$ARCHIVO"` pasa **un** argumento con el espacio adentro.
Por eso: **siempre** `"$VAR"`.

## Bloque B — decidir

**B1 / B2**
```bash
#!/usr/bin/env bash
# revisar.sh <ruta>
set -euo pipefail
[[ $# -eq 1 ]] || { echo "uso: $0 <ruta>" >&2; exit 2; }
RUTA="$1"
if   [[ -d "$RUTA" ]]; then echo "$RUTA es un directorio"
elif [[ -f "$RUTA" ]]; then
    [[ -r "$RUTA" ]] || { echo "ERROR: existe pero no lo puedo leer" >&2; exit 2; }
    echo "$RUTA es un archivo legible"
else
    echo "$RUTA no existe" >&2; exit 1
fi
```

**B3**
```bash
#!/usr/bin/env bash
# umbral.sh <ruta_log> <umbral>
set -euo pipefail
[[ $# -eq 2 ]] || { echo "uso: $0 <ruta_log> <umbral>" >&2; exit 2; }
LOG="$1"; UMBRAL="$2"
[[ "$UMBRAL" =~ ^[0-9]+$ ]] || { echo "ERROR: umbral no entero" >&2; exit 2; }
[[ -f "$LOG" && -r "$LOG" ]] || { echo "ERROR: no leo $LOG" >&2; exit 2; }
errores="$(grep -c '\[ERROR\]' "$LOG" || true)"
echo "errores: $errores (umbral $UMBRAL)"
[[ "$errores" -le "$UMBRAL" ]] || exit 1
```
El `|| true` es necesario porque `grep -c` devuelve **1** si no encuentra nada, y con
`set -e` eso mataría el script.

**B4**
```bash
case "${1:-}" in
    --ayuda|-h) echo "uso: $0 <ruta_log> <umbral>"; exit 0 ;;
esac
```

**B5** `>` dentro de `[[ ]]` compara **texto**: va carácter por carácter. `"10" > "9"` es
verdadero al revés de lo que uno espera cuando los números tienen distinta cantidad de
dígitos (`"9"` empieza con `9`, que es mayor que `1`). Para números: `-gt`, `-lt`, etc.

## Bloque C — repetir

**C1**
```bash
while IFS= read -r s; do
    [[ "$s" =~ ^# || -z "$s" ]] && continue
    echo "servicio: $s"
done < datos/servicios.txt
```
`for s in $(cat archivo)` parte por **espacios**, no por líneas: un valor con espacio se
rompe, y además carga todo el archivo en memoria.

**C2**
```bash
for f in datos/*.log; do
    [[ -e "$f" ]] || continue
    printf '%-24s %s\n' "$(basename "$f")" "$(wc -l < "$f")"
done
```

**C3** Con `for f in $(ls)`: `prueba`, `con`, `espacio.log` → tres vueltas, tres nombres
inexistentes. Con `for f in *.log`: una sola vuelta con `prueba con espacio.log` entero.

**C4**
```bash
while IFS=';' read -r host ip ambiente; do
    [[ "$host" =~ ^# || -z "$host" ]] && continue
    printf '%-10s %s\n' "$host" "$ambiente"
done < datos/hosts.txt
```

**C5**
```bash
total=0
while read -r n; do
    total=$(( total + n ))
done < <(grep -c '\[ERROR\]' datos/*.log)
echo "total: $total"
```
Con `grep -c ... | while read` el bucle corre en un **proceso hijo**: acumula sobre una
**copia** de `total` que muere al terminar el pipe, y el padre sigue en 0.
La redirección de proceso `< <(...)` deja el `while` en el padre.

## Bloque D — ordenar

**D1 / D2**
```bash
contar_errores() {
    local archivo="$1"
    grep -c '\[ERROR\]' "$archivo" || true
}
validar_log() {
    local archivo="$1"
    [[ -f "$archivo" && -r "$archivo" ]] || return 1
}
if validar_log "datos/app_demo.log"; then
    n="$(contar_errores "datos/app_demo.log")"
    echo "errores: $n"
fi
```

**D3** Sin `local`, la `f` de la función es la **misma** `f` del `for`: al volver de la
función el bucle continúa con el valor cambiado → resultados mezclados o bucle que nunca
avanza. Con `local f` cada una juega en su cancha.

**D4**
```bash
#!/usr/bin/env bash
# reporte.sh <directorio>
set -euo pipefail
TAG="$(basename "$0" .sh)"

log()     { printf '[%s] %s\n' "$(date '+%F %T')" "$*" >&2; }
uso()     { echo "uso: $0 <directorio>" >&2; exit 2; }
validar() { local d="$1"; [[ -d "$d" && -r "$d" ]] || return 1; }

contar_errores() { local a="$1"; grep -c '\[ERROR\]' "$a" || true; }

main() {
    (( $# == 1 )) || uso
    local dir="$1" f total=0 n
    validar "$dir" || { log "no sirve: $dir"; return 2; }
    for f in "$dir"/*.log; do
        [[ -e "$f" ]] || continue
        n="$(contar_errores "$f")"
        printf '%-24s %4s\n' "$(basename "$f")" "$n"
        total=$(( total + n ))
    done
    printf '%-24s %4s\n' "TOTAL" "$total"
}

main "$@"
```

## Bloque E — dejar rastro y correr solo

**E1**
```bash
logger -t "$TAG" -p user.info "arranco sobre $dir"
logger -t "$TAG" -p user.err  "no pude leer $dir"
journalctl -t reporte -n 20 --no-pager
```

**E2**
```
(a) 30 2 * * *        (b) */5 * * * *
(c) 0 7 * * 1         (d) 0 0 1 * *
```

**E3** Los tres problemas:
1. `respaldo.sh` sin **ruta absoluta**: el PATH de cron es mínimo → `/usr/local/bin/respaldo.sh`.
2. El `%` de `date +%F` es **especial** en el crontab: hay que escaparlo (`\%F`) o, mejor,
   armar el nombre **adentro** del script.
3. Solo redirige `stdout`: los errores se pierden. Va `>> ... 2>&1`, o directamente `logger`.

```bash
0 3 * * * /usr/local/bin/respaldo.sh >> /var/log/respaldo.log 2>&1
```

**E4**
```bash
crontab -l > ~/crontab_$(date +%F).bak     # PRIMERO el respaldo
crontab -e                                  # agregás:  */1 * * * * /ruta/absoluta/reporte.sh /ruta/datos
journalctl -t reporte --since '-5 min' --no-pager
crontab -e                                  # y la borrás
```

**E5** `cron.service` en Debian/Ubuntu, `cronie.service` en Arch, `crond.service` en
Fedora/RHEL. Se averigua con `systemctl list-units '*cron*'`.

## Bloque F — integrador

**F1 / F2** — es el script de **D4** más: el argumento opcional del umbral
(`local umbral="${2:-20}"`), la columna de líneas (`wc -l < "$f"`), y al final:

```bash
    if (( total > umbral )); then
        logger -t "$TAG" -p user.err "total $total supera el umbral $umbral"
        log "ALERTA: $total errores"
        return 1
    fi
    return 0
```

**F3** — el reto es tuyo. Acá no hay solución: la bandera se la decís al profe. 🏁
