#!/bin/bash
#############################################################################
# Recibe los siguientes argumentos:
#   1.- Nombre de la app
#   2.- Nombre Archivo yml para el docker Ejemplo: docker-compose_logistic_prod.yml
#############################################################################
docker ps
docker stop logistic-api-migrations
docker rm -f logistic-api-migrations
docker-compose -f $2 pull logistics-api-migrations
docker-compose -f $2 run --force-recreate logistics-api-migrations
if [[ $? -ne 0 ]] ; then echo "Error al correr migrations "; exit 1 ; fi
imageToRestore=$(docker ps -f name=logistic-api --format "{{.Image}}")
docker stop logistic-api
docker rm -f logistic-api
docker-compose -f $2 --env-file=env_files/.env_$1 pull logistics-api
docker-compose -f $2 --env-file=env_files/.env_$1 up -d --force-recreate logistics-api
if [[ $? -ne 0 ]] ; then 
    echo "Error when deploy, restore container...";
    echo "TAG="${imageToRestore} >> .env_restore_$1
    docker-compose -f $2 --env-file=.env_restore_$1 pull logistic-api
    docker-compose -f $2 --env-file=.env_restore_$1 up -d --force-recreate logistic-api
    exit 1 ; 
fi
