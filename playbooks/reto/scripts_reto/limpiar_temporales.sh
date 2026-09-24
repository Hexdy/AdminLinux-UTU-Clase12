# limpiar_temporales.sh — heredado. Borra los .tmp de la carpeta de trabajo.
#
# OJO: NO lo corras. Leelo: tiene varios antipatrones de los que vimos hoy.

DIR=./tmp_app

if [ -d $DIR ]; then
  rm -f $DIR/*.tmp
  echo "Temporales borrados de $DIR"
else
  echo "No existe $DIR"
fi
