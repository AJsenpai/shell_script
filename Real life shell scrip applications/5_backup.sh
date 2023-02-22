#!/bin/bash
# Author: Ajay
# Date created: 19/02/2023
# Description : backup file for /etc and /var
# Date Modified: 19/02/2023

# tar tvf to see whats inside the file

tar cvf /tmp/backup.tar /etc /var

gzip /tmp/backup.tar

find /tmp/backup.tar.gz -mtime -1 -type f -print &>/dev/null

if [ $? -eq 0 ]; then
  echo 'backup was created'
  echo
  echo "Archiving backup to differnt location"
  scp /tmp/backup.tar.gz root@192.168.1.3:/path_name
else
  echo "backup failed"

fi
