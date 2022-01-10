#!/bin/bash
#############################################################################
# Recibe los siguientes argumentos:
#   1.- $DOCKERFILE_PATH (Ruta y nombre del archivo Dockerfile para compilar)
#   2.- $FILE_ENVIRONMENT (Nombre Archivo donde se guardan las variables de entorno tanto las de consul como las de secrets
#############################################################################
i=1
linea=1
palabra="#PASTE-ENVIRONMENT"
while read findLine; do
 echo "$findLine"
 if [ "$findLine" = "$palabra" ]; then
     echo "$findline"
     echo "Strings are equal."
     ((linea=i+1))
 else
     echo "Strings are not equal."
     ((i=i+1))
 fi
done < $1
#echo "linea: $linea -> FIN -> $i"
chI="i"
while read line; do
  if [ "$line" != "" ]; then
   sed -i "$linea$chI $line" $1
  fi
  ((linea=linea+1)) 
done < $2
