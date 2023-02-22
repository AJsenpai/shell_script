#!/bin/bash
# Author: Ajay
# Date created: 19/02/2023
# Description : remote server connectivity to check if they are alive or dead
# Date Modified: 19/02/2023

# -c1 is to count just once
# dev/nul is a null file in linux everytime you throw anything in dev/null it will disappear

hosts = '192.169.1.1'
ping -c1 $host &>/dev/null
if [ $? -eq 0 ]; then
  echo "$host is ok"
else
  echo "$host is not reachable"
fi

#####################################################
# Ping 100's of servers
# create a file with a list of servers
# 192.168.1.1
# 192.169.1.235

IPLISTS = 'home/ajay/myscripts/hosts'
for ip in $(cat $IPLISTS); do
  ping -c1 $ip &>/dev/null
  if [ $? -eq 0 ]; then
    echo "$ip ping passed"
  else
    echo "$ip ping not passed"
  fi
done
