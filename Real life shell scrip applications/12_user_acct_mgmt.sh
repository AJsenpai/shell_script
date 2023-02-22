#### create user account
#!/bin/bash
echo "provide a username"
read username
echo

useradd $username
echo "$username has been created"

#######################################################################

#### error out if user exist
#!/bin/bash
echo "provide a username"
read username
echo

grep -q $username /etc/passwd #-q is quite mode; don't show anything on screen

if [ $? -eq 0 ]; then
  echo "ERROR -- user $username already exist"
  echo "please choose a different username"
  echo
  exit 0
fi

useradd $username
echo "$username has been created"

#######################################################################

#### add user description
#!/bin/bash
echo "provide a username"
read username
echo

grep -q $username /etc/passwd #-q is quite mode; don't show anything on screen

if [ $? -eq 0 ]; then
  echo "ERROR -- user $username already exist"
  echo "please choose a different username"
  echo
  exit 0
fi

echo "provide user descriptiom"
read des
useradd $username -c "$des" # -c is to add description
echo "$username has been created"

#######################################################################

#### add user id option
#!/bin/bash
echo "provide a username"
read username
echo

grep -q $username /etc/passwd #-q is quite mode; don't show anything on screen

if [ $? -eq 0 ]; then
  echo "ERROR -- user $username already exist"
  echo "please choose a different username"
  echo
  exit 0
fi

echo "provide user descriptiom"
read des

echo "do you want to specify userid (y/n)?"
read ynu

if [ $ynu == y ]; then
  echo "please enter UID"
  read uid
  useradd $username -c "$des" -u $uid #  -u is to add userid
  echo
  echo "$username account has been created"
elif [ $ynu == n ]; then
  echo "no worries we will assign the userid"
  useradd $username -c "$des"
  echo "$username account has been created"
fi

#######################################################################

# error out if user id exist
#!/bin/bash
echo "provide a username"
read username
echo

grep -q $username /etc/passwd #-q is quite mode; don't show anything on screen

if [ $? -eq 0 ]; then
  echo "ERROR -- user $username already exist"
  echo "please choose a different username"
  echo
  exit 0
fi

echo "provide user descriptiom"
read des

echo "do you want to specify userid (y/n)?"
read ynu

if [ $ynu == y ]; then
  echo "please enter UID"
  read uid
  grep $uid /etc/passwd
  if [ $? -eq 0 ]; then
    echo "ERROR- userid already exist"
    echo "please pick different id"
    exit 0
  else
    useradd $username -c "$des" -u $uid #  -u is to add userid
    echo
    echo "$username account has been created"
  fi

elif [ $ynu == n ]; then
  echo "no worries we will assign the userid"
  useradd $username -c "$des"
  echo "$username account has been created"
fi
