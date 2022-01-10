#!/bin/bash
#docker-compose --env-file=.env_migrations down
sed -i 's/ENV /export /g' tmp_source.sh
. ./tmp_source.sh
echo "DATABASE_USERNAME=${DATABASE_USERNAME}" >> .env_migrations
echo "DATABASE_PASSWORD=${DATABASE_PASSWORD}" >> .env_migrations

docker volume create tiko_ci_data
docker network create custom_network
docker stop pg_gis_testing_logistic
docker stop redis_testing_logistic
docker rm -f pg_gis_testing_logistic
docker rm -f redis_testing_logistic
docker-compose --env-file=.env_migrations up -d --force-recreate pg_gis_testing redis_testing
export SSH_PRIVATE_KEY="$(cat /root/.ssh/keyGit)"
docker-compose --env-file=.env_migrations build logistics-api_ci_migrations
if [[ $? -ne 0 ]] ; then echo "Error al buildear el componente de migrations"; exit 1 ; fi
docker-compose --env-file=.env_migrations  run logistics-api_ci_migrations
if [[ $? -ne 0 ]] ; then echo "Error al correr migrations"; exit 1 ; fi
contenedor=$()
docker-compose --env-file=.env_migrations down
