# Chuleta — Bucles y funciones

> Escalones 3 y 4 de la Clase 12: **repetir** y **ordenar**.
> Lo básico (variables, comillas, condicionales) está en `chuleta_bash.md`.

## 1. `for`: una vuelta por elemento

```bash
for f in "$DIR"/*.log; do          # la LISTA la arma el glob
    [[ -e "$f" ]] || continue      # si no hay ninguno, el glob queda literal
    echo "procesando $f"
done
```

| Forma | Para qué |
|---|---|
| `for f in "$DIR"/*.log` | **archivos de una carpeta**. La que vas a usar siempre. |
| `for s in ssh cron nginx` | una lista escrita a mano |
| `for arg in "$@"` | los argumentos del script |
| `for i in {1..10}` | un rango de números |
| `for (( i=0; i<10; i++ ))` | estilo C, cuando necesitás el índice |

## 2. 🔴 Nunca `for f in $(ls)`

`$(ls)` devuelve **texto**, y Bash lo parte por espacios. Si hay un archivo llamado
`app viejo.log`, el bucle da **dos** vueltas con dos nombres que no existen.

| ❌ | ✅ |
|---|---|
| `for f in $(ls)` | `for f in "$DIR"/*.log` |
| `for f in $(find . -name '*.log')` | `find . -name '*.log' -print0 \| while IFS= read -r -d '' f` |

El glob devuelve una **lista de archivos**, no texto: los nombres con espacios llegan
enteros. Y siempre `"$f"` entre comillas cuando lo usás.

**Glob vacío**: si no hay ningún `.log`, Bash te pasa el patrón **literal**
(`/ruta/*.log`). Por eso el `[[ -e "$f" ]] || continue`.

## 3. `while`: repetir mientras se cumpla una condición

```bash
while IFS= read -r linea; do
    echo "lei: $linea"
done < archivo.log
```

| Pedazo | Qué hace |
|---|---|
| `IFS=` | vacía el separador **solo para este `read`**: no recorta espacios |
| `read` | lee **una** línea de la entrada |
| `-r` | **no** interpreta las barras invertidas (`\n`, `\t`, `\\`) |
| `linea` | la variable donde cae cada línea |
| `< archivo` | de dónde se alimenta el bucle |

```bash
while (( intentos < 5 )); do ... done      # mientras la cuenta sea menor a 5
until systemctl is-active --quiet nginx; do sleep 2; done   # hasta que se cumpla
```

`break` corta el bucle · `continue` salta a la siguiente vuelta ·
`break 2` sale de **dos** bucles anidados.

## 4. 🔴 El acumulador que siempre da 0

```bash
total=0
grep -c '\[ERROR\]' *.log | while read -r n; do
    total=$(( total + n ))        # esto se pierde
done
echo "$total"                     # -> 0
```

El `|` corre el `while` en un **proceso hijo**. Los cambios que hace el hijo **mueren**
cuando termina. La solución es **no usar pipe**:

```bash
total=0
while read -r n; do
    total=$(( total + n ))
done < <(grep -c '\[ERROR\]' *.log)    # redireccion de proceso: el while queda en el PADRE
echo "$total"
```

(Está explicado con dibujo en `auto_estudio.md`.)

## 5. Funciones

```bash
contar_errores() {
    local archivo="$1"                       # local: no pisa nada de afuera
    grep -c '\[ERROR\]' "$archivo" || true
}

n="$(contar_errores "app.log")"              # se llama SIN parentesis ni comas
```

| Regla | Por qué |
|---|---|
| Definirla **antes** de usarla | Bash lee el archivo de arriba para abajo |
| `local` en **toda** variable de la función | si no, es global y pisa las de afuera |
| Los argumentos son `$1`, `$2`, `"$@"` | pero son los **de la función**, no los del script |
| Nombre en `minusculas_con_guion_bajo` | convención |

## 6. 🔴 `return` vs `echo`

| | Qué devuelve | Cómo se lee |
|---|---|---|
| `return N` | un **estado** (0–255): 0 = bien, ≠0 = falló | `$?` o directamente un `if` |
| `echo`/`printf` | un **dato** (texto) | `x="$(funcion)"` |

```bash
calcular() { echo $(( $1 * 2 )); }
r="$(calcular 21)"        # r = 42          ✅

malo() { return 42; }
r="$(malo)"               # r = ""  (vacio) ❌  42 era un ESTADO, no un dato

validar() { [[ -f "$1" ]] || return 1; }
if validar "app.log"; then echo "ok"; fi    # asi se usa un return
```

> Si la función **imprime** y además devuelve estado: capturá con `$( )` para el dato y
> mirá `$?` para el estado.

## 7. Organizar el script: funciones + `main`

```bash
#!/usr/bin/env bash
set -euo pipefail

log()     { printf '[%s] %s\n' "$(date '+%F %T')" "$*" >&2; }
uso()     { echo "uso: $0 <directorio>" >&2; exit 2; }
validar() { local d="$1"; [[ -d "$d" && -r "$d" ]] || return 1; }

main() {
    (( $# >= 1 )) || uso
    local dir="$1"
    validar "$dir" || { log "no sirve: $dir"; return 1; }
    ...
}

main "$@"        # <-- la ULTIMA linea del archivo
```

La `main` se lee como un **índice**: en 6 líneas entendés qué hace el script.
Y `main "$@"` le pasa a la función los argumentos del script, tal cual.

## 8. El mínimo profesional (lo que se te pide en el reto)

- [ ] shebang + `set -euo pipefail`
- [ ] entrada **por argumento**, validada
- [ ] recorrido con **glob**, nunca `$(ls)`
- [ ] **todas** las variables entre comillas
- [ ] al menos **una función**, con `local`
- [ ] errores y avisos a `>&2`
- [ ] códigos de salida distintos (0 / 1 / 2)
- [ ] `shellcheck` limpio
