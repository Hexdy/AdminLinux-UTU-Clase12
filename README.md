# AdminLinux · UTU · Clase 12 — Shell scripting I (fundamentos y decisiones)

> Repo de la **Clase 12** de *Administración de Sistemas Linux* (UTU, 2026).
> Docente: **Ulyses García**. Repositorio **privado** de práctica.

Doble uso: 🤖 pegá `CONTEXTO_IA.md` en tu chatbot · 🧑‍💻 cloná y escribí tus primeros
scripts sobre los `datos/`.

## 🏁 El reto de hoy (empezalo YA)

**Cloná → resolvé mientras escuchás → verificás la 🏁 y se la decís al profe.**
No hay Pull Request para la bandera: la entrega es decírsela al docente.

| Paso | Qué hacés |
|---|---|
| 1 · Cloná | este repo, **fuera** de Google Drive / OneDrive |
| 2 · Resolvé | escribís **tu** `auditar.sh` mientras se explica la clase |
| 3 · Entregá | verificás la bandera con Ansible y **se la decís al profe** |

Todo el detalle en [`playbooks/README.md`](playbooks/README.md).

## 🚀 Arranque rápido

> 🔑 Cloná **fuera** de Google Drive / OneDrive. El sync corrompe `.git` y te mete
> finales de línea CRLF que rompen los scripts.

```bash
git clone <url-de-este-repo> ~/src/AdminLinux-UTU-Clase12
cd ~/src/AdminLinux-UTU-Clase12

# Tu primer script, en 3 comandos
cp docs/plantilla_script.sh mi_primer_script.sh
chmod +x mi_primer_script.sh
./mi_primer_script.sh datos/app.log
```

## 🗂️ Qué hay acá

| Carpeta / archivo | Qué es |
|---|---|
| `CONTEXTO_IA.md` | **Pegá esto en tu chatbot** para que te asista con contexto. |
| `datos/app.log` | Log de la app de práctica (78 líneas, usuarios e IPs ficticios). |
| `docs/chuleta_bash.md` | Toda la sintaxis de hoy en tablas + los errores típicos. |
| `docs/plantilla_script.sh` | El **encabezado profesional** listo para copiar. |
| `docs/reto_pull_request.md` | El reto de la clase y cómo se entrega. |
| `ejercicios/` | 8 ejercicios + soluciones comentadas. |
| `scripts/` | Ejemplos chiquitos de la clase, para leer y romper. |
| `playbooks/` | 🏁 **El reto de la bandera**: lo desplegás con Ansible (multi-distro) y lo resolvés escribiendo un script. |

## 🧵 Hilo del curso

Hasta acá **tipeabas** los comandos: `grep` (C3), `sed` (C4), `awk` (C5), `find` (C6),
`systemctl` (C10), `ssh` (C11). Hoy eso se **guarda en un archivo y corre solo**.

⚠️ **Hoy NO hay bucles ni funciones**: son la **Clase 13**, junto con `logger` y `cron`.
La **Clase 14** escala todo esto a **Ansible**.

## 🎯 Los 5 pilares

Hoy pegan fuerte **Security by Design** (comillas siempre, `set -euo pipefail`, cero
secretos hardcodeados, `mktemp`) e **IA aplicada** (los LLM escriben scripts sin comillas
y con `rm -rf` por concatenación → `shellcheck` **antes** de correr). El reto de
[`playbooks/`](playbooks/README.md) suma **IaC + Ansible**.

## ⚠️ Seguridad

- Tu script corre **con tus permisos** — y desde `cron` muchas veces como `root`.
- `rm -rf "$VAR"/*` con `$VAR` vacía es `rm -rf /*`. Por eso `set -u` y `"${VAR:?}"`.
- **Nunca** un token, contraseña o IP real en el código. Van en un archivo aparte con
  permiso `600`, y ese archivo va en `.gitignore`.

---

## ❓ Autoevaluación de la clase

> 5 preguntas para saber si **entendiste lo de hoy**. No hay soluciones — pensalas y, si
> te trabás, abrí la 💡 **Pista**.

### 1️⃣ El shebang
¿Qué hace la línea `#!/usr/bin/env bash` y por qué se prefiere a `#!/bin/bash` a secas?
<details><summary>💡 Pista</summary>

Es lo primero que lee el sistema: le dice **quién** tiene que interpretar el archivo.
Pensá qué pasa si en una distro `bash` no está exactamente en `/bin/`.
</details>

### 2️⃣ El encabezado profesional
Explicá **qué hace cada letra** de `set -euo pipefail`. ¿Cuál de las tres te salva de un
`rm -rf "$DESTINO"/*` cuando `$DESTINO` nunca se definió?
<details><summary>💡 Pista</summary>

Son tres cosas distintas: cortar ante un error, quejarse por una variable inexistente y
hacer que un pipe no mienta sobre su resultado.
</details>

### 3️⃣ Comillas
`ARCHIVO="mi informe.txt"`. ¿Por qué `rm $ARCHIVO` borra **dos** archivos y
`rm "$ARCHIVO"` borra **uno**?
<details><summary>💡 Pista</summary>

Antes de ejecutar, el shell **parte** lo que no está entrecomillado usando los espacios
como separador. Se llama *word splitting*.
</details>

### 4️⃣ Cadenas vs números
¿Por qué `[[ "9" > "10" ]]` es **verdadero** y `[[ 9 -gt 10 ]]` es **falso**? ¿Qué
operadores usás para cada caso?
<details><summary>💡 Pista</summary>

Uno compara como **texto** (letra por letra, como el diccionario) y el otro como
**número**. Fijate qué va primero en el diccionario: `"1"` o `"9"`.
</details>

### 5️⃣ Exit codes + IA
Le pedís un script a un LLM y te devuelve algo que anda, pero termina sin `exit`. ¿Qué
código devuelve entonces, y por qué le importa a `cron` y al pipeline de CI?
<details><summary>💡 Pista</summary>

Si no ponés `exit`, el script devuelve el del **último comando** que corrió. Pensá qué
pasa si ese último comando es un `echo` que siempre sale bien.
</details>

---

*Material docente. Elaborado con asistencia de IA y revisado por el docente.*
