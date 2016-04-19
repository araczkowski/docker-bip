#!/bin/bash

cat /files/BI_Publisher_Trial_linux_32-64bit_generic.zipa* > /files/BI_Publisher_Trial_linux_32-64bit_generic.zip
unzip -o /files/BI_Publisher_Trial_linux_32-64bit_generic.zip -d /oracle
cp -f /scripts/configureBIP.sh /oracle/BI_Publisher_Trial/configureBIP.sh
cd /oracle/BI_Publisher_Trial
./configureBIP.sh
