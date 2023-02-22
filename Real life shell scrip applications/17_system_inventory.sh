# 1 script to add record
# 2 script to delete a record
# 3 to combine and provide options

# add_records.sh
#!/bin/bash
# we have already created a database file where we store this info
clear

echo "please enter the hostname"
read host
grep -q $host /home/ajay/database # -q to do it quietly wihout prompting on screen
if [ $? -eq 0 ]; then
  echo "ERROR -- hostname $host already exist"
  echo
  exit 0
fi

echo "please enter the ip address"
read ip
grep -q $ip /home/ajay/database
if [ $? -eq 0 ]; then
  echo "ERROR -- ip $ip already exist"
  echo
  exit 0
fi

echo "please enter description"
read desc
echo

echo $host $ip $desc >>/home/ajay/database # single > will overwrite >> will append
echo "the provided record has been added"

# delete records from database inventory
#!/bin/bash

echo "please enter the hostname or ip address"
read hostip
echo
grep -q $hostip /home/ajay/database
if [ $? -eq 0 ]; then
  echo
  sed -i '/'$hostip'/d' /home/ajay/database
  echo "$hostip has been deleted"
else
  echo "record $hostip does not exist"
fi

# sed -i s/hostname/old /filepath  - s stands for substitution

# combine these two
# !/bin/bash

clear
echo "please select one of the following options"
echo
echo "a = Add a record"
echo "d = Delete a record"
echo

read choice
case $choice in
a) /home/ajay/add-data.sh ;;
d) /home/ajay/delete-data.sh ;;
*) echo "invalid choice - Bye" ;;
esac
