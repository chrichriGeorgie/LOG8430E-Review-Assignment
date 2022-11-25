#!/bin/bash
# Inspired by https://blog.devgenius.io/how-to-deploy-a-mongodb-replicaset-using-docker-compose-a538100db471

DELAY=60

docker-compose --file docker-compose.yml down
docker rm -f $(docker ps -a -q)
docker volume rm $(docker volume ls -q)

docker-compose --file docker-compose.yml up -d

echo "****** Waiting for ${DELAY} seconds for containers to go up ******"
sleep $DELAY

#docker exec -it mongo1 bash
docker ps

docker exec mongo1 /scripts/rs-init.sh