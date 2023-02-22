#!/bin/bash
for i in 1 2 3 4 5:; do
  echo 'running $i times'
done

####################################

#!/bin/bash
for i in eat jump play; do
  echo "i $i"
done

####################################
#!/bin/bash

for i in {1..5}; do
  echo "$i"
done

####################################
#!/bin/bash

START=1
END=5
echo "countdown"
for ((i = $START; i <= $END; i++)); do
  echo -n "$i"
  sleep 1
done
