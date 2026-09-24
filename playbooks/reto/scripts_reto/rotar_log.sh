# rotar_log.sh — heredado. Renombra el log del dia y deja uno vacio.
#
# OJO: NO lo corras. Leelo: le falta casi todo lo que vimos hoy.

LOG=/var/log/app/app.log
FECHA=$(date +%F)

mv $LOG $LOG.$FECHA
touch $LOG
echo "Log rotado a $LOG.$FECHA"
