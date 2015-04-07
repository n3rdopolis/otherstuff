#! /usr/bin/zsh
zmodload zsh/net/socket
typeset REPLY

#Connect to the server, and get the file descriptor number
SOCKETFD="$TRUSTED_FD"

#Loop, send and get data from the server
while [ 1 ]
do
  print -u $SOCKETFD ClientSend$1 2>/dev/null
  read -t -u $SOCKETFD && print $REPLY &>/dev/null
  READ_RESULT=$?
  if [[ $READ_RESULT != 0 ]]
  then
    echo "Server quit. Exiting."
    exit
  fi
  read -t 1
done