#!/bin/bash
# using xargs
ps -ef | grep "sleep 600" | grep -v grep | awk '{print $2}' | xargs -I{} echo {}

# xargs -I{} holds the output from previous pipe and can be used with command {}
ps -ef | grep "sleep 600" | grep -v grep | awk '{print $2}' | xargs -I{} kill {}

# using For loop
#!/bin/bash
a = ps -ef | grep "sleep 600" | grep -v grep | awk '{print $2}'
for i in $a; do
  kill $i
done
