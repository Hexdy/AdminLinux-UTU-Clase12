# Chuleta de Bash — Clase 12 (fundamentos y decisiones)

> Todo lo de la clase, en tablas. ⚠️ Bucles y funciones **no están acá**: son la Clase 13.

## 1. Anatomía

| Pieza | Para qué |
|---|---|
| `#!/usr/bin/env bash` | **shebang**: quién interpreta el archivo. Línea 1, sin espacios antes. |
| `set -euo pipefail` | encabezado profesional (§2) |
| `# comentario` | explica el **por qué**, no el qué |
| `exit 0` / `exit 1` | el veredicto para quien lo llamó |
| `chmod +x script.sh` | permiso de ejecución (sin esto, `./script.sh` = *Permission denied*) |

| Forma de correrlo | Dónde corre | Sus variables | Cuándo |
|---|---|---|---|
| `./script.sh` | proceso hijo | se pierden | la normal (pide shebang + `x`) |
| `bash script.sh` | proceso hijo | se pierden | probar sin dar permisos |
| `source script.sh` · `. script.sh` | **tu shell actual** | **quedan** | cargar config, `.env` |

## 2. `set -euo pipefail`

| Opción | Nombre largo | Qué hace |
|---|---|---|
| `-e` | `errexit` | si un comando falla, el script **para** |
| `-u` | `nounset` | usar una variable **no definida** es error |
| `-o pipefail` | — | en `a \| b \| c` falla si falla **cualquiera** |

⚠️ `-e` **no** salta si el comando está dentro de un `if`, antes de `||`/`&&`, o negado
con `!`. Igual validá a mano.

## 3. Variables

| Escribís | Pasa |
|---|---|
| `NOMBRE="log"` | ✅ asignación (sin espacios alrededor del `=`) |
| `NOMBRE = "log"` | ❌ `NOMBRE: command not found` |
| `"${VAR}"` | ✅ el valor, como **una sola pieza** |
| `$VAR` | ⚠️ se parte por los espacios (*word splitting*) |
| `"${VAR:-defecto}"` | si `VAR` está vacía o no existe, usa `defecto` |
| `"${VAR:?mensaje}"` | si está vacía, **corta** el script con ese mensaje |
| `readonly TOPE=10` | constante: no se puede cambiar después |
| `export VAR=x` | pasa a ser variable de **entorno** (la heredan los hijos) |

`local` existe pero se usa **dentro de funciones** → Clase 13.

## 4. Sustitución y aritmética

| Escribís | Da |
|---|---|
| `$(comando)` | la **salida** del comando (✅ el que se usa) |
| `` `comando` `` | lo mismo, pero **obsoleto** (SC2006) |
| `$(( 3 + 4 ))` | `7` — cuentas **enteras** |
| `$(( a * b ))` | adentro de `$(( ))` no hace falta el `$` |
| `awk 'BEGIN { printf "%.2f\n", 10/3 }'` | decimales (Bash no sabe) |

## 5. Argumentos

| Cosa | Qué es |
|---|---|
| `$0` | el nombre del script |
| `$1` … `$9` | los argumentos, en orden |
| `$#` | **cuántos** llegaron |
| `"$@"` | todos, **uno por uno** (✅ el que se usa) |
| `"$*"` | todos **pegados** en una sola pieza |
| `shift` | corre los argumentos: `$2` pasa a ser `$1`… |

```bash
if [[ $# -lt 1 ]]; then
  echo "Uso: $0 <ruta-log> [umbral]" >&2
  exit 2
fi
LOG="$1"
UMBRAL="${2:-10}"
```

## 6. `read`

| Opción | Qué hace |
|---|---|
| `-p "texto"` | muestra la pregunta en la **misma** línea |
| `-r` | respeta las `\` (usalo **siempre**) |
| `-s` | **no muestra** lo que se escribe (claves) |
| `-t 10` | espera 10 segundos y sigue |

⚠️ Un script interactivo **no se puede automatizar**. Preferí argumentos.

## 7. Códigos de salida

| Código | Convención |
|---|---|
| `0` | todo bien |
| `1` | falló / se cumplió la condición de alerta |
| `2` | mal usado (faltan argumentos, archivo ilegible) |
| `126` | encontrado pero **no ejecutable** (te faltó `chmod +x`) |
| `127` | **comando no encontrado** (typo o no está instalado) |
| `130` | lo cortaste con `Ctrl+C` |

`$?` = código del **último** comando. Sin `exit`, el script devuelve el del último.

## 8. Condicionales

```bash
if [[ condicion ]]; then
  ...
elif [[ otra ]]; then
  ...
else
  ...
fi
```

| | `[[ ]]` | `[ ]` |
|---|---|---|
| Qué es | palabra reservada de Bash | un **comando** |
| Variable vacía sin comillas | no se rompe | **explota** |
| `&&` / `\|\|` adentro | sí | no |
| Regex `=~` | sí | no |
| Portable a POSIX `sh` | no | sí |

**✅ En Bash usá `[[ ]]`.** `[ ]` solo si escribís `sh` puro.

### 🔴 Cadenas vs Números

| TEXTO | NÚMEROS |
|---|---|
| `==` igual | `-eq` igual |
| `!=` distinto | `-ne` distinto |
| `<` `>` orden alfabético | `-lt` menor · `-le` menor o igual |
| `-z` está vacío | `-gt` mayor · `-ge` mayor o igual |
| `-n` NO está vacío | |

`[[ "9" > "10" ]]` → **verdadero** (texto). `[[ 9 -gt 10 ]]` → **falso** (número).

### Pruebas de archivo

| Prueba | Verdadero si… |
|---|---|
| `-e ruta` | existe (lo que sea) |
| `-f ruta` | existe y es un **archivo común** |
| `-d ruta` | existe y es un **directorio** |
| `-r` / `-w` / `-x` | puedo **leer** / **escribir** / **ejecutar** |
| `-s ruta` | existe y **no está vacío** |

### Operadores

| Operador | Significa |
|---|---|
| `&&` | Y — tienen que cumplirse las dos |
| `\|\|` | O — alcanza con una |
| `!` | negación |
| `cmd1 && cmd2` | corré `cmd2` **solo si** `cmd1` salió bien |
| `cmd1 \|\| cmd2` | corré `cmd2` **solo si** `cmd1` falló |

### `case`

```bash
case "$1" in
  start)        systemctl start nginx ;;
  stop|parar)   systemctl stop  nginx ;;
  *.log)        echo "es un log" ;;
  *)            echo "Uso: $0 {start|stop}" >&2 ; exit 2 ;;
esac
```

## 9. Mensajes

| Escribís | Qué hace |
|---|---|
| `echo "hola"` | simple; varía entre shells |
| `printf "%s\n" "hola"` | formato de verdad, igual en todos lados |
| `printf "%-12s %5d\n" "$s" "$n"` | `%-12s` texto a la izquierda en 12 lugares, `%5d` número en 5 |
| `echo "ERROR" >&2` | manda el mensaje a **stderr** |
| `comando 2>/dev/null` | tira los errores a la basura |

**Resultados → `stdout`. Errores y avisos → `stderr` (`>&2`).**

## 10. Depurar

| Herramienta | Para qué |
|---|---|
| `bash -x script.sh` | imprime cada línea **antes** de ejecutarla |
| `set -x` / `set +x` | enciende / apaga el modo traza **en un tramo** |
| `shellcheck script.sh` | el corrector: encuentra los errores antes de que exploten |
| `bash -n script.sh` | revisa la **sintaxis** sin ejecutar nada |

Instalar `shellcheck`: `apt install shellcheck` · `pacman -S shellcheck` ·
`dnf install ShellCheck`.

## 11. 🔴 Errores típicos (síntoma → causa → arreglo)

| Síntoma | Causa | Arreglo |
|---|---|---|
| `NOMBRE: command not found` | espacios alrededor del `=` | `NOMBRE="valor"` |
| `unary operator expected` | variable vacía sin comillas en `[ ]` | comillas + `[[ ]]` |
| `too many arguments` | variable con espacios sin comillas | `"${VAR}"` |
| borró el archivo equivocado | faltaron comillas (*word splitting*) | `rm "${ARCHIVO}"` |
| `[[ 9 > 10 ]]` da verdadero | comparaste números como texto | `-gt`, `-lt`, `-eq` |
| `unbound variable` | `set -u` y la variable no existe | `"${VAR:-defecto}"` |
| `Permission denied` al hacer `./x.sh` | falta el permiso `x` | `chmod +x x.sh` |
| `bash\r: command not found` | el archivo está en **CRLF** | `dos2unix x.sh` |
| `syntax error near unexpected token 'fi'` | te falta el `;` antes de `then` | `if [[ x ]]; then` |
| el pipe "salió bien" pero el dato está mal | faltó `-o pipefail` | `set -euo pipefail` |
| `cron` dice que todo anduvo y no | el script nunca hizo `exit 1` | poné exit codes |

## 12. 🔒 Security by design

| # | Regla | ❌ Antipatrón | ✅ Correcto |
|---|---|---|---|
| 1 | Comillas siempre | `rm -rf $DIR/*` | `rm -rf "${DIR:?}"/*` |
| 2 | Validar lo que entra | `LOG="$1"` y listo | `[[ -f "$LOG" && -r "$LOG" ]] \|\| exit 2` |
| 3 | Nada de `eval` | `eval "$ENTRADA"` | validar con `case` / `[[ =~ ]]` |
| 4 | Cero secretos en el código | `TOKEN="abc123"` | archivo aparte con `chmod 600` + `.gitignore` |
| 5 | Temporales seguros | `/tmp/bk.tgz` (nombre fijo) | `tmp="$(mktemp)"` |
| 6 | Rutas entre comillas | `cd $DESTINO` | `cd "${DESTINO}"` |
| 7 | Mínimo privilegio | `chmod 777` | `chmod 600` / `640` según haga falta |

> Un secreto commiteado **no se borra** con otro commit: queda en el historial. Se **rota**.
