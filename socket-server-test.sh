#! /usr/bin/zsh

#function to close up old file descriptors
function fdcleanup 
{
  NEWCLIENT_FDS=()
  echo "Client with file descriptor number $CLIENT_FDNUMBER has closed. Closing the FD"
  NUMBEROFCLIENT_FDS=${#CLIENT_FDS[@]}
  for (( socket_iterator=1; socket_iterator<=$NUMBEROFCLIENT_FDS; socket_iterator++ ))
  do
    TESTFD=${CLIENT_FDS[$socket_iterator]}
    if [[ $TESTFD != $CLIENT_FDNUMBER ]]
    then
      NEWCLIENT_FDS+=($TESTFD)
    else
      exec {TESTFD}>&-
    fi
  done
  CLIENT_FDS=()
  NUMBEROFCLIENT_FDS=${#NEWCLIENT_FDS[@]}
  for (( newarray_iterator=1; newarray_iterator<=$NUMBEROFCLIENT_FDS; newarray_iterator++ ))
  do
    CLIENT_FDS+=${NEWCLIENT_FDS[$newarray_iterator]}
  done
}

function StartTrustedClient
{
  zsocket "$SOCKET"
  LOCAL_FD=$REPLY
  TRUSTEDCLIENT_FDS+=($LOCAL_FD)
  CLIENT_FDS+=($LOCAL_FD)
  zsocket -a $MAINFD
  export TRUSTED_FD=$REPLY
  ./socket-trusted-client-test.sh 100 &
  exec {TRUSTED_FD}>&-
  unset TRUSTED_FD
}

#Prevent closing clients from killing the server
trap fdcleanup 13
zmodload zsh/net/socket

#Prepare variable types
typeset REPLY
typeset -i CLIENT_FD
typeset -i MAINFD
typeset -i NUMBEROFTRUSTEDCLIENT_FDS

export SOCKET=/tmp/zsockettestnew
#Create the new socket, and get the listenfd ID.
rm "$SOCKET"
zsocket -l "$SOCKET"
MAINFD=$REPLY
echo "Creating Socket with $MAINFD"

#Create an array of all the fds for the clients
CLIENT_FDS=()
TRUSTEDCLIENT_FDS=()

#Stat a trusted client
StartTrustedClient

while [ 1 ]
do
  REPLY=0
  zsocket -t -a $MAINFD
  CLIENT_FD=$REPLY
  if [[ $CLIENT_FD != 0 && $REPLY != $MAINFD ]]
  then
    echo "New CLIENT_FD $CLIENT_FD"
    CLIENT_FDS+=($CLIENT_FD)
  fi

  #Loop through all clients, send recive data.
  NUMBEROFCLIENT_FDS=${#CLIENT_FDS[@]}
  for (( client_iterator=1; client_iterator<=$NUMBEROFCLIENT_FDS; client_iterator++ ))
  do
    CLIENT_FDNUMBER=${CLIENT_FDS[$client_iterator]}
    echo "Handling FD $CLIENT_FDNUMBER ( FD $client_iterator of $NUMBEROFCLIENT_FDS )"

    #See if the cleint is trusted
    NUMBEROFTRUSTEDCLIENT_FDS=${TRUSTEDCLIENT_FDS[@]}
    for (( trust_iterator=1; trust_iterator<=$NUMBEROFTRUSTEDCLIENT_FDS; trust_iterator++ ))
    do
      TRUSTEDCLIENT_FD=${TRUSTEDCLIENT_FDS[$trust_iterator]}
      if [[ $TRUSTEDCLIENT_FD == $CLIENT_FDNUMBER ]]
      then
	echo "              Client $CLIENT_FDNUMBER is trusted"
	break
      fi
    done
    read -t -u $CLIENT_FDNUMBER 
    print "Client sent: $REPLY" 
    print -u $CLIENT_FDNUMBER "ServerReply to client $CLIENT_FDNUMBER" 2>/dev/null
  done
  echo "-------"
  sleep 1
done



