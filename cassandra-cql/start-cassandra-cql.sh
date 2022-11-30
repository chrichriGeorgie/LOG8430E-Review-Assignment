#!/bin/bash

sudo docker run --name cassandra-main -d cassandra:latest
sleep 40s
sudo docker run --name cassandra-n2 -d --link cassandra-main:cassandra cassandra:latest
sudo docker run --name cassandra-n3 -d --link cassandra-main:cassandra cassandra:latest
sleep 130s
sudo docker start cassandra-n2 cassandra-n3

cass_main_ip=$(sudo docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' cassandra-main)
cass_n2_ip=$(sudo docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' cassandra-n2)
cass_n3_ip=$(sudo docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' cassandra-n3)

echo 'Waiting for cluster to stabilize'
sleep 120s

#initial database config for ycsb testing
sudo docker exec -it cassandra-main cqlsh -e "create keyspace ycsb WITH REPLICATION = {'class' : 'SimpleStrategy', 'replication_factor': 3};USE ycsb;create table usertable (y_id varchar primary key,field0 varchar,field1 varchar,field2 varchar,field3 varchar,field4 varchar,field5 varchar,field6 varchar,field7 varchar,field8 varchar,field9 varchar);"

workloads=( "workloada" "workloadb" "workloadc" "workloadd" "workloade" "workloadf" )

cd ../../ycsb-0.17.0
it=3
for workload in ${workloads[@]}; do
    for ((i=0; i<it; i++)); do
        ./bin/ycsb.sh load cassandra-cql -P workloads/${workload} -p "hosts=$cass_main_ip,$cass_n2_ip,$cass_n3_ip" > load${workload}${i}.txt
        ./bin/ycsb.sh run cassandra-cql -P workloads/${workload} -p "hosts=$cass_main_ip,$cass_n2_ip,$cass_n3_ip" > run${workload}${i}.txt
    done
done

#Stop and delete containers
sudo docker stop cassandra-n3
sudo docker stop cassandra-n2
sudo docker stop cassandra-main
sudo docker rm cassandra-n3
sudo docker rm cassandra-n2
sudo docker rm cassandra-main
