# 🏁 El reto de la bandera — Clase 12 (Shell scripting I)

> **Ansible arma el entorno · vos escribís el script · la bandera es la recompensa.**
> Este reto **no se entrega por Pull Request**: cuando la tengas verificada, **se la
> decís al profe**.

## Qué es esto

Entrás a un equipo nuevo. El compañero que se fue dejó una app con su log y una carpeta
de scripts viejos. Te piden un informe — y la regla de la casa es que **no se hace a
mano**: se hace con un **script**, para que mañana lo corra cualquiera.

Con un solo comando desplegás tu estación de trabajo (multi-distro), leés tu misión
personalizada, **escribís tu `auditar.sh`** y sacás 3 respuestas. Con esas 3 armás la
bandera y la verificás.

## 0. ¿Tenés todo?

```bash
bash comprobar_requisitos.sh
```

Te detecta la distro (`apt` / `pacman` / `dnf`) y, si falta algo, te dice el comando
exacto para instalarlo. **No instala nada por vos.**

## 1. Desplegá el entorno

```bash
# Simular primero (no toca nada) — RECOMENDADO la 1ª vez
ansible-playbook armar_reto.yml -l local --check --diff

# Aplicar de verdad (si te pide contraseña de sudo, agregá -K)
ansible-playbook armar_reto.yml -l local
```

O el atajo: `bash correr.sh`.

Corrélo **dos veces**: la 2ª tiene que dar `changed=0`. Eso es **idempotencia**, y es la
diferencia entre un script que "hace cosas" y uno que **garantiza un estado**.

El playbook:

| Paso | Módulo | Qué hace |
|---|---|---|
| 1 | `assert` | comprueba que tu distro esté soportada (Debian / Arch / RedHat) |
| 2 | `package` (en `block`/`rescue`) | instala `shellcheck` y `gawk` con **tu** gestor. Si falla, **avisa y sigue** |
| 3 | `file` | crea el área de trabajo `datos/reto/` |
| 4 | `copy` | deja el log, los scripts viejos y la plantilla |
| 5 | `template` | genera **tu** `MISION.txt` con los datos de **tu** máquina |
| 6 | `copy` (`mode: 0600`) | deja la nota del equipo **solo legible por vos** |
| 7 | `command` (`changed_when: false`) | te muestra cuánto material quedó listo |

> 🐧 **El mismo playbook corre en Ubuntu, Arch y Fedora** sin cambiar una línea.
> El módulo `package` elige `apt`, `pacman` o `dnf` según `ansible_os_family`, y el
> paquete de shellcheck se llama `ShellCheck` (con mayúsculas) solo en Fedora/RHEL.

## 2. Leé tu misión

```bash
cat ../datos/reto/MISION.txt
```

## 3. Escribí tu script

Partí de la plantilla:

```bash
cd ../datos/reto
cp plantilla_script.sh auditar.sh
chmod +x auditar.sh
```

Tiene que tener: shebang `#!/usr/bin/env bash`, `set -euo pipefail`, **validación** del
argumento y del archivo (`-f`, `-r`), **todas** las variables entre comillas, errores a
`stderr` (`>&2`) y `exit 0/1/2`. Y tiene que pasar `shellcheck auditar.sh` **limpio**.

⚠️ **Sin bucles ni funciones** — eso es la Clase 13. Se resuelve con lo de hoy.

## 4. Las 3 respuestas

- **R1** — cuántas líneas del log son de **nivel ERROR**.
  ⚠️ `grep -c ERROR` **te miente**: el nivel es el **segundo campo**.
- **R2** — qué **servicio** (tercer campo) acumula más líneas de nivel ERROR.
- **R3** — cuántos `.sh` de `scripts_reto/` **no** tienen shebang en la línea 1.

## 5. Verificá la bandera

```bash
ansible-playbook comprobar_bandera.yml -e "bandera=BANDERA{<R1>-<R2>-<R3>}"
```

- ✅ **BANDERA CORRECTA** → trofeo.
- ❌ incorrecta → el playbook te dice **qué revisar** de cada respuesta.

## 6. Entregá

**Decile la bandera al profe** (en clase o por el canal del curso). Listo. **No** hace
falta subir nada al repo ni abrir un Pull Request.

---

## 🔒 Security by design en este reto

- El repo **no guarda la bandera en claro**: solo su **huella SHA-256** en
  `secretos/bandera.sha256`. El playbook compara **hashes**. Es la misma idea con la que
  se guardan las contraseñas de verdad (que además usan hashing lento con sal).
- La nota del equipo se copia con `mode: '0600'` — **solo su dueño** la lee.
- Adentro de `scripts_reto/` hay un script con un **token hardcodeado**. Es un
  **antipatrón a propósito**: el valor es falso. Cuando lo veas, ya sabés por qué está mal.
- Los usuarios e IPs del log son **ficticios** y de **rango privado**.

## 🗂️ Mapa de la carpeta

| Archivo | Qué es |
|---|---|
| `armar_reto.yml` | despliega tu estación (multi-distro, idempotente) |
| `comprobar_bandera.yml` | verifica tu bandera **por hash** |
| `comprobar_requisitos.sh` | chequea que tengas Ansible, Python, shellcheck, gawk |
| `correr.sh` | atajo: requisitos + armar |
| `ansible.cfg` | config local (usa `inventory.ini` sin pasarlo a mano) |
| `inventory.ini` | qué máquinas administra Ansible (acá: `localhost`) |
| `templates/mision.txt.j2` | la plantilla Jinja2 de tu `MISION.txt` |
| `reto/app_reto.log` | el log de la app |
| `reto/scripts_reto/` | los scripts viejos del compañero |
| `reto/nota_equipo.txt` | la nota del equipo (se copia con `0600`) |
| `secretos/bandera.sha256` | **solo el hash** de la bandera |

> 🤖 Si le pedís el script a la IA: **leelo entero**, pasalo por `shellcheck`, y si tiene
> un `rm` cambialo por `echo rm` para ver qué **habría** borrado.
