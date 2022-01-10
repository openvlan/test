#!/bin/bash
#############################################################################
# Recibe los siguientes argumentos:
#   1.- UrlConsul (http://3.18.18.13:8500/v1/kv/)
#   2.- PathKeysConsul (env/tiko-global-backoffice/test/)
#   3.- PrefijoSecrets (vault_)
#   4.- NombreArchivoResultado
#   5.- FileEnvironment (Nombre del archivo que necesito para guardar las variables de entorno tanto las del consul como las secrets)
#############################################################################
listSecretsKey=""
#Obtengo string con las key
stringArray=$(curl $1$2?keys)
# remove ( and )
newstr=$(echo $stringArray | sed 's/\[//g' )
newstr=$(echo $newstr | sed 's/\]//g' )
#remove env/test/ from string
cleanString=$(echo $newstr | sed 's!'"$2"'!!g')
#remove directory from string
cleanString=$(echo $cleanString | sed 's!"",!!g')
#remove doble cuote from string
cleanString=$(echo $cleanString | sed 's!"!!g')
#convert string to array
IFS=', ' read -r -a arrayString <<< "$cleanString" 
for index in "${!arrayString[@]}"
do
    if [[ "${arrayString[index]}" =~ "$3" ]]; then
       echo "si"
       key=$(echo ${arrayString[index]} | sed 's!'"$3"'!!g')
       if [ -z "$listSecretsKey" ]; then
         listSecretsKey="["$key
       else
         listSecretsKey=$listSecretsKey","$key
       fi
    #else call value of consul
    else
      echo "no"
      valorR=$(curl $1$2${arrayString[index]})
      IFS=',' read -r -a arrayString2 <<< "$valorR" 
      for index2 in "${!arrayString2[@]}"
      do
         limpia=$(echo ${arrayString2[index2]} | sed 's!\"!!g')
#         echo $limpia
         if [[ "$limpia" =~ "Value:" ]]; then
           valor=$(echo $limpia | sed 's!Value:!!g')
           valorF=$(echo $valor | base64 --decode)
           re="[[:space:]]+"
           if [[ "$valorF" =~ $re ]] && [[ !($valorF =~ ^\'.*\'$) ]]; then
             echo "ENV ${arrayString[index]}='$valorF'" >> $5
           else
             echo "ENV ${arrayString[index]}=$valorF" >> $5
           fi
         fi
      done
    fi
done
echo $listSecretsKey > $4
