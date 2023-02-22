# direcotires in /home
# users list in there in /etc/passwd
# math the users from /etc/passwd to home/dir if it doesn't match
# should be deleted

# priviliges required - root

#!/bin/bash

cd /home

for dir in *; do
  CHK = $(grep -c "/home/$dir" /etc/passwd)
  if [ CHK -ge 1 ]; then
    echo "$dir is assigned to user"
  else
    echo "$dir is NOT assigned to user"
  fi
done
