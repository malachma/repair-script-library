#!/bin/bash


#wget https://raw.githubusercontent.com/Azure/ALAR/main/src/run-alar.sh
#chmod 700 run-alar.sh
#./run-alar.sh $@
# Above is the original content, modified to run a test

#/bin/bash

wget https://raw.githubusercontent.com/Azure/ALAR/refs/heads/ALAR-redesign/run-alar.sh
chmod 700 run-alar.sh
./run-alar.sh $@

exit $?
