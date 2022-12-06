#!/bin/bash


#Run the Redis benchmark
cd ./Redis
./start-redis.sh
docker-compose --file docker-compose.yml down
docker rm -f $(docker ps -aq)
docker volume rm $(docker volume ls -q)

#Run the MongoDb benchmark
cd ../mongodb
./start-mongo.sh
docker-compose --file docker-compose.yml down
docker rm -f $(docker ps -aq)
docker volume rm $(docker volume ls -q)

#Run the Cassandra benchmark
cd ../cassandra-cql
./start-cassandra-cql.sh