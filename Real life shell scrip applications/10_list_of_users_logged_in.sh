# script to look for users loffed in today
#!/bin/bash

today = $(date | awk '{print $1,$2,$3}')

# all user logged in sommand - last
last | grep "$today" | awk '{print $1}'

# script to ask user input to pull user (spicific date)
#!/bin/bash
echo "enter the day (eg. Mon)"
read day
echo
echo "enter the month (eg. Aug)"
read month
echo
echo "enter the date (eg. 25)"
read date
echo

last | grep "$day $month $date" | awk '{print $1}'
