# Soluciones — Clase 12 (Shell scripting I)

> Mirá esto **después** de intentarlo. Todas pasan `shellcheck` limpio y **no usan bucles
> ni funciones** (eso es la Clase 13).

---

### 1️⃣ Tu primer script

```bash
#!/usr/bin/env bash
set -euo pipefail

NOMBRE="Ulyses"
echo "Hola, ${NOMBRE}. Hoy es $(date +%F)."
exit 0
```

```bash
chmod +x hola.sh
./hola.sh
```

**Por qué**: sin `chmod +x`, `./hola.sh` da *Permission denied* (el permiso `x` de la C6).
Sin shebang, el sistema no sabe con qué interpretarlo.

---

### 2️⃣ El saludo con argumento

```bash
#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
    echo "Uso: $0 <nombre>" >&2
    exit 2
fi

NOMBRE="$1"
echo "Hola, ${NOMBRE}."
exit 0
```

Salida esperada:

```
$ ./saluda.sh Ulyses ; echo "codigo: $?"
Hola, Ulyses.
codigo: 0
$ ./saluda.sh        ; echo "codigo: $?"
Uso: ./saluda.sh <nombre>
codigo: 2
```

**Por qué**: el mensaje va a `stderr`, así que `2>/dev/null` lo hace desaparecer y el
resultado "limpio" del script no se ensucia.

---

### 3️⃣ Contar de verdad

`grep -c ERROR` cuenta **16** porque hay una línea `INFO` cuyo `msg=` contiene la palabra
"ERROR". El **nivel** es el **segundo campo**:

```bash
#!/usr/bin/env bash
set -euo pipefail

LOG="$1"
errores=$(grep -cE '^[^ ]+ ERROR ' "$LOG")
echo "${errores}"
exit 0
```

```
$ ./contar_errores.sh datos/app.log
15
```

**Por qué**: `^[^ ]+ ERROR ` ancla al inicio: "algo sin espacios (la fecha), un espacio,
ERROR, un espacio". Con `awk` (C5) sería `awk '$2=="ERROR"' "$LOG" | wc -l`.

---

### 4️⃣ Validar antes de romper

```bash
#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
    echo "Uso: $0 <ruta-log>" >&2
    exit 2
fi

LOG="$1"

if [[ ! -f "$LOG" || ! -r "$LOG" ]]; then
    echo "ERROR: no puedo leer ${LOG}" >&2
    exit 2
fi

if [[ ! -s "$LOG" ]]; then
    echo "AVISO: ${LOG} esta vacio" >&2
    exit 0
fi

errores=$(grep -cE '^[^ ]+ ERROR ' "$LOG")
echo "${errores}"
exit 0
```

**Por qué**: `-f` (es archivo) + `-r` (lo puedo leer) **antes** de tocarlo. `-s` distingue
"no está" de "está pero vacío", que son dos problemas distintos.

---

### 5️⃣ El umbral

```bash
#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
    echo "Uso: $0 <ruta-log> [umbral]" >&2
    exit 2
fi

LOG="$1"
UMBRAL="${2:-10}"

[[ -f "$LOG" && -r "$LOG" ]] || { echo "ERROR: no puedo leer ${LOG}" >&2; exit 2; }

errores=$(grep -cE '^[^ ]+ ERROR ' "$LOG")
printf '%-10s %s\n' "ERRORES:" "${errores}"

if [[ "$errores" -gt "$UMBRAL" ]]; then
    echo "AVISO: ${errores} errores superan el umbral de ${UMBRAL}" >&2
    exit 1
fi

exit 0
```

```
$ ./contar_errores.sh datos/app.log 20 ; echo "codigo: $?"
ERRORES:   15
codigo: 0
$ ./contar_errores.sh datos/app.log 5  ; echo "codigo: $?"
ERRORES:   15
AVISO: 15 errores superan el umbral de 5
codigo: 1
```

**Por qué**: `"${2:-10}"` da un valor por defecto. `-gt` porque son **números**: con `>`
compararía texto y `"9" > "10"` daría verdadero.

---

### 6️⃣ El reporte con `printf`

```bash
#!/usr/bin/env bash
set -euo pipefail

[[ $# -ge 1 ]] || { echo "Uso: $0 <ruta-log>" >&2; exit 2; }
LOG="$1"
[[ -f "$LOG" && -r "$LOG" ]] || { echo "ERROR: no puedo leer ${LOG}" >&2; exit 2; }

info=$(grep -cE '^[^ ]+ INFO '  "$LOG")
warn=$(grep -cE '^[^ ]+ WARN '  "$LOG")
err=$(grep -cE  '^[^ ]+ ERROR ' "$LOG")
total=$(( info + warn + err ))

printf '%-8s %4d\n' "INFO"  "$info"
printf '%-8s %4d\n' "WARN"  "$warn"
printf '%-8s %4d\n' "ERROR" "$err"
printf '%-8s %4d\n' "TOTAL" "$total"
exit 0
```

```
INFO       50
WARN       13
ERROR      15
TOTAL      78
```

**Por qué**: `%-8s` alinea el texto a la izquierda en 8 lugares y `%4d` el número a la
derecha en 4 → columnas prolijas. `$(( ))` suma enteros.

---

### 7️⃣ El menú con `case`

```bash
#!/usr/bin/env bash
set -euo pipefail

[[ $# -ge 1 ]] || { echo "Uso: $0 {start|stop|status}" >&2; exit 2; }

case "$1" in
    start)   echo "Arrancaria el servicio (systemctl start nginx)"  ;;
    stop)    echo "Pararia el servicio (systemctl stop nginx)"      ;;
    status)  echo "Consultaria el estado (systemctl status nginx)"  ;;
    *)       echo "Uso: $0 {start|stop|status}" >&2 ; exit 2        ;;
esac

exit 0
```

**Por qué**: `case` es más legible que un `if/elif` de 4 ramas cuando comparás **la misma
variable** contra varios valores fijos. El `*)` es el "si no fue ninguno" y **siempre** va.

---

### 8️⃣ 🤖 Revisión de IA

**Los problemas del script original:**

| # | Problema | Por qué importa |
|---|---|---|
| 1 | `DESTINO = $1` | espacios alrededor del `=` → `DESTINO: command not found` |
| 2 | Falta `set -euo pipefail` | si algo falla, sigue igual y "termina bien" |
| 3 | `$DESTINO` sin comillas | si la ruta tiene un espacio, `rm` borra otra cosa |
| 4 | No valida `$1` | si viene vacío, `rm -rf /*` con tus permisos |
| 5 | No valida que sea un directorio | podría apuntar a cualquier lado |
| 6 | `#!/bin/bash` | `#!/usr/bin/env bash` es más portable entre distros |
| 7 | Todo va a `stdout` | los errores tendrían que ir a `stderr` |
| 8 | Nunca hace `exit` | quien lo llame (cron, CI) no sabe si salió bien |

**Reescrito:**

```bash
#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
    echo "Uso: $0 <directorio-a-limpiar>" >&2
    exit 2
fi

DESTINO="${1:?Falta la ruta a limpiar}"

if [[ ! -d "$DESTINO" ]]; then
    echo "ERROR: ${DESTINO} no es un directorio" >&2
    exit 2
fi

echo "Limpiando ${DESTINO}"
rm -rf "${DESTINO:?}"/*     # el :? es el cinturon extra: si esta vacia, corta
echo "Listo"
exit 0
```

> 🔎 **Probalo primero sin borrar nada**: cambiá la línea del `rm` por
> `echo rm -rf "${DESTINO:?}"/*` y mirá **qué habría borrado**. Recién después, si estás
> seguro, sacá el `echo`.

**Moraleja**: la IA escribe rápido; el que firma el incidente sos vos. `shellcheck` +
leerlo entero, **siempre**.
