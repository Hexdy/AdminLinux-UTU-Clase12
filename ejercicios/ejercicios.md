# Ejercicios — Clase 12 (Shell scripting I)

> Todos sobre `datos/app.log` (78 líneas). Formato de cada línea:
>
> ```
> 2026-09-14T00:19:45 INFO catalogo u=adominguez ip=10.20.4.70 msg="cache actualizada"
>      $1            $2    $3          $4              $5            $6...
> ```
>
> **Reglas de la casa** (valen para todos): shebang `#!/usr/bin/env bash`,
> `set -euo pipefail`, **todas** las variables entre comillas, errores a `>&2`, `exit`
> explícito, y **`shellcheck` limpio** antes de decir "listo".
>
> ⚠️ **Sin bucles ni funciones** — eso es la Clase 13. Se resuelve todo con lo de hoy.

---

### 1️⃣ Tu primer script

Escribí `hola.sh` que salude con tu nombre y muestre la fecha de hoy. Tiene que correr con
`./hola.sh` (no con `bash hola.sh`).

*Pistas: shebang, `chmod +x`, `$(date +%F)`.*

---

### 2️⃣ El saludo con argumento

Escribí `saluda.sh` que reciba un nombre por argumento y salude. Si **no** le pasás
ningún argumento, tiene que imprimir `Uso: ./saluda.sh <nombre>` **por stderr** y salir
con código **2**.

Probá que funcionó:

```bash
./saluda.sh Ulyses ; echo "codigo: $?"
./saluda.sh        ; echo "codigo: $?"
./saluda.sh 2>/dev/null   # el mensaje de error NO tiene que aparecer
```

---

### 3️⃣ Contar de verdad

`grep -c ERROR datos/app.log` da **16**, pero las líneas de **nivel** ERROR son **15**.
Averiguá por qué y escribí `contar_errores.sh <ruta-log>` que imprima el número correcto.

*Pista: el nivel es el **segundo campo**. Una línea tiene la palabra "ERROR" adentro del
`msg=`.*

---

### 4️⃣ Validar antes de romper

Ampliá el script anterior para que, **antes** de contar:

- corte con `exit 2` si no llegó el argumento,
- corte con `exit 2` si el archivo no existe o no se puede leer,
- avise y salga con `exit 0` si el archivo existe pero está **vacío**.

Probalo con `./contar_errores.sh /etc/shadow` (ese no lo podés leer) y con
`./contar_errores.sh no_existe.log`.

---

### 5️⃣ El umbral

Ampliá otra vez: que acepte un **segundo argumento opcional** (`umbral`, por defecto
`10`). Si la cantidad de errores **supera** el umbral, que avise por `stderr` y salga con
**1**. Si no, `exit 0`.

```bash
./contar_errores.sh datos/app.log 20 ; echo "codigo: $?"   # tiene que dar 0
./contar_errores.sh datos/app.log 5  ; echo "codigo: $?"   # tiene que dar 1
```

---

### 6️⃣ El reporte con `printf`

Escribí `reporte.sh <ruta-log>` que imprima, **en columnas alineadas**, cuántas líneas hay
de cada nivel (`INFO`, `WARN`, `ERROR`) y el total.

*Pista: `printf "%-8s %4d\n"`. Podés contar cada nivel con un `grep -c` anclado al segundo
campo. **Sin bucles**: tres líneas, una por nivel.*

---

### 7️⃣ El menú con `case`

Escribí `servicio.sh` que reciba `start`, `stop`, `status` o cualquier otra cosa, y que
solo **imprima** qué haría en cada caso (no ejecutes `systemctl` de verdad). Para
cualquier otro valor: mensaje de uso por `stderr` y `exit 2`.

---

### 8️⃣ 🤖 Revisión de IA

Una IA te dio esto:

```bash
#!/bin/bash
DESTINO = $1
echo "Limpiando $DESTINO"
rm -rf $DESTINO/*
echo "Listo"
```

Encontrá **al menos 5 problemas** y reescribilo bien. No lo ejecutes.

*Pista: mirá el `=`, el shebang, las comillas, qué pasa si `$1` viene vacío, y qué falta
arriba de todo.*

---

## ✅ Antes de entregar

```bash
shellcheck *.sh     # tiene que salir limpio
bash -n mi.sh       # sintaxis OK
file mi.sh          # NO debe decir "with CRLF line terminators"
```
