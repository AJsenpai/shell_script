#!/bin/bash
# Author: Ajay
# Date created: 19/02/2023
# Description : Copy files to remote hosts
# Date Modified: 19/02/2023

hostnames = $(cat /home/ajay/hostfiles)
for i in hostnames; do #hostnames
  scp /home/ajay/somefile $i:/tmp
done
