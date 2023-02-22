# !/bin/bash
# Author: Ajay
# Date Created: 20/02/2023
# Description: this script will log defined keywords
# Date Modified: 20/02/2023

tail -fn0 /var/log/messages | while read line; do
  echo $line | egrep -i "refused|invalid|error|fail|lost|shut|down|offline"
  if [ $? = 0 ]; then
    echo $line >>/tmp/filtered-error-messages # put this into this filter error file
  fi
done

# notification for error log messages

mail_list = 'ajay@gmail.com, sam@outlook.com, gunther@yahoo.com, martin@gmail.com'

if [ -s /tmp/filtered-error-messages]; then # if file is ther and its not empty -s
  cat /tmp/filtered-error-messages | sort | unique | mail -s "syslogs messages" $mail_list
  rm /tmp/filtered-error-messages
else
fi

# schedule this to crontab to send mails - run every 15 minutes
# */15 * * * * /root/log-alert.sh
