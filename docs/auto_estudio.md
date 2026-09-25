# Auto-estudio — lo que NO entró en los 110 minutos

> La Clase 12 fusiona todo el saber 5 (5.1 a 5.8) en una sola sesión. Estos temas
> **sí entran en el programa del curso**, pero se estudian acá, tranquilo, con la
> máquina adelante. El primero es **obligatorio**: te va a pasar en el reto de hoy.

## 1. 🔴 El acumulador que siempre da 0 (leelo ANTES del reto)

```bash
total=0
grep -c '\[ERROR\]' *.log | while read -r n; do
    total=$(( total + n ))
done
echo "$total"       # -> 0   ¿¿por qué??
```

Cada lado de un `|` corre en un **proceso aparte**. El `while` de la derecha es un
**hijo**: hereda una **copia** de `total`, la modifica... y cuando termina, la copia
muere con él. El padre nunca se entera.

```
   PADRE                          HIJO (por el pipe)
   total=0                        copia de total=0
     |                              |
     |   ---- pipe ---->            suma 23 -> 23
     |                              suma 17 -> 40
     |                              TERMINA: la copia se pierde
   total sigue valiendo 0   <-------+
```

**La solución**: sacar el pipe y usar una **redirección de proceso**, para que el
`while` quede en el **padre**:

```bash
total=0
while read -r n; do
    total=$(( total + n ))
done < <(grep -c '\[ERROR\]' *.log)     # ojo: < <(...) va con un espacio en el medio
echo "$total"
```

También sirve acumular en un archivo temporal, o hacer la suma con `awk` (Clase 5),
pero el modismo `done < <(...)` es el que vas a ver en todos lados.

## 2. `trap` y `mktemp`: limpiar aunque el script se muera

```bash
tmp="$(mktemp)"                       # nombre aleatorio, permisos 600
trap 'rm -f "$tmp"' EXIT              # se ejecuta SIEMPRE al salir, falle o no
comando_grande > "$tmp"
```

`trap '<comando>' <SEÑAL>` te deja enganchar una acción a una señal:

| Señal | Cuándo |
|---|---|
| `EXIT` | siempre que el script termina (bien o mal) |
| `INT` | Ctrl+C |
| `TERM` | `kill` normal |
| `ERR` | cualquier comando que falle (con `set -e`) |

> 🔒 Un temporal con nombre fijo (`/tmp/mi_temp.$$`) es **adivinable**: otro usuario
> puede plantar un enlace ahí y hacer que tu script escriba donde él quiera. `mktemp`
> lo evita.

## 3. Arrays

```bash
servicios=("ssh" "cron" "nginx")
echo "${servicios[0]}"        # ssh
echo "${servicios[@]}"        # todos
echo "${#servicios[@]}"       # cuantos hay: 3
servicios+=("postgresql")     # agregar al final

for s in "${servicios[@]}"; do
    systemctl is-active --quiet "$s" && echo "$s: ok" || echo "$s: caido"
done
```

Y el **array asociativo** (diccionario), que es lo que usarías para contar por clave:

```bash
declare -A cuenta
cuenta["api01"]=29
for k in "${!cuenta[@]}"; do echo "$k -> ${cuenta[$k]}"; done
```

## 4. `until`, `break N` y bucles anidados

```bash
until systemctl is-active --quiet nginx; do sleep 2; done   # repetir HASTA que se cumpla

for d in /srv/*/; do
    for f in "$d"*.log; do
        [[ -e "$f" ]] || continue
        [[ "$f" == *secreto* ]] && break 2      # sale de LOS DOS bucles
    done
done
```

## 5. `printf` en serio (mejor que `echo` para formatear)

```bash
printf '%-20s %5s\n' "archivo" "errores"     # columna izquierda 20, derecha 5
printf '%-20s %5d\n' "api01.log" 29
printf '%.2f\n' 3.14159                      # 3.14
printf '%s\n' "${servicios[@]}"              # uno por linea
```

`echo` cambia de comportamiento entre shells; `printf` no. Para salida "de reporte",
usá `printf`.

## 6. Depurar: `bash -x` y amigos

```bash
bash -n script.sh        # solo sintaxis, no ejecuta
bash -x script.sh        # muestra cada linea (ya expandida) antes de correrla
set -x ; ...codigo... ; set +x     # trazar solo un pedazo
shellcheck script.sh     # el corrector ortografico de Bash
```

`shellcheck` te marca `SC2086` ("falta comillas"), `SC2046`, `SC2164`… En los equipos
serios corre en el **CI**: si no pasa, el Pull Request no se mergea.

## 7. `getopts`: opciones estilo `-v -f archivo`

```bash
while getopts ":vf:" opt; do
    case "$opt" in
        v) verbose=1 ;;
        f) archivo="$OPTARG" ;;
        \?) echo "opcion invalida: -$OPTARG" >&2; exit 2 ;;
        :)  echo "la opcion -$OPTARG necesita un valor" >&2; exit 2 ;;
    esac
done
shift $(( OPTIND - 1 ))
```

Cuando tu script crece y `$1 $2 $3` ya no alcanza, esto es lo que se usa.

## 8. `systemd timers` a fondo

El ejemplo completo (`.service` + `.timer` + `OnCalendar` + `Persistent=true`) está en
`chuleta_cron.md`, sección 5. Practicalo en tu VM: agendá algo cada 2 minutos, mirá
`systemctl list-timers` y `journalctl -u tu.service`, y después borralo.

---

> 📌 Todo esto **puede aparecer en el parcial** como lectura de código (entender qué
> hace un script que lo usa), no como escritura de memoria.
