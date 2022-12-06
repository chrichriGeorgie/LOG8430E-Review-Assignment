#!/bin/bash

sudo docker run --name cassandra-main -d -e MAX_HEAP_SIZE="950M" -e HEAP_NEWSIZE="950M" --restart always cassandra:latest
sleep 60s
cass_main_ip=$(sudo docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' cassandra-main)
sudo docker run --name cassandra-n2 -d -e CASSANDRA_SEEDS="$cass_main_ip" -e MAX_HEAP_SIZE="800M" -e HEAP_NEWSIZE="800M" --restart always cassandra:latest
sleep 60s
sudo docker run --name cassandra-n3 -d -e CASSANDRA_SEEDS="$cass_main_ip" -e MAX_HEAP_SIZE="800M" -e HEAP_NEWSIZE="800M" --restart always cassandra:latest
sleep 60s
sudo docker run --name cassandra-n4 -d -e CASSANDRA_SEEDS="$cass_main_ip" -e MAX_HEAP_SIZE="800M" -e HEAP_NEWSIZE="800M" --restart always cassandra:latest
sleep 60s
sudo docker run --name cassandra-n5 -d -e CASSANDRA_SEEDS="$cass_main_ip" -e MAX_HEAP_SIZE="800M" -e HEAP_NEWSIZE="800M" --restart always cassandra:latest
sleep 60s
sudo docker run --name cassandra-n6 -d -e CASSANDRA_SEEDS="$cass_main_ip" -e MAX_HEAP_SIZE="800M" -e HEAP_NEWSIZE="800M" --restart always cassandra:latest

echo 'Waiting for cluster to stabilize'
sleep 120s

cass_n2_ip=$(sudo docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' cassandra-n2)
cass_n3_ip=$(sudo docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' cassandra-n3)
cass_n4_ip=$(sudo docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' cassandra-n4)
cass_n5_ip=$(sudo docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' cassandra-n5)
cass_n6_ip=$(sudo docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' cassandra-n6)


#initial database config for ycsb testing
sudo docker exec -it cassandra-main cqlsh -e "create keyspace ycsb WITH REPLICATION = {'class' : 'SimpleStrategy', 'replication_factor': 3};USE ycsb;create table usertable (y_id varchar primary key,field0 varchar,field1 varchar,field2 varchar,field3 varchar,field4 varchar,field5 varchar,field6 varchar,field7 varchar,field8 varchar,field9 varchar);"

workloads=( "workloada" "workloadb" "workloadc" "workloadd" "workloade" "workloadf" )

cd ../../YCSB
it=3
for workload in ${workloads[@]}; do
    for ((i=0; i<it; i++)); do
        ./bin/ycsb.sh load cassandra-cql -P workloads/${workload} -p "hosts=$cass_main_ip,$cass_n2_ip,$cass_n3_ip,$cass_n4_ip,$cass_n5_ip,$cass_n6_ip"
        ./bin/ycsb.sh run cassandra-cql -P workloads/${workload} -p "hosts=$cass_main_ip,$cass_n2_ip,$cass_n3_ip,$cass_n4_ip,$cass_n5_ip,$cass_n6_ip" > ../cassandrarun${workload}${i}.txt
    done
done

#Stop and delete containers
sudo docker stop cassandra-n6
sudo docker stop cassandra-n5
sudo docker stop cassandra-n4
sudo docker stop cassandra-n3
sudo docker stop cassandra-n2
sudo docker stop cassandra-main
sudo docker rm cassandra-n6
sudo docker rm cassandra-n5
sudo docker rm cassandra-n4
sudo docker rm cassandra-n3
sudo docker rm cassandra-n2
sudo docker rm cassandra-main