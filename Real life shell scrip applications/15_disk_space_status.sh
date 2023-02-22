# find disk space using df command
# differnt scripts that will filter the output and compare (long)
# simple script

#!/bin/bash

# cut % delimiter from 70% and give -f1 which is field 1 70
a = $(df -h | egrep -v "tmpfs|devtmpfs" | tail -n+2 | awk '{print $5}' | cut -d'%' -f1)

for i in $a; do
  if [ $i -ge 80 ]; then
    echo "check disk space $i $(df -h | grep $i)"
  fi
done

# same but differntly written
#!/bin/bash
df -H | grep -vE '^Filesystem|tmpfs|cdrom' | awk '{print $5 $1}' | while read output; do
  usedspace=$(echo $output | awk '{print $1}' | cut -d'%' -f1)
  partition_name = $(echo $output | awk '{print $2}') # $1 from {print $5 $1}

  if [ usedspace -ge 90 ]; then
    echo "Running out of space \" $partition_name ($usedspace%) \" on $(hostname) as on $(date)"
  fi
done

# !/bin/bash
# easy script

echo
echo "Following is the disk stats"
echo
df -h | awk '0+$5 >= 90 {print}' | awk 'print{$5,$6}'
