#!/bin/bash
#

echo
echo 'choose one of the options below'
echo 'a= date and time'
echo 'b= list files and directories'
echo 'c= list of users logged in'
echo 'd= check system uptime'

read choices
case $choices in

a) date ;;
b) ls ;;
c) who ;;
d) uptime ;;
*) echo 'invalid choice bye.' ;; # default

esac

###############################

# this script will look at your current day and tell you the state of backup

#!/bin/bash
NOW=$(date +'%a') # format is important
case $NOW in
Mon)
      echo 'fulbackup'
      ;;
Tue | Wed | Thu | Fri)
      echo 'partial backup'
      ;;
Sat | Sun)
      echo 'no backup'
      ;;
*) ;;
esac
