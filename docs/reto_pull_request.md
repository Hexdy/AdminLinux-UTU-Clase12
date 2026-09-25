# 🏁 Cómo entregás la bandera (NO hay Pull Request)

> En esta clase **no se entrega por Pull Request**. El reto es de tipo **CTF**: cuando
> tengas la bandera verificada, **se la decís al profe**. Simple.

## Los 5 pasos

| # | Paso | Comando |
|---|---|---|
| 1 | Cloná el repo **fuera de Google Drive / OneDrive** | `git clone <url>` |
| 2 | Preflight: ¿tenés todo? | `cd playbooks && bash comprobar_requisitos.sh` |
| 3 | Desplegá el reto (corrélo **dos veces**: la 2ª debe dar `changed=0`) | `ansible-playbook armar_reto.yml -l local` |
| 4 | Escribí **tu** script y sacá R1, R2 y R3 | `cat ../datos/reto/MISION.txt` |
| 5 | Verificá la bandera | `ansible-playbook comprobar_bandera.yml -e "bandera=BANDERA{...}"` |

Cuando el playbook te diga **✅ ¡BANDERA CORRECTA!**, se la decís al profe (en clase o
por el canal del curso). Eso es todo.

## Qué te vamos a preguntar cuando la digas

No alcanza con el número: tenés que poder mostrar **tu script** y contestar:

- ¿Cómo recorriste los archivos? (si la respuesta es `$(ls)`, volvé a leer)
- ¿Qué pasa si un archivo tiene un **espacio** en el nombre?
- ¿Por qué `viejos/` no cuenta? ¿Qué te habría pasado con un `grep -r`?
- ¿Por qué `[ERROR]` con corchetes y no `ERROR` a secas?
- ¿Dónde está tu función y por qué sus variables son `local`?
- ¿Qué devuelve tu script si le pasás una carpeta que no existe?

## La lista de control antes de decirla

- [ ] Mi script arranca con `#!/usr/bin/env bash` y `set -euo pipefail`
- [ ] Recibe la carpeta **por argumento** y la valida
- [ ] Recorre con **glob**, nunca `$(ls)`
- [ ] **Todas** las variables entre comillas
- [ ] Tiene al menos **una función** con `local`
- [ ] Los errores van a `>&2`
- [ ] Devuelve **0 / 1 / 2** según el caso (probalo: `echo $?`)
- [ ] `shellcheck mi_script.sh` sale **limpio**
- [ ] `ansible-playbook comprobar_bandera.yml -e "bandera=..."` da **✅**

## ⚠️ No subas la bandera al repo

La bandera **no va** en ningún commit, issue, ni comentario público. El repo guarda solo
su **huella SHA-256** (`playbooks/secretos/bandera.sha256`) justamente para eso: es el
mismo principio con el que se guardan las contraseñas. Si la publicás, le arruinás el
reto a todo el grupo.

> 💬 Si te trabaste: mostrame **tu script**, no la bandera. La mitad de las veces el bug
> es una comilla o un acumulador adentro de un pipe (`docs/auto_estudio.md`, sección 1).
