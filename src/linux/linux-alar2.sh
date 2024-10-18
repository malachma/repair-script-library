#!/bin/bash


#wget https://raw.githubusercontent.com/Azure/ALAR/main/src/run-alar.sh
#chmod 700 run-alar.sh
#./run-alar.sh $@
# Above is the original content, modified to run a test

#/bin/bash

curl -L https://github.com/Azure/ALAR/releases/download/v0.7.0-ALPHA/alar2 --output /tmp/alar2
cd /tmp
chmod 700 alar2
RUST_LOG=debug ./alar2 $@

exit $?
