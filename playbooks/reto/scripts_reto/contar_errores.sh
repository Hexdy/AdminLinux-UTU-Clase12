# contar_errores.sh — heredado. Cuenta lineas de ERROR de un log.
#
# OJO: NO lo corras a ciegas. Leelo y buscale los problemas.

LOG=$1
TOTAL=`grep -c ERROR $LOG`

echo "El log $LOG tiene $TOTAL lineas con ERROR"
