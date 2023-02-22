#!/bin/bash
# Author: Ajay
# Date created: 19/02/2023
# Description : script to delete old files with specified - 90 days
# Date Modified: 19/02/2023

# once the disk space is full your system becomes unresponsive

# create script to delete files as specified

# create files with older timestamp
# -  touch -d "Thu, 1 March 2018 12:30:00" filename

# -mtime is modified days
# -exec is execute this command once found the file
find /home/ajay/myscripts -mtime +90 -exec ls -l {} \; # \ is a part of exec

# delete the files instead of listing
find /home/ajay/myscripts -mtime +90 -exec rm {} \;

# find and rename old files
find /home/ajay/myscripts -mtime +90 -exec {} {}.old \;

# find files with -name
find . -type f -empty
find -type f -perm 0777 -print
find /home -iname hello.txt
find /home -iname "*.txt"
