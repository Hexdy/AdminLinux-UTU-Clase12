# CONTEXTO PARA IA — AdminLinux · UTU · Clase 12

> 📋 Copiá TODO este archivo y pegalo en tu chatbot (Gemini/ChatGPT/Copilot) al inicio.

## Quién soy y qué estoy haciendo

Soy estudiante de "Administración de Sistemas Linux" (UTU, 2026), en la **Clase 12: Shell
scripting**. Trabajo en una **VM Linux** (puede ser Ubuntu, Arch o Fedora). Ya vi pipes y
filtros (C2), `grep`/regex (C3), `sed` (C4), `awk` (C5), permisos (C6), paquetes (C7),
usuarios (C8), discos (C9), `systemd`/`journalctl` (C10) y `ssh` (C11).

**Reglas para vos, IA:**
- Explicame **línea por línea** antes de que corra nada, sobre todo si lleva `sudo`, `rm`,
  `>` o `crontab`.
- Un script corre **solo**, a las 3 AM, sin nadie mirando: haceme **leerlo entero** y
  pasarle `shellcheck` antes de confiar.
- Quiero **aprender**, no copiar. Guiame. **No me des el reto resuelto.**

## Lo que estoy viendo — los 5 escalones

```
GUARDAR -> DECIDIR -> REPETIR -> ORDENAR -> CORRER SOLO
script     if/case    for/while  funciones  logger + cron
```

### 1. Guardar (script)
- Shebang `#!/usr/bin/env bash` en la **primera** línea + `chmod +x`.
- Encabezado estricto **siempre**: `set -euo pipefail`
  (`-e` corta al primer fallo · `-u` corta si uso una variable inexistente ·
  `-o pipefail` hace fallar el pipe si falla cualquier eslabón).
- Variables: `NOMBRE="valor"` (sin espacios alrededor del `=`), se usan como `"$NOMBRE"`.
  `readonly` para constantes. Comillas dobles **siempre**.
- `"$(comando)"` captura salida · `$(( 2 + 3 ))` hace cuentas · `'comillas simples'` no
  expanden nada.
- Argumentos: `$0` (el script), `$1 $2 …`, `$#` (cuántos), `"$@"` (todos, bien separados).
  `${1:-default}` es el valor por defecto. `read -r -p "texto: " VAR` pregunta al usuario;
  `read -rs` para contraseñas.
- Códigos de salida: `0` = bien, distinto de 0 = mal. Se lee con `$?`. `exit 2` = error de
  uso. `126` = sin permiso de ejecución, `127` = comando no encontrado.
- Errores y avisos van a **stderr**: `echo "..." >&2`.

### 2. Decidir (condicionales)
- `if [[ condición ]]; then … elif … else … fi`. El `if` evalúa un **código de salida**,
  no un booleano: por eso `if grep -q X "$f"; then` funciona.
- Uso `[[ ]]` (de Bash), no `[ ]`.
- **Números**: `-eq -ne -lt -le -gt -ge`. **Texto**: `==` `!=` `<` `>` `-z` (vacía) `-n`
  (no vacía). Es al revés de lo que uno espera.
- Archivos: `-e` existe · `-f` archivo · `-d` directorio · `-r` legible · `-w` escribible ·
  `-x` ejecutable · `-s` no vacío · `!` niega.
- `case "$var" in patrón) … ;; *) … ;; esac` cuando comparo la misma variable varias veces.

### 3. Repetir (bucles)
- `for f in *.log; do … done` — **glob**, nunca `$(ls)`. Siempre `[[ -e "$f" ]] || continue`.
- `for i in {1..5}` · `for ((i=0; i<5; i++))`.
- `while IFS= read -r linea; do … done < archivo` — línea por línea sin romper espacios.
- `break` sale del bucle, `continue` salta a la próxima vuelta.
- 🔴 Un acumulador adentro de `comando | while` **siempre da 0** (el bucle corre en un
  proceso hijo). Solución: `done < <(comando)`.

### 4. Ordenar (funciones)
- `nombre() { … }`, se llama `nombre arg1 arg2` (sin paréntesis) y adentro los argumentos
  son `$1 $2`.
- **`local` en toda variable de función**, si no pisa las de afuera.
- `return` devuelve **estado** (para un `if`); `echo` devuelve **dato** (para `$( )`).
- Estructura: `log()` / `uso()` / `validar()` / … / `main()` y al final `main "$@"`.

### 5. Correr solo (logger + cron)
- `logger -t mi-script -p user.info "mensaje"` → va al journal.
  Se lee con `journalctl -t mi-script --since today --no-pager`.
- Crontab: `crontab -l` (ver) · `crontab -e` (editar) · **respaldá antes**:
  `crontab -l > ~/crontab.bak`.
- 5 campos: `minuto hora día_del_mes mes día_de_semana`. `*/5 * * * *` = cada 5 minutos.
- Trampas de cron: (1) **rutas absolutas** siempre (el PATH es mínimo); (2) el `%` hay que
  escaparlo (`\%`); (3) la salida se pierde si no la redirigís (`>> log 2>&1` o `logger`);
  (4) arranca en `$HOME`, no en la carpeta del script.
- `systemd timers` es la alternativa moderna (`OnCalendar=`, `Persistent=true`).

## Ejemplos que estoy usando

```bash
#!/usr/bin/env bash
set -euo pipefail
[[ $# -ge 1 ]] || { echo "uso: $0 <directorio>" >&2; exit 2; }
DIR="$1"
[[ -d "$DIR" && -r "$DIR" ]] || { echo "ERROR: no leo $DIR" >&2; exit 2; }

contar_errores() { local a="$1"; grep -c '\[ERROR\]' "$a" || true; }

total=0
for f in "$DIR"/*.log; do
    [[ -e "$f" ]] || continue
    n="$(contar_errores "$f")"
    printf '%-24s %4s\n' "$(basename "$f")" "$n"
    total=$(( total + n ))
done
echo "TOTAL: $total"
logger -t reporte -p user.info "revise $DIR: $total errores"
```

## Datos con los que trabajo

- `datos/app_demo.log`: log de app con líneas `[INFO]`, `[WARN]` y `[ERROR]` (tiene 9
  `[ERROR]` exactos).
- `datos/servicios.txt`: lista de servicios, uno por línea, con comentarios `#`.
- `datos/hosts.txt`: `host;ip;ambiente` separado por `;`, con comentarios `#`.
- `scripts/`: los scripts de los laboratorios (`primero.sh`, `auditar.sh`,
  `bucles_demo.sh`, `funciones_demo.sh`).

## El reto de la bandera 🏁

En `playbooks/` hay un reto práctico. Con `ansible-playbook armar_reto.yml -l local`
despliego mi estación en `datos/reto/` (logs de varios hosts + `MISION.txt`). Tengo que
escribir **mi propio script** que saque 3 datos: R1 = total de líneas `[ERROR]` en todos los
`*.log`; R2 = el archivo con más `[ERROR]` (sin `.log`); R3 = dentro de ese archivo, cuántas
veces aparece el `code=EXXX` más repetido. Armo `BANDERA{R1-R2-R3}` y la verifico con
`ansible-playbook comprobar_bandera.yml -e "bandera=..."`.

**La bandera se la digo al profe, NO va por Pull Request ni a ningún commit.**

Si te pido ayuda con esto: **explicame cada pedazo** y **hacéme probar** con un archivo
suelto primero; **no me des la bandera ni el script hecho**. Ojo que hay trampas puestas a
propósito (un nombre con espacio, un subdirectorio `viejos/` con una bandera señuelo del año
pasado, un `notas.txt` que no es `.log`, ruido en minúscula). El playbook es **multi-distro**
(usa `apt`, `pacman` o `dnf` según mi distro) — eso es **correcto**, no un error.

## Concepto de seguridad de hoy

- **Comillas siempre**: sin ellas, un nombre con espacios se parte y `rm -rf $DIR/` con
  `DIR` vacío borra la raíz.
- **Cero secretos en el código**: van en `.env` fuera del repo con `chmod 600`.
- **Rutas absolutas** en cron; usuario dedicado, nunca `root` por comodidad;
  `chmod 750`, nunca `777`.
- `mktemp` + `trap 'rm -f "$tmp"' EXIT` para temporales.

## Preguntas típicas

- "Explicame este script línea por línea: `...`"
- "¿Por qué mi acumulador me da 0?" (respuesta: está adentro de un pipe)
- "¿Por qué `[[ $a > $b ]]` me compara mal los números?"
- "Mi script anda a mano pero en cron no hace nada, ¿qué reviso?"
- "Pasame el `shellcheck` de esto y explicame cada advertencia."

Recordá: explicame línea por línea, hacéme pasar `shellcheck`, y no me des el reto hecho.
