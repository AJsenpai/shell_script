# send alearts if files are less than 50

# create 20 files  ends with txt
touch file{1..20}.txt

a= $(ls -l file* | wc -l)

if [$a -eq 20 ]; then
  echo 'yes there are $a files'
else
  echo 'there are less files'
fi
