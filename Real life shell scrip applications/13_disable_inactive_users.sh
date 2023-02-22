#!/bin/bash

a = $(lastlog -b 90 | tail -n+2 | grep -v 'never logged in' | awk '{print $1}')

for i in $a:; do
  usermode -L $i
done

# using xargs
#!/bin/bash

$(lastlog -b 90 | tail -n+2 | grep 'test' | awk '{print $1}' | xargs -I{} usermod -L {})
