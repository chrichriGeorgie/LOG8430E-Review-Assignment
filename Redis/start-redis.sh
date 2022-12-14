#!/bin/bash

DELAY=60

docker-compose --file docker-compose.yml down
docker rm -f $(docker ps -aq)
docker volume rm $(docker volume ls -q)

docker-compose --file docker-compose.yml up -d

echo "****** Waiting for ${DELAY} seconds for containers to go up ******"
sleep $DELAY

workloads=( "workloada" "workloadb" "workloadc" "workloadd" "workloade" "workloadf" )

cd ../../ycsb-0.17.0
it=3
for workload in ${workloads[@]}; do
    for ((i=0; i<$it; i++)); do
        ./bin/ycsb.sh load redis -s -P workloads/${workload} -p redis.host=127.0.0.1 -p redis.port=6379 -p redis.cluster=true > ../redisload_${workload}_${i}.txt
        ./bin/ycsb.sh run redis -s -P workloads/${workload} -p redis.host=127.0.0.1 -p redis.port=6379 -p redis.cluster=true > ../redisrun_${workload}_${i}.txt
    done
done