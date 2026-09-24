# Reto de la semana — Clase 12 🏁 (la bandera)

Arrancamos el bloque de automatización como en un trabajo real: **desplegás el entorno con
Ansible**, **escribís tu propio script** para auditar lo que quedó, capturás la **bandera**
y **se la decís al profe**.

> 🐧 No es hacking: es el laburo de un sysadmin junior. Te dejaron un servidor con un log
> de 231 líneas y una carpeta de scripts viejos de un compañero que se fue, y te piden un
> informe. La bandera es la **recompensa** por hacerlo bien.

> 🏁 **Este reto NO se entrega por Pull Request.** No tenés que subir nada al repo:
> cuando tengas la bandera verificada, **se la decís al profe** (en clase o por el canal
> del curso). Eso es todo.

## Pasos

1. **Cloná fuera de Drive**:
   ```bash
   git clone <url> ~/src/AdminLinux-UTU-Clase12
   cd ~/src/AdminLinux-UTU-Clase12/playbooks
   ```
2. **Desplegá la estación con Ansible** (idempotente; simulá primero con `--check`):
   ```bash
   ./comprobar_requisitos.sh
   ansible-playbook armar_reto.yml -l local --check --diff
   ansible-playbook armar_reto.yml -l local
   ```
   Esto instala `shellcheck` y `gawk`, crea `datos/reto/` con los datos del servidor
   y te deja tu `MISION.txt`. Corré el playbook **dos veces**: la 2ª da `changed=0`
   (idempotencia).
3. **Escribí tu script** `auditar.sh` (podés partir de `docs/plantilla_script.sh`). Tiene
   que tener:
   - `#!/usr/bin/env bash` y `set -euo pipefail`
   - **validación**: que llegue el argumento y que el archivo exista y sea legible
   - **todas** las variables entre comillas
   - los errores a `stderr` (`>&2`)
   - `exit 0` / `exit 1` / `exit 2` según corresponda
   - que pase `shellcheck` limpio
4. **Sacá las 3 respuestas** (leé tu `MISION.txt`):
   - **R1** — cuántas líneas del log son de **nivel ERROR de verdad**.
     ⚠️ `grep -c ERROR` **te miente**: cuenta también las que dicen "ERROR" adentro del
     mensaje. Mirá el **segundo campo** de cada línea.
   - **R2** — qué **servicio** acumula más líneas de nivel ERROR (el **tercer** campo).
   - **R3** — cuántos archivos `.sh` de `scripts_reto/` **no** tienen shebang en la
     línea 1.
5. **Armá la bandera** con el formato exacto y **verificala** con Ansible:
   ```bash
   ansible-playbook comprobar_bandera.yml -e "bandera=BANDERA{<R1>-<R2>-<R3>}"
   ```
   Tiene que dar **✅ BANDERA CORRECTA**.
6. **Decile la bandera al profe** — en clase o por el canal del curso. Con eso el reto
   queda entregado. **No hace falta subir nada al repo** ni abrir un Pull Request.

## Cómo se evalúa (autoevaluación)

- [ ] Desplegaste con `armar_reto.yml` y lo corriste **2 veces** (la 2ª da `changed=0`).
- [ ] Tu `auditar.sh` tiene shebang, `set -euo pipefail` y **comillas en todo**.
- [ ] Valida el argumento y el archivo **antes** de tocarlo, y sale con `exit 2` si falta.
- [ ] Los mensajes de error salen por `stderr`, no mezclados con el resultado.
- [ ] `shellcheck auditar.sh` sale **limpio**.
- [ ] **R1** cuenta el **nivel**, no la palabra suelta.
- [ ] `comprobar_bandera.yml` te dio ✅ **BANDERA CORRECTA**.
- [ ] Le **dijiste la bandera al profe**.

> 🔒 El repo no guarda la bandera en claro, solo su **hash SHA-256**. Así se guardan las
> contraseñas de verdad: nunca el secreto, solo su huella.

> 🤖 Si le pedís el script a la IA: **leelo entero**, pasalo por `shellcheck`, y si tiene
> un `rm` cambialo por `echo rm` para ver qué **habría** borrado. Las IA escriben scripts
> sin comillas y sin `set -euo pipefail` todo el tiempo.

> 🪟 Si editás en Windows y al correrlo te dice `bash\r: command not found`, el archivo
> quedó en CRLF: `dos2unix auditar.sh`.
