#!/bin/bash
DELAY=10

mongosh <<EOF
use ycsb;
db.dropDatabase();
EOF

echo "****** Waiting for ${DELAY} seconds for database removal to be completed******"

sleep $DELAY