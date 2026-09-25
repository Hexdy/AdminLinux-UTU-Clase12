# AdminLinux · UTU · Clase 12 — Shell scripting

> Repo de la **Clase 12** de *Administración de Sistemas Linux* (UTU, 2026).
> Docente: **Ulyses García**. Repositorio **privado** de práctica.

Doble uso: 🤖 pegá `CONTEXTO_IA.md` en tu chatbot · 🧑‍💻 cloná y escribí **tus** scripts
sobre los `datos/`.

## 🚀 Arranque rápido

> 🔑 Cloná **fuera** de Google Drive / OneDrive. El sync corrompe `.git`.

```bash
git clone <url-de-este-repo> ~/AdminLinux-UTU-Clase12
cd ~/AdminLinux-UTU-Clase12

# Tu primer script, en 3 lineas:
printf '#!/usr/bin/env bash\nset -euo pipefail\necho "Hola, %s"\n' "$USER" > hola.sh
chmod +x hola.sh && ./hola.sh
```

## 🏁 El reto de la bandera (empezalo YA, mientras escuchás la clase)

Sos el **SRE de guardia**: la plataforma tuvo una noche fea y te dejaron los logs de
**todos** los hosts. Son demasiados para mirarlos a mano — **para eso existen los bucles**.
El jefe de guardia quiere 3 datos para el postmortem.

```bash
cd playbooks
bash comprobar_requisitos.sh                              # que no te falte nada
ansible-playbook armar_reto.yml -l local                  # corrélo 2 veces: la 2a da changed=0
cat ../datos/reto/MISION.txt
```

| # | Dato que hay que sacar | Con qué se resuelve |
|---|---|---|
| **R1** | **Total** de líneas con el nivel `[ERROR]` exacto, en **todos** los `*.log` | `for` sobre el glob + acumulador |
| **R2** | Qué archivo juntó **más** `[ERROR]` (sin la extensión `.log`) | una **función** que cuente + comparar |
| **R3** | Dentro de **ese** archivo, cuántas veces aparece el `code=EXXX` más repetido | campos + `sort` + `uniq -c` |

Bandera: `BANDERA{<R1>-<R2>-<R3>}`, y se verifica con

```bash
ansible-playbook comprobar_bandera.yml -e "bandera=BANDERA{...}"
```

⚠️ Hay **4 trampas** a propósito (un nombre con espacio, un `viejos/` del año pasado con
una bandera **señuelo**, un `notas.txt` que no es `.log`, y ruido en minúscula). Y una
quinta que te vas a hacer solo: el acumulador adentro de un pipe → `docs/auto_estudio.md`.

> 💬 **La bandera se la decís al profe. NO se entrega por Pull Request.** El detalle en
> [`docs/reto_pull_request.md`](docs/reto_pull_request.md).

> 🔒 El repo **no** guarda la bandera en claro, solo su **huella SHA-256** en
> `playbooks/secretos/bandera.sha256` — igual que las contraseñas de verdad.

## 🗂️ Qué hay acá

| Carpeta / archivo | Qué es |
|---|---|
| `CONTEXTO_IA.md` | **Pegá esto en tu chatbot** para que te asista con contexto. |
| `datos/app_demo.log` | Log de la app para los laboratorios 1 y 2 (tiene 9 `[ERROR]`). |
| `datos/servicios.txt` · `datos/hosts.txt` | Listas para practicar `for` y `while read`. |
| `scripts/` | Los scripts de los laboratorios, listos para leer y romper. |
| `ejercicios/` | 6 bloques de ejercicios (A→F) + soluciones. |
| `docs/` | 3 chuletas (Bash, bucles/funciones, cron) + plantilla + auto-estudio + cómo entregás. |
| `playbooks/` | 🏁 **El reto de la bandera**: Ansible multi-distro arma tu estación. |

## 🪜 Los 5 escalones de la clase

```
   GUARDAR  ->  DECIDIR  ->  REPETIR  ->  ORDENAR  ->  CORRER SOLO
   script       if/case      for/while    funciones    logger + cron
   5.1 5.2      5.3          5.4          5.5          5.6 5.7 5.8
```

## 🧵 Hilo del curso

Desde marzo venís escribiendo comandos **de a uno**. Hoy los **guardás** en un archivo y
la terminal pasa a trabajar sin vos. Todo lo que ya sabés entra acá adentro: `grep` (C3),
`sed` (C4), `awk` (C5), permisos (C6), `systemctl`/`journalctl` (C10), `ssh` (C11).

> 🔜 **Clase 13**: tus scripts automatizan **en el tiempo** (la misma máquina, una y otra
> vez). **Ansible** automatiza **en escala** (cuarenta máquinas, una sola vez) — es el
> `correr.sh` que venís corriendo desde marzo sin preguntar qué era.

## 🎯 Los 5 pilares

Hoy pegan fuerte **Security by Design** (comillas, `set -euo pipefail`, cero secretos en el
código, rutas absolutas en cron) e **IA aplicada** (un script que la IA te escribió corre
**solo**, a las 3 AM, sin nadie mirando: leelo línea por línea y pasale `shellcheck`). El
reto suma **IaC + Ansible** y el repo, **GitHub**.

## ⚠️ Seguridad

- **Comillas siempre**: `"$VAR"`. Sin comillas, un nombre con espacios se parte en dos y
  un `rm -rf $DIR/` con `DIR` vacío te borra la raíz.
- **Cero secretos en el script**: van en `.env` (fuera del repo, `chmod 600`) o en un
  gestor. El script se versiona; la contraseña, no.
- **Rutas absolutas en cron**: el `PATH` de cron es mínimo. "Me anda a mano pero no en
  cron" es *siempre* esto.
- **Nunca `chmod 777`** un script. `750` y usuario dedicado.

---

## ❓ Autoevaluación de la clase

> 5 preguntas para saber si **entendiste lo de hoy**. No hay soluciones — pensalas y, si
> te trabás, abrí la 💡 **Pista**.

### 1️⃣ El encabezado estricto
¿Qué hace cada una de las tres partes de `set -euo pipefail` y por qué la ponés en **todos**
tus scripts?
<details><summary>💡 Pista</summary>

`-e` corta al primer comando que falla (en vez de seguir con datos rotos); `-u` corta si usás
una variable que no existe (ahí muere el `rm -rf $DIR/` con `DIR` vacío); `-o pipefail` hace
que un pipe falle si **cualquier** eslabón falla, no solo el último.
</details>

### 2️⃣ Texto o número
¿Por qué `[[ "9" > "10" ]]` es **verdadero** y `[[ 9 -gt 10 ]]` es **falso**? ¿Cuál usás
para comparar cantidades?
<details><summary>💡 Pista</summary>

Los **símbolos** (`==`, `<`, `>`) comparan **texto**, carácter por carácter: `"9"` es
alfabéticamente mayor que `"1"`. Las de **letras** (`-eq`, `-lt`, `-gt`) comparan **números**.
Suena al revés de lo que uno esperaría: por eso se equivocan todos.
</details>

### 3️⃣ La trampa del `ls`
¿Qué le pasa a `for f in $(ls)` cuando hay un archivo llamado `mi informe.log`? ¿Con qué
lo reemplazás?
<details><summary>💡 Pista</summary>

La salida de `ls` se parte por **espacios**, así que ese archivo entra como **dos** vueltas
(`mi` y `informe.log`), ninguna de las cuales existe. El glob `for f in *.log` le pasa a
Bash la lista real de archivos, con espacios y todo. Acordate del `[[ -e "$f" ]] || continue`.
</details>

### 4️⃣ `return` vs `echo`
En una función, ¿cuándo usás `return` y cuándo `echo`? ¿Qué te devuelve
`resultado=$(mi_funcion)` si la función hace `return 7`?
<details><summary>💡 Pista</summary>

`return` devuelve **estado** (0 = salió bien) y se lee con `$?` o dentro de un `if`. `echo`
devuelve **dato** y se captura con `$( )`. Con `return 7` la captura te deja `resultado`
**vacío**: el 7 se fue a `$?`, no a la salida.
</details>

### 5️⃣ Cron que "no anda"
Tu script corre perfecto a mano, pero agendado en cron no hace nada y no deja ni un
mensaje. Nombrá **tres** causas probables y cómo las verificás.
<details><summary>💡 Pista</summary>

(1) Ruta relativa: el `PATH` de cron es mínimo → usá rutas **absolutas** para el script y
para los comandos. (2) El script depende del directorio actual → cron arranca en `$HOME`;
hacé `cd` explícito. (3) La salida se pierde → redirigí `>> log 2>&1` o mandá todo a
`logger` y mirá con `journalctl -t <tag>`. Bonus: el `%` en el crontab es especial y hay que
escaparlo.
</details>

---

*Material docente. Elaborado con asistencia de IA y revisado por el docente.*
