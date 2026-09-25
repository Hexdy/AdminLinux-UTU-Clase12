<!-- Plantilla de Pull Request — completala antes de pedir la revisión. -->
<!-- OJO: la BANDERA del reto NO se entrega por acá. Se la decís al profe. -->

## Qué hice

<!-- Explicá en 1-2 frases qué resolviste y cómo. -->

## Script que escribí

```bash
# pegá acá tu script completo
```

## Salida obtenida

<!-- Pegá la salida o una captura de tu terminal, incluyendo el `echo $?`. -->

## Checklist

- [ ] Entiendo cada línea de lo que entrego (no lo copié sin entender).
- [ ] Arranca con `#!/usr/bin/env bash` y `set -euo pipefail`.
- [ ] **Todas** las variables van entre comillas (`"$VAR"`).
- [ ] Recorro con **glob**, nunca con `$(ls)`.
- [ ] Los errores y avisos van a `>&2`.
- [ ] Devuelve códigos de salida distintos según el caso (0 / 1 / 2).
- [ ] `shellcheck mi_script.sh` sale **limpio**.
- [ ] **No incluyo la bandera**, ni secretos, ni datos sensibles reales.
- [ ] Trabajé en una rama, no en main.
