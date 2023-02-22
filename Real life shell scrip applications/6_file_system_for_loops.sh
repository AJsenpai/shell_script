# simple counting script

#!/bin/bash
for i in {1..5}; do
  echo $i
  sleep 1
done

# create files with different names

#!/bin/bash
for i in {1..5}; do
  touch Ajay.$i
done

# create multiple files with user input

#!/bin/bash
echo 'how many files do you want to create'
read total

echo 'what you want to name them?'
read name

for i in $(seq 1 $total); do
  touch $name.$i
done

# assign write permission to files

#!/bin/bash
for i in ajay.*; do
  echo "Changing files permission for $i"
  chmod a+w $i
  sleep 1
done

# Assing write permission to files with total time it'll take

#!/bin/bash
total = $(ls -l ajay.* | wc -l)
echo "It will take $total seconds to assign file permission"

for i in ajay.*; do
  echo 'assigning write permission'
  chmod a+w $i
done

# rename all *.text to *.none

#!/bin/bash
for filename in *.txt; do
  mv $filename $(filename%.txt).none
done

# check to see if files exist
#!/bin/bash
FILES= '/etc/passwd
/etc/group
/etc/shadow
/etc/nsswitch.conf
/etc/ssh.sshd.config
/etc/fake'

echo
for file in $FILES; do
  if [ ! -e $file ]; then
    echo "$file does not exist"
    echo
  fi
done
