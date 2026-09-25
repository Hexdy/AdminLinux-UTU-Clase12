# Chuleta — `logger`, `cron` y `systemd timers`

> Escalón 5 de la Clase 12: **dejar rastro** y **correr solo**.

## 1. `logger`: que tu script escriba en el journal

Si tu script corre a las 3 AM y nadie lo mira, la única prueba de que pasó algo es lo
que anotó. `logger` manda tu mensaje al **journal del sistema** (el de la Clase 10).

```bash
logger -t respaldo-nocturno -p user.info "arranco el respaldo de /var/www"
logger -t respaldo-nocturno -p user.err  "fallo: destino lleno"
```

| Opción | Qué hace |
|---|---|
| `-t ETIQUETA` | con qué nombre aparece (usá el nombre del script) |
| `-p facility.nivel` | prioridad: `user.info`, `user.warning`, `user.err` |
| `-s` | además del journal, lo escribe en **stderr** |

```bash
journalctl -t respaldo-nocturno -n 20 --no-pager       # las ultimas 20
journalctl -t respaldo-nocturno -p err --since today   # solo errores de hoy
```

> ⚠️ En un script, `journalctl` **siempre** con `--no-pager`: si no, se cuelga esperando
> que alguien salga de `less`.

El patrón que conviene copiar:

```bash
TAG="$(basename "$0" .sh)"
log() {                       # log err "no pude leer x"
    local nivel="$1"; shift
    printf '[%s] [%s] %s\n' "$(date '+%F %T')" "${nivel^^}" "$*" >&2
    logger -t "$TAG" -p "user.${nivel}" "$*"
}
```

## 2. `cron`: el despertador del sistema

```
   *      *      *      *      *      comando
   |      |      |      |      |
   |      |      |      |      +--  dia de SEMANA   (0-7, 0 y 7 = domingo)
   |      |      |      +--------   MES             (1-12)
   |      |      +---------------   dia del MES     (1-31)
   |      +----------------------   HORA            (0-23)
   +-----------------------------   MINUTO          (0-59)
```

| Símbolo | Significa | Ejemplo |
|---|---|---|
| `*` | todos | `* * * * *` = cada minuto |
| `,` | lista | `0 8,14,20 * * *` = 08:00, 14:00 y 20:00 |
| `-` | rango | `0 9-18 * * *` = cada hora de 9 a 18 |
| `*/n` | cada n | `*/15 * * * *` = cada 15 minutos |

| Línea | Cuándo corre |
|---|---|
| `0 3 * * *` | todos los días a las 03:00 |
| `30 2 * * 0` | domingos a las 02:30 |
| `0 0 1 * *` | el día 1 de cada mes a medianoche |
| `*/10 8-18 * * 1-5` | cada 10 min, de 8 a 18, de lunes a viernes |

| Comando | Qué hace |
|---|---|
| `crontab -e` | editar **mi** crontab |
| `crontab -l` | ver **mi** crontab |
| `crontab -l > ~/crontab.bak` | **respaldarlo** (hacelo ANTES de tocar nada) |
| `crontab -r` | 🔴 **borrarlo entero, sin preguntar** |

**Dónde vive cada cosa**:

| Lugar | Formato |
|---|---|
| `crontab -e` (el tuyo) | 5 campos + comando (corre **como vos**) |
| `/etc/crontab` · `/etc/cron.d/<archivo>` | 5 campos + **usuario** + comando |
| `/etc/cron.{hourly,daily,weekly}/` | scripts ejecutables sueltos (sin línea de tiempo) |

```bash
# /etc/cron.d/respaldo-app   <-- el formato de sistema lleva el USUARIO
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
0 3 * * *  respaldos  /usr/local/bin/respaldo.sh
```

## 3. 🔴 Las 4 trampas de cron

| # | Trampa | Síntoma | Arreglo |
|---|---|---|---|
| 1 | El **PATH** es mínimo y no carga tu `~/.bashrc` | "anda en mi terminal y en cron no" | **rutas absolutas** en todo (script, binarios, archivos) |
| 2 | El `%` es **especial** en el crontab | la línea se corta a la mitad | escapalo: `date +\%F` — o mejor, metelo **adentro** del script |
| 3 | La salida **se pierde** | "corrió pero no sé qué hizo" | `logger` (mejor) o `>> /var/log/x.log 2>&1` |
| 4 | **No hay nadie** del otro lado | queda colgado o falla | nada de `read`, ni `sudo` con contraseña, ni prompts |

```bash
# ❌ mal                              # ✅ bien
0 3 * * * respaldo.sh                 0 3 * * * /usr/local/bin/respaldo.sh
0 3 * * * tar -czf $(date +%F).tgz    0 3 * * * /usr/local/bin/respaldo.sh   # la fecha, adentro
```

**Depurar cron** — cómo ver si corrió:

```bash
journalctl -u cron --since today --no-pager       # Debian/Ubuntu
journalctl -u cronie --since today --no-pager     # Arch
journalctl -u crond --since today --no-pager      # Fedora/RHEL
journalctl -t mi-script --since today --no-pager  # lo que escribiste vos con logger
```

**Probarlo sin esperar a las 3 AM**: agendalo dentro de 2 minutos (`*/1 * * * *`),
mirá el journal, y **después** ponelo en su horario real.

## 4. ⚠️ Multi-distro: cron se llama distinto

| | Debian / Ubuntu | Arch | Fedora / RHEL |
|---|---|---|---|
| Paquete | `cron` | `cronie` | `cronie` |
| **Unit** | `cron.service` | `cronie.service` | `crond.service` |
| Ver el log | `journalctl -u cron` | `journalctl -u cronie` | `journalctl -u crond` |

```bash
systemctl list-units '*cron*'      # si no sabés cómo se llama en tu máquina
```

En Arch y en Fedora mínimo, `cron` **no viene instalado**: si `crontab` no existe, ese
es el motivo.

## 5. `systemd timers`: la alternativa moderna

Hacen lo mismo que cron, pero integrados a systemd: los logs van al **journal**,
pueden depender de otras units y **recuperan** la ejecución perdida si la máquina
estaba apagada (`Persistent=true`, cosa que cron **no** hace).

```ini
# /etc/systemd/system/respaldo.service
[Unit]
Description=Respaldo de la app

[Service]
Type=oneshot
ExecStart=/usr/local/bin/respaldo.sh
```

```ini
# /etc/systemd/system/respaldo.timer
[Unit]
Description=Correr el respaldo todos los dias a las 03:00

[Timer]
OnCalendar=*-*-* 03:00:00
Persistent=true

[Install]
WantedBy=timers.target
```

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now respaldo.timer
systemctl list-timers --all            # cuando corre la proxima
journalctl -u respaldo.service --no-pager
```

| | `cron` | `systemd timer` |
|---|---|---|
| Configuración | una línea | dos archivos (`.service` + `.timer`) |
| Logs | los redirigís vos | al **journal**, automático |
| Si la máquina estaba apagada | se perdió | `Persistent=true` lo recupera |
| Dependencias | no | `After=`, `Requires=` |

**Regla práctica**: para tareas simples de usuario, `cron` alcanza y sobra. Para
servicios, dependencias o cuando te importa no perder ejecuciones, **timer**.
