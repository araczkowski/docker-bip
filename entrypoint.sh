#!/bin/bash

exec >> >(tee -ai /docker_log.txt)
exec 2>&1

# # Start BIP
##
cd /oracle/BI_Publisher_Trial/bin
./startBIP.sh
