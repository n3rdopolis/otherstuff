#!/bin/bash
# TODO better naming 
# TODO find a way to specify, and append excludes

function getfilesysteminfo
{
#Get if root is a mountpont
mountpoint / -q
ISROOTMOUNT=$?

#Handle choots
if [[ $ISROOTMOUNT != 0 ]]
then
  echo "/ is not a mountpoint. Is / a chroot? Try to bindmount the chroot path onto itself"
  exit
fi
INITROOTFS=$(findmnt -vUrno FSROOT -N1 /)
THISROOTFS=$(findmnt -vUrno FSROOT /)
if [[ "$INITROOTFS" != "$THISROOTFS" ]]
then
  REPLACESTRING="$THISROOTFS"
else
  REPLACESTRING=/
fi
FSES=$(findmnt -vUPno MAJ:MIN,FSROOT,TARGET,ID  | sed -e "s|$REPLACESTRING|/|g" -e "s|//|/|g" | sort -k4,4n --stable -k 1,1 -k2,2)
FSES=${FSES//MAJ:MIN/MAJ_MIN}

EXCLUDES=(/proc /sys /dev /run /tmp)

OUTSTR=""

BINDISFILE=0
FSCANTOVERLAY=0


unset DONE1FSES
ROOTFSROOT=/
IFS=$'\n'
for SEARCH1FS in $FSES
do
  HASBINDS=0
  unset DONE2FSES
  eval "$SEARCH1FS"
  SEARCH1ID="$ID"
  SEARCH1FSROOT="$FSROOT"
  SEARCH1TARGET="$TARGET"
  SEARCH1MAJMIN="$MAJ_MIN"
  
  FS1WASHANDLED=0
  IFS=$'\n'
  for DONE1FS in $DONE1FSES
  do
    if [[ "$DONE1FS" == "$MAJ_MIN" ]]
    then
      FS1WASHANDLED=1
      break
    fi
  done

  if [[ ("$SEARCH1FSROOT" == "$ROOTFSROOT") && ("$FS1WASHANDLED" == 0) ]]
  then
  DONE1FSES+="$MAJ_MIN"$'\n'
  IFS=$'\n'
  for SEARCH2FS in $FSES
  do
    TARGETEXCLUDED=0
    eval "$SEARCH2FS"
    SEARCH2ID=$ID
    SEARCH2FSROOT=$FSROOT
    SEARCH2TARGET=$TARGET
    SEARCH2MAJMIN=$MAJ_MIN
    FS2WASHANDLED=0
    for DONE2FS in $DONE2FSES
    do
      if [[ $DONE2FS == $SEARCH2FS ]]
      then
        FS2WASHANDLED=1
        break
      fi
    done

    for EXCLUDE in ${EXCLUDES[@]}
    do
      EXCLUDEREGEX="^$EXCLUDE(/|)"
      if [[ "$SEARCH2TARGET" =~ $EXCLUDEREGEX ]]
      then
        TARGETEXCLUDED=1
        break
      fi
    done


    if [[ ("$SEARCH1MAJMIN" == "$SEARCH2MAJMIN")  && ("$SEARCH1TARGET" != "$SEARCH2TARGET" )  && ("$FS2WASHANDLED" == 0 ) ]]
    then
      if [[ "$SEARCH1TARGET" == "$ROOTFSROOT" ]]
      then
        SEARCH1TARGET=""
      fi
      DONE2FSES+="$SEARCH2FS"$'\n'
      if [[ -f $SEARCH2TARGET ]]
      then
        >&2 echo "$SEARCH2TARGET is a bind mounted file"
        BINDISFILE=1
      fi
      OUTSTR+="MOUNTSOURCE=\"$SEARCH1TARGET$SEARCH2FSROOT\" MOUNTDEST=\"$SEARCH2TARGET\" ISBIND=\"1\" DOOVERLAY=\"0\""$'\n'
    fi

    if [[ ($FS2WASHANDLED == 0) && ("$SEARCH1TARGET" == "$SEARCH2TARGET" ) ]]
    then
      if [[ $TARGETEXCLUDED == 0 ]]
      then
        # TODO detect if overlayfs not supported
        if [[ "" ]]
        then
          >&2 echo "$SEARCH2TARGET is not supported by overlayfs"
          FSCANTOVERLAY=1
        fi
        OUTSTR+="MOUNTSOURCE=\"\" MOUNTDEST=\"$SEARCH2TARGET\" ISBIND=\"0\" DOOVERLAY=\"1\""$'\n'
      else
        OUTSTR+="MOUNTSOURCE=\"\" MOUNTDEST=\"$SEARCH2TARGET\" ISBIND=\"0\" DOOVERLAY=\"0\""$'\n'
      fi
    fi

  done

  fi
done

if [[ $FSCANTOVERLAY == 1 || $BINDISFILE == 1 ]]
then
  exit 1
else
  echo "$OUTSTR" | sort -k3,3 -k2,2 -k4,4
fi
}

MOUNTEDFILESYSTEMS=$(getfilesysteminfo)

#Setup a union mount, if supported
if [[ $HASOVERLAYFS -eq 1 ]]
then
  mkdir "${TMP_DIR}/TRANSL"
  mkdir "${TMP_DIR}/workdir"
  mkdir "${TMP_DIR}/uniondirs"
  mount --make-rprivate /
  MOUNTS=$(findmnt -lUno TARGET|sort)
  #Go through each mount, and create an overlayfs, or bind it in, or create a bind mount, based on an existing bind mount
  IFS=$'\n'
  for MOUNTEDFILESYSTEM in $MOUNTEDFILESYSTEMS
  do
    eval "$MOUNTEDFILESYSTEM"
    if [[ $ISBIND == 0 ]]
    then
      if [[ $DOOVERLAY == 1 ]]
      then
        WORKDIRNAME=$RANDOM$RANDOM$RANDOM$RANDOM$RANDOM
        mkdir -p "${TMP_DIR}/uniondirs/$WORKDIRNAME"
        mkdir -p "${TMP_DIR}/workdir/$MOUNTDEST"
        mkdir -p "${TMP_DIR}/TRANSL/$MOUNTDEST"

        mount -t overlay overlay -o lowerdir="$MOUNTDEST",upperdir="${TMP_DIR}/TRANSL/$MOUNTDEST",workdir="${TMP_DIR}/uniondirs/$WORKDIRNAME" "${TMP_DIR}/workdir/$MOUNTDEST"
      else
        mount --bind $MOUNTDEST "${TMP_DIR}/workdir/$MOUNT"
      fi
    else
      if [[ -d "$MOUNTSOURCE" ]]
      then
        mkdir -p "${TMP_DIR}/TRANSL/$MOUNTSOURCE"
        mkdir -p "${TMP_DIR}/TRANSL/$MOUNTDEST"
        mount --bind "${TMP_DIR}/TRANSL/$MOUNTSOURCE" "${TMP_DIR}/TRANSL/$MOUNTDEST"
        mount --bind "${TMP_DIR}/workdir/$MOUNTSOURCE" "${TMP_DIR}/workdir/$MOUNTDEST"
      fi
    fi

  done
  unset IFS

  pivot_root "${TMP_DIR}/workdir" "${TMP_DIR}/workdir/${TMP_DIR}/uniondirs"
fi

cd "$DIRECTORIO_FUENTE"

"${INSTALLCMD[@]}" 
# Report success or failure
if [ $? -eq 0 ]; then
   exit 0
else
   exit 1
fi

