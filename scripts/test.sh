#!/bin/bash
cd /home/isofh/server/emr/dhy-production/signer-connector/files/test-file-182
date=$(date +"%Y_%m_%d_%H_%M_%S")
touch $date
#create a file for size 2MB*fSize
dd if=/dev/urandom of=file.txt bs=2MB count=1 2>&1 | awk '/copied/ {print $6 " "  $7}' >> time.txt
echo $date >> time.txt
mv file.txt $date
