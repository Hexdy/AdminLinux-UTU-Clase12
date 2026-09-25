# Chuleta — Bash: lo básico que se usa en TODO script

> Escalones 1 y 2 de la Clase 12: **guardar** y **decidir**.
> Para bucles y funciones mirá `chuleta_bucles_funciones.md`; para agendar, `chuleta_cron.md`.

## 1. El encabezado (siempre igual)

```bash
#!/usr/bin/env bash
# nombre.sh - que hace, quien lo hizo, como se usa.
# Salida: 0 = ok | 1 = problema | 2 = error de uso
set -euo pipefail
```

| Parte | Por qué |
|---|---|
| `#!/usr/bin/env bash` | shebang: con qué intérprete se abre. Más portable que `#!/bin/bash`. |
| `set -e` | si un comando falla, **frena** ahí (no sigue haciendo desastre). |
| `set -u` | usar una variable que no existe es un **error**, no una cadena vacía. |
| `set -o pipefail` | si falla **cualquier** comando de la tubería, la tubería falla. |

Y después: `chmod +x nombre.sh` → `./nombre.sh`.

| Síntoma | Causa | Arreglo |
|---|---|---|
| `Permission denied` (código 126) | falta el `+x` | `chmod +x nombre.sh` |
| `command not found` (código 127) | falta el `./` o hay un typo | `./nombre.sh` |
| `/usr/bin/env: 'bash\r': No such file` | el archivo está en **CRLF** | `dos2unix nombre.sh` |

## 2. Variables

```bash
NOMBRE="servidor-01"          # sin espacios alrededor del =
echo "$NOMBRE"                # se LEE con $ y SIEMPRE entre comillas
echo "${NOMBRE}_respaldo"     # llaves cuando pega con otro texto
readonly NOMBRE               # ya no se puede cambiar
```

| Necesito | Se escribe |
|---|---|
| Valor por defecto | `"${2:-20}"` → usá `$2`; si no vino, `20` |
| Abortar si falta | `"${1:?falta la ruta}"` |
| Longitud | `"${#NOMBRE}"` |
| Sacar la extensión | `"${archivo%.log}"` |
| Quedarme con el nombre | `"$(basename "$f" .log)"` |
| Salida de un comando | `HOY="$(date +%F)"` |
| Cuenta entera | `TOTAL=$(( A + B ))` |

**Comillas** — la regla que más bugs evita:

| | Qué hace |
|---|---|
| `"$VAR"` | expande `$` y **respeta los espacios**. ✅ Esta es la que usás. |
| `'$VAR'` | literal, no expande nada. Útil para patrones: `grep '\[ERROR\]'`. |
| `$VAR` | expande y **parte por espacios**. ❌ Casi siempre es un bug. |

`export MIVAR` la manda al **entorno** (la heredan los procesos hijos). Sin `export`,
tu script no la ve. Se listan con `env`.

## 3. Argumentos y `read`

```bash
[[ $# -ge 1 ]] || { echo "Uso: $0 <ruta> [umbral]" >&2; exit 2; }
LOG="$1"
UMBRAL="${2:-20}"
```

| Variable | Qué es |
|---|---|
| `$0` | el nombre del script |
| `$1` … `$9` | los argumentos (del 10 en adelante: `${10}`, con llaves) |
| `$#` | cuántos argumentos llegaron |
| `"$@"` | **todos**, cada uno como un elemento. ✅ Siempre con comillas. |
| `"$*"` | todos pegados en un solo string |
| `shift` | corre la lista: `$2` pasa a `$1`… y `$#` baja 1 |

```bash
read -r -p "Nombre del servidor: " SERVIDOR    # -p mensaje, -r no interpreta \
read -r -s -p "Contrasena: " CLAVE ; echo      # -s oculta lo tipeado
```

> ⚠️ Un script con `read` **no se puede automatizar**: a las 3 AM no hay nadie para
> contestar. Si lo va a correr cron, usá **argumentos**.

## 4. Códigos de salida y los dos caños

| Código | Significa |
|---|---|
| `0` | éxito |
| `1` | error genérico / "encontré la condición" |
| `2` | error de **uso** (faltan argumentos, argumento inválido) |
| `126` · `127` | no ejecutable (falta `+x`) · comando no encontrado |
| `130` | terminado con Ctrl+C |

```bash
echo "un resultado"                  # canal 1: stdout  -> el reporte
echo "ERROR: falta el archivo" >&2   # canal 2: stderr  -> la pantalla
comando >/dev/null 2>&1              # callar los dos canales
echo "$?"                            # codigo de salida del ultimo comando
```

> 🔴 Nunca termines con `exit 0` fijo "para que no moleste": cron te avisa **solo** si
> salís ≠ 0.

## 5. Condicionales

```bash
if [[ "$errores" -gt 10 ]]; then
    echo "ALERTA" >&2 ; exit 1
elif [[ "$errores" -gt 0 ]]; then
    echo "revisar"
else
    echo "todo ok"
fi
```

| Comparar | Números | Texto |
|---|---|---|
| igual / distinto | `-eq` · `-ne` | `==` · `!=` |
| menor / mayor | `-lt` `-le` · `-gt` `-ge` | `<` `>` (orden alfabético) |
| vacío / no vacío | — | `-z "$v"` · `-n "$v"` |

> 🔴 `[[ "$a" -gt "$b" ]]` compara **números**; `[[ "$a" > "$b" ]]` compara **texto**
> (y ahí `"9" > "10"` es verdadero).

**Pruebas de archivo** (el pan de cada día):

| Prueba | Verdadero si… |
|---|---|
| `-e` · `-f` · `-d` | existe (lo que sea) · es archivo regular · es directorio |
| `-r` · `-w` · `-x` | lo puedo leer · escribir · ejecutar |
| `-s` | existe y **no** está vacío |
| `-L` | es un enlace simbólico |

```bash
[[ -f "$LOG" && -r "$LOG" ]] || { echo "ERROR: no leo $LOG" >&2; exit 2; }
```

**Combinar**: `&&` (y), `||` (o), `!` (no). Y el atajo que vas a ver en todos lados:

```bash
comando || { echo "fallo" >&2; exit 1; }    # "si falla, hacé esto"
```

**`case`** — cuando comparás la misma variable muchas veces:

```bash
case "$1" in
    start)    arrancar ;;
    stop)     parar ;;
    *.log)    procesar "$1" ;;      # tambien acepta patrones
    *)        echo "uso: $0 {start|stop}" >&2; exit 2 ;;
esac
```

## 6. Usá `[[ ]]`, no `[ ]`

`[ ]` (o `test`) es un programa POSIX viejo: se rompe con una variable vacía sin comillas
y no acepta `&&` / `||` adentro. `[[ ]]` es una construcción de Bash: aguanta, combina y
entiende patrones (`[[ "$f" == *.log ]]`) y regex (`[[ "$ip" =~ ^10\. ]]`).
**Sabé leer `[ ]`** en scripts viejos, pero no lo escribas.

## 7. Antes de dar por terminado un script

```bash
bash -n script.sh        # ¿la sintaxis cierra? (no lo ejecuta)
shellcheck script.sh     # el corrector ortografico de Bash
bash -x script.sh        # muestra cada linea ANTES de ejecutarla
```
