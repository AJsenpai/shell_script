# pull_errors.sh
# pull error msgs from file

#!/bin/bash
# Author: Ajay
# Date created: 19/02/2023
# Description : copy error logs fromm var/log/messages message file
# Date Modified: 19/02/2023

grep -i error /var/logs/messages >/home/user/error_messages.txt

# to pull warning messages
grep -i warn /var/logs/messages

# to pull Failure messages
grep -i fail /var/logs/messages

# you can schedule this scripts in crontab and use sendmail protocols to get the err messages
# you can also get the output by utilizing piping
# ./pull_error.sh | grep "Aug 27" | wc -l

###############################################################
#!/bin/bash
# Author: Ajay
# Date created: 19/02/2023
# Description : script that will fromat the output of administrative commands
# Date Modified: 19/02/2023

date | awk '{print $1}' # to get only first column
uptime | awk '(print $3}'
df -h | grep root
