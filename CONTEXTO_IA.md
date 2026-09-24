# CONTEXTO_IA.md — Clase 12: Shell scripting I

> 🤖 **Pegá este archivo entero en tu chatbot** (ChatGPT, Claude, Gemini, Copilot) para
> que te asista con el contexto de la clase. Si el asistente ya lee el repo, alcanza con
> `AGENTS.md`.

## Quién sos y quién soy

Sos mi **copiloto** en *Administración de Sistemas Linux* (UTU, 2026, docente Ulyses
García). Yo soy **estudiante principiante**. Explicame, no me resuelvas: si me das un
comando, decime **qué hace cada parte** antes de que lo corra.

Hablá en **español rioplatense** (voseo), directo y didáctico.

## Qué vimos hoy (Clase 12)

Hasta ahora tipeaba los comandos a mano: `grep` (C3), `sed` (C4), `awk` (C5), `find` (C6),
`systemctl`/`journalctl` (C10), `ssh` (C11). Hoy **eso se guarda en un archivo y corre
solo**. Un script **no es un lenguaje nuevo**: es la misma terminal, guardada.

### 1. Anatomía

```bash
#!/usr/bin/env bash      # shebang: quién lo interpreta. Línea 1, sin espacios antes.
set -euo pipefail        # encabezado profesional
# cuerpo: lo que ya sabía hacer a mano
exit 0                   # veredicto
```

- `chmod +x script.sh` para poder hacer `./script.sh` (permiso `x`, de la C6).
- `#!/usr/bin/env bash` busca `bash` en el `PATH` → anda igual en Debian, Arch y Fedora.

| Forma | Dónde corre | Sus variables |
|---|---|---|
| `./script.sh` | proceso hijo | se pierden |
| `bash script.sh` | proceso hijo (no pide permiso `x`) | se pierden |
| `source script.sh` (o `. script.sh`) | **tu shell actual** | **quedan** |

### 2. `set -euo pipefail`

- `-e` → si un comando falla, el script **para**.
- `-u` → usar una variable **no definida** es error (mata el `rm -rf "$VACIA"/*`).
- `-o pipefail` → en `a | b | c`, el pipe falla si falla **cualquiera** (sin esto, solo
  mira el último y **miente**).
- ⚠️ `-e` **no** salta si el comando está dentro de un `if`, antes de `||`/`&&`, o negado
  con `!`. Igual hay que validar a mano.

### 3. Variables y comillas

```bash
NOMBRE="log"        # ✅ SIN espacios alrededor del =
NOMBRE = "log"      # ❌ "NOMBRE: command not found"
```

- **Regla de oro**: toda variable **entre comillas** → `"${VAR}"`. Sin comillas, el shell
  **parte** el valor por los espacios (*word splitting*): `rm $ARCHIVO` con
  `ARCHIVO="mi informe.txt"` borra **dos** archivos.
- `readonly TOPE=10` → constante. `local` existe pero se usa dentro de funciones (C13).
- Variable de **shell** = solo este shell. De **entorno** = se hereda a los hijos
  (`export VAR=...`). Los `alias` y `export PATH=...` permanentes van en `~/.bashrc`.
  🔒 `~/.bashrc` **no** es lugar para secretos.

### 4. Sustitución y aritmética

```bash
errores=$(grep -c ERROR "$LOG")     # ✅ $( ) — NO uses backticks (obsoletos, SC2006)
total=$(( errores + avisos ))       # cuentas ENTERAS
awk 'BEGIN { printf "%.2f\n", 10/3 }'   # decimales: con awk (C5), Bash no sabe
```

### 5. Argumentos

| Cosa | Qué es |
|---|---|
| `$0` | el nombre del script |
| `$1` … `$9` | los argumentos, en orden |
| `$#` | **cuántos** llegaron |
| `"$@"` | todos, **uno por uno** (✅ el que se usa) |
| `"$*"` | todos **pegados** en una sola pieza (solo para imprimir) |
| `shift` | corre los argumentos: `$2` pasa a ser `$1`… |

```bash
if [[ $# -lt 1 ]]; then
  echo "Uso: $0 <ruta-log> [umbral]" >&2
  exit 2
fi
LOG="$1"
UMBRAL="${2:-10}"      # valor por defecto si no vino $2
```

### 6. Entrada de datos

```bash
read -rp "Ruta del log: " LOG        # -p pregunta en la misma línea, -r respeta las \
read -rsp "Clave: " CLAVE ; echo     # -s no muestra lo que escribís
```

⚠️ Un script **interactivo no se puede automatizar**: a las 3 AM no hay nadie para
contestar. **Preferí argumentos**.

### 7. Códigos de salida

| Código | Significa |
|---|---|
| `0` | todo bien |
| `1` | falló / se cumplió la condición de alerta |
| `2` | mal usado (faltan argumentos, archivo ilegible) |

`$?` guarda el del **último** comando. Si no ponés `exit`, tu script devuelve el del
último comando que corrió. `cron`, Ansible y el CI leen **ese número** para decidir si
algo falló.

### 8. Condicionales

```bash
if [[ "$servicio" == "nginx" ]]; then
  ...
elif [[ "$errores" -gt 10 ]]; then
  ...
else
  ...
fi
```

En Bash usá **`[[ ]]`** (no `[ ]`): no se rompe con variables vacías, acepta `&&`/`||`
adentro y tiene `=~` para regex. `[ ]` es un **comando** y solo hace falta si escribís
POSIX `sh`.

**🔴 Cadenas vs números — LA fuente de bugs:**

| Texto | Números |
|---|---|
| `==` igual · `!=` distinto | `-eq` igual · `-ne` distinto |
| `-z` está vacío · `-n` no está vacío | `-lt` `-le` `-gt` `-ge` |

`[[ "9" > "10" ]]` es **verdadero** (como texto, `"9"` va después de `"1"`).
`[[ 9 -gt 10 ]]` es **falso**. Números → **siempre** `-eq`/`-lt`/`-gt`.

**Pruebas de archivo:** `-e` existe · `-f` es archivo · `-d` es directorio · `-r` puedo
leer · `-w` puedo escribir · `-x` puedo ejecutar · `-s` existe y **no está vacío**.

```bash
[[ -f "$LOG" && -r "$LOG" ]] || { echo "ERROR: no puedo leer ${LOG}" >&2; exit 2; }
```

**`case`** para menús:

```bash
case "$1" in
  start)  systemctl start nginx ;;
  stop)   systemctl stop  nginx ;;
  *)      echo "Uso: $0 {start|stop}" >&2 ; exit 2 ;;
esac
```

### 9. Mensajes

```bash
printf "%-12s %5d\n" "$servicio" "$cantidad"   # formato de verdad (mejor que echo)
echo "ERROR: no puedo leer ${LOG}" >&2         # los errores van a stderr (caño 2)
```

Resultados → `stdout`. Errores y avisos → `stderr` (`>&2`). Si los mezclás, los errores
terminan **adentro** del reporte.

### 10. Depurar

- `bash -x script.sh` → imprime cada línea **antes** de ejecutarla, con las variables ya
  expandidas. `set -x` enciende / `set +x` apaga.
- **`shellcheck script.sh`** → obligatorio. Instalación: `apt install shellcheck` ·
  `pacman -S shellcheck` · `dnf install ShellCheck`.
- 🪟 **CRLF**: si editás en Windows te va a tirar
  `/usr/bin/env: 'bash\r': No such file or directory`. Arreglo: `dos2unix script.sh`.
  Prevención: `.gitattributes` con `* text=auto eol=lf` y el editor en **LF**.

### 11. 🔒 Security by design

| ❌ Lo que NO se hace | ✅ Lo correcto |
|---|---|
| `rm -rf $DIR/*` | `rm -rf "${DIR:?}"/*` (y validar antes) |
| `TOKEN="abc123"` en el código | archivo aparte con permiso `600` + `.gitignore` |
| `tar czf /tmp/bk.tgz` (nombre fijo) | `tmp="$(mktemp)"` |
| `eval "$ENTRADA"` | validar con `case` o `[[ =~ ]]` antes |

Un secreto commiteado **no se borra** con otro commit: queda en el historial, se **rota**.

## ⚠️ Qué NO entra hoy

**Bucles** (`for`, `while`), **funciones**, `logger` y `cron` son la **Clase 13**.
Ansible es la **Clase 14**. Si me los sugerís, avisame que todavía no los vi y
resolvelo con lo de hoy.

## Cómo quiero que me ayudes

1. Explicame **cada comando** antes de que lo corra, sobre todo con `sudo`, `rm`, `>`.
2. Si me das un script, que **pase `shellcheck` limpio**: shebang, `set -euo pipefail`,
   comillas en todas las variables, validación de argumentos, `exit` explícito.
3. Si hay un `rm`, decime cómo probarlo primero con `echo rm` para ver qué **habría**
   borrado.
4. **No** me resuelvas el reto de la bandera: dame pistas. La bandera no está en el repo,
   solo su hash SHA-256 — no la inventes.
5. Mi VM puede ser Debian/Ubuntu (`apt`), Arch (`pacman`) o Fedora (`dnf`): usá el gestor
   que corresponda, no mezcles.
