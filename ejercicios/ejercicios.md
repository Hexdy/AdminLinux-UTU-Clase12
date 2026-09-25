# Ejercicios — Clase 12 · Shell scripting

> Trabajá en `datos/` (ahí están `app_demo.log`, `servicios.txt` y `hosts.txt`).
> Las soluciones están en `soluciones.md`: **miralas recién después de intentarlo**.
> Pasale `shellcheck` a **todos** tus scripts: tiene que salir limpio.

## Bloque A — Escalón 1: guardar

**A1.** Escribí `hola.sh` que salude con tu nombre. Tiene que tener shebang,
`set -euo pipefail` y un comentario de cabecera. Dale permiso y corrélo con `./hola.sh`.

**A2.** ¿Qué código de salida te da correr `./hola.sh` **sin** haberle dado `chmod +x`?
¿Y si escribís mal el nombre? Comprobalo con `echo $?`.

**A3.** Escribí `info_sistema.sh` que muestre, cada uno en su línea: la fecha (`date +%F`),
el hostname, y cuántos archivos hay en `/etc`. Usá `$( )` para todos.

**A4.** Hacé que `info_sistema.sh` acepte un directorio **por argumento** y cuente ahí.
Si no le pasan nada, que use `/etc` (valor por defecto con `${1:-/etc}`).

**A5.** Guardá `ARCHIVO="mi informe.txt"` y probá `ls $ARCHIVO` y `ls "$ARCHIVO"`.
Explicá en un comentario por qué dan distinto.

## Bloque B — Escalón 2: decidir

**B1.** Escribí `revisar.sh <ruta>` que diga si la ruta es un archivo, un directorio o
no existe. Usá `[[ ]]` y `elif`.

**B2.** Mejorá `revisar.sh`: si es un archivo pero **no** lo podés leer, avisá por
`>&2` y salí con código 2.

**B3.** Escribí `umbral.sh <ruta_log> <umbral>` que cuente las líneas `[ERROR]` de
`datos/app_demo.log` y salga con `1` si superan el umbral, `0` si no. Validá que el
umbral sea un número.

**B4.** Agregale a `umbral.sh` un `case` que acepte como primer argumento `--ayuda`
y muestre el uso saliendo con 0.

**B5.** ¿Por qué `[[ "10" > "9" ]]` es **verdadero** y `[[ 10 -gt 9 ]]` también, pero
`[[ "10" > "9" ]]` con números grandes te puede engañar? Dejá la explicación en un
comentario.

## Bloque C — Escalón 3: repetir

**C1.** Escribí un `for` que imprima cada servicio de `datos/servicios.txt`... y
explique por qué **no** conviene hacerlo con `for s in $(cat archivo)`.

**C2.** Recorré con **glob** todos los `.log` de `datos/` e imprimí `nombre: cantidad de
líneas`. Acordate del `[[ -e "$f" ]] || continue`.

**C3.** Creá a mano un archivo llamado `prueba con espacio.log` en una carpeta de
juguete. Recorré la carpeta con `for f in $(ls)` y después con `for f in *.log`.
Mostrá la diferencia.

**C4.** Leé `datos/hosts.txt` línea por línea con `while IFS= read -r` y, salteando los
comentarios (`#`), imprimí solo el host y el ambiente (campos 1 y 3, separados por `;`).

**C5.** 🔴 Sumá el total de líneas `[ERROR]` de todos los `.log` de `datos/` usando un
acumulador. Probá primero con `grep -c ... | while read` y explicá por qué da 0.

## Bloque D — Escalón 4: ordenar

**D1.** Escribí una función `contar_errores <archivo>` que devuelva el número por `echo`
y usala con `n="$(contar_errores ...)"`.

**D2.** Escribí una función `validar_log <archivo>` que **no** imprima nada y use
`return 0` / `return 1`. Usala en un `if`.

**D3.** Demostrá el problema de no usar `local`: escribí una función que use una
variable `f` sin `local` y llamala desde adentro de un `for f in ...`.

**D4.** Reescribí tu script del ejercicio C5 con la estructura
`log() / uso() / validar() / main()` + `main "$@"` al final.

## Bloque E — Escalón 5: dejar rastro y correr solo

**E1.** Hacé que tu script de D4 escriba dos mensajes con `logger -t` (uno `user.info`
al arrancar, uno `user.err` si falla). Leelos con `journalctl -t ... --no-pager`.

**E2.** Escribí la línea de crontab para: (a) todos los días a las 02:30;
(b) cada 5 minutos; (c) los lunes a las 07:00; (d) el día 1 de cada mes a medianoche.

**E3.** ¿Qué tiene de malo esta línea? Arreglala:
`0 3 * * * respaldo.sh > /backup/$(date +%F).log`  (hay **tres** problemas).

**E4.** Respaldá tu crontab, agendá tu script del E1 para dentro de 2 minutos, verificá
en el journal que corrió, y **borrá** la entrada.

**E5.** ¿Cómo se llama el servicio de cron **en tu distro**? Averigualo con
`systemctl list-units '*cron*'` y mirá su log con `journalctl -u <unit> --no-pager`.

## Bloque F — Integrador

**F1.** Escribí `reporte_logs.sh <directorio>` que, con los 5 escalones, imprima una
tabla con `printf` de `archivo | lineas | errores` para cada `.log`, y al final el total.
Que valide el argumento, use al menos una función con `local`, mande los errores a
`>&2`, devuelva 0/1/2 y pase `shellcheck` limpio.

**F2.** Agregale a `reporte_logs.sh` un segundo argumento opcional: el umbral de errores
a partir del cual sale con código 1 y escribe un `logger -p user.err`.

**F3.** 🏁 Con todo esto ya tenés las piezas del **reto de la bandera**. Volvé a
`playbooks/README.md`.
