#!/bin/bash

# get UID from local user
uid=$(stat -c "%u" /home/$LOCAL_USER)
echo $LOCAL_USER $uid

EXISTING_USER=$(id -nu $uid)

if [ $EXISTING_USER ] ; then
  echo $EXISTING_USER
  sudo userdel -r $EXISTING_USER
else
  echo "Not exist"
fi

sudo groupmod -g $uid $CONTAINER_USER
sudo usermod -u $uid -g $uid $CONTAINER_USER

# continue to run container
node
