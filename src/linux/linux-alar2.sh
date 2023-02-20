#!/bin/bash

wget https://raw.githubusercontent.com/Azure/ALAR/cli-test/src/run-alar.sh
chmod 700 run-alar.sh
./run-alar.sh $1

exit $?
