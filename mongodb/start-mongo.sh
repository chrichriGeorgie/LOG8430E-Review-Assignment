#!/bin/bash
# Inspired by https://blog.devgenius.io/how-to-deploy-a-mongodb-replicaset-using-docker-compose-a538100db471

DELAY=60

docker-compose --file docker-compose.yml down
docker rm -f $(docker ps -a -q)
docker volume rm $(docker volume ls -q)

docker-compose --file docker-compose.yml up -d

echo "****** Waiting for ${DELAY} seconds for containers to go up ******"
sleep $DELAY

docker exec mongo1 /scripts/rs-init.sh

workloads=( "workloada" "workloadb" "workloadc" "workloadd" "workloade" "workloadf" )

cd ../../ycsb-0.17.0
it=3
for workload in ${workloads[@]}; do
    for ((i=0; i<$it; i++)); do
        ./bin/ycsb.sh load mongodb -P workloads/${workload} > ../mongoload_${workload}_${i}.txt
        ./bin/ycsb.sh run mongodb -P workloads/${workload} > ../mongorun_${workload}_${i}.txt
        docker exec mongo1 /scripts/clear-ycsb.sh
    done
done