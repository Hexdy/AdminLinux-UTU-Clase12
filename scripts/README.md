# scripts/ — los laboratorios de la clase, para leer, correr y romper

> Todos arrancan con `#!/usr/bin/env bash` + `set -euo pipefail` y pasan `shellcheck`
> limpio. Corrélos **desde la raíz del repo** (usan `datos/` como ruta por defecto).

```bash
chmod +x scripts/*.sh
./scripts/primero.sh
```

| Script | Escalón | Qué muestra |
|---|---|---|
| `primero.sh` | 1 · GUARDAR | Lab 1: shebang, `set -euo pipefail`, `$( )`, variables. |
| `auditar.sh` | 2 · DECIDIR | Lab 2: validación de argumentos, `[[ ]]`, **códigos 0/1/2**. |
| `bucles_demo.sh` | 3 · REPETIR | `for` con glob, `while IFS= read -r`, y el acumulador que da 0. |
| `funciones_demo.sh` | 4 · ORDENAR | `local`, `return` vs `echo`, estructura `main "$@"`. |

## Probá los 4 caminos de `auditar.sh`

```bash
./scripts/auditar.sh ; echo "codigo: $?"                          # 2 (falta argumento)
./scripts/auditar.sh /no/existe.log ; echo "codigo: $?"           # 2 (no lo puedo leer)
./scripts/auditar.sh datos/app_demo.log 5 ; echo "codigo: $?"     # 1 (9 errores > 5)
./scripts/auditar.sh datos/app_demo.log ; echo "codigo: $?"       # 0 (9 < umbral 20)
```

## Rompelos a propósito

Es la mejor forma de entenderlos:

- Sacale las comillas a una variable y creá un archivo con espacios en el nombre.
- Sacá el `|| true` del `grep -c` y corrélo sobre un log **sin** errores.
- Sacá el `local` de `funciones_demo.sh` y mirá cómo se pisa la variable del `for`.
- Corré cualquiera con `bash -x` para ver cada línea ya expandida.
