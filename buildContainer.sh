#!/bin/bash
#Funcion para compilar segun ambiente
#############################################################################
# Recibe los siguientes argumentos:
#   1.- Path
#   2.- Dockerfile path
#   3.- File environment
#   4.- branch 
#   5.- AppName
#   6.- Docker Hub Repo
#   7.- Nuevo Tag
#   8.- Username Docker Hub
#   9.- Pass Docker Hub
#   10.-Replaced branch string
#############################################################################
buildEnvironment (){
    docker-compose -f docker-compose.yml down --rmi local $5
    echo "========Build Container & Tag========"
    nuevoTAG=$(echo "$7" | sed "s#_$4_#_${10}_#g")
    cp Dockerfile.ori Dockerfile
    echo "Llega antes del environment..."
    echo "$3_${10}"
    set +x
    export SSH_PRIVATE_KEY="$(cat /root/.ssh/keyGit)"
    set -x
    docker-compose -f docker-compose.yml build $5
    docker tag $6:$5 $6:${nuevoTAG} 
    echo "========Push Container========"
    docker login --username $8 --password $9
    docker push $6:${nuevoTAG}
    echo "Fin Push"
}
. ./sourceEnvironment.sh
nuevoTag="${TAG}"
COMMIT_SHA=$(git rev-parse HEAD)
echo "ENV BUILD_NUMBER=${BUILD_NUMBER}" >> ${FILE_ENVIRONMENT}_${BRANCH_NAME}
echo "ENV COMMIT_SHA=${COMMIT_SHA}" >> ${FILE_ENVIRONMENT}_${BRANCH_NAME}
if [[ "${ENV_TEST}" == 'FALSE' ]] ; then
    buildEnvironment '' '' '' "${BRANCH_NAME}" "${PROYECT}" "${DOCKER_HUB_REPO}" "${nuevoTag}" "${USERNAME}" "${PASSWORD}" "${BRANCH_NAME}"
else
    buildEnvironment '' '' '' 'dev' "${PROYECT}" "${DOCKER_HUB_REPO}" "${nuevoTag}" "${USERNAME}" "${PASSWORD}" 'dev'
fi
case "${BRANCH_NAME}" in
  "dev")
        buildEnvironment '' '' '' "${BRANCH_NAME}" "${PROYECT}" "${DOCKER_HUB_REPO}" "${nuevoTag}" "${USERNAME}" "${PASSWORD}" "${BRANCH_QA}"
    ;;
  "master")
        buildEnvironment '' '' '' "${BRANCH_NAME}" "${PROYECT}" "${DOCKER_HUB_REPO}" "${nuevoTag}" "${USERNAME}" "${PASSWORD}" "${BRANCH_DEMO}"
    ;;
esac

