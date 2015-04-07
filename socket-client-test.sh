#! /usr/bin/zsh
zmodload zsh/net/socket
typeset REPLY

#Connect to the server, and get the file descriptor number
zsocket  /tmp/zsockettestnew
SOCKETFD=$REPLY
echo "Starting Socket with $SOCKETFD"
REPLY=""
#Loop, send and get data from the server
while [ 1 ]
do
  print -u $SOCKETFD ClientSend$1 2>/dev/null
  read -t -u $SOCKETFD
  print "Server sent: $REPLY"
  sleep 1
done
#DETECT BAD SOCKET
