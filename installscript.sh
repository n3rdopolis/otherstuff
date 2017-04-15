#!/bin/bash

# TODO detect if overlayfs not supported
function checkcanoverlay
{
  return 0
}

function getmountmap
{
  #Get if root is a mountpont
  mountpoint / -q
  ROOTISMOUNTPOINT=$?

  #Handle choots
  if [[ $ROOTISMOUNTPOINT != 0 ]]
  then
    >&2 echo "/ is not a mountpoint. Is / a chroot? Try to bindmount the chroot path onto itself"
    return 1
  fi
  INITROOTFS=$(findmnt -vUrno FSROOT -N1 /)
  THISROOTFS=$(findmnt -vUrno FSROOT /)
  if [[ "$INITROOTFS" != "$THISROOTFS" ]]
  then
    CHROOTPATH="$THISROOTFS"
  else
    CHROOTPATH=/
  fi
  FSES=$(findmnt -vUPno MAJ:MIN,FSROOT,TARGET,ID  | sed -e "s|$CHROOTPATH|/|g" -e "s|//|/|g" -e "s|^MAJ:MIN=|MAJ_MIN=|g" | sort -k4,4n --stable -k 1,1 -k2,2)

  IFS=,
  EXCLUDES+=($IEXCLUDE)
  EXCLUDES+=($EXCLUDE)
  unset IFS
  EXCLUDECOUNT=${#EXCLUDES[@]}

  if [[ $EXCLUDECOUNT == 0 ]]
  then
    EXCLUDES=(/proc,/sys,/dev,/run,/tmp)
  fi

  MOUNT_MAP_OUTPUT=""

  FILE_IS_BIND_MOUNTED=0
  UNSUPPORTED_LOWERDIR_FS=0


  unset DONE1FSES
  IFS=$'\n'
  for SEARCH1FS in $FSES
  do
    HASBINDS=0
    unset DONE2FSES
    unset IFS
    declare $SEARCH1FS
    SEARCH1ID="${ID:1:-1}"
    SEARCH1FSROOT="${FSROOT:1:-1}"
    SEARCH1TARGET="${TARGET:1:-1}"
    SEARCH1MAJMIN="${MAJ_MIN:1:-1}"

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

    if [[ ("$SEARCH1FSROOT" == "/") && ("$FS1WASHANDLED" == 0) ]]
    then
    DONE1FSES+="$MAJ_MIN"$'\n'
    IFS=$'\n'
    for SEARCH2FS in $FSES
    do
      TARGETEXCLUDED=0
      unset IFS
      declare $SEARCH2FS
      SEARCH2ID="${ID:1:-1}"
      SEARCH2FSROOT="${FSROOT:1:-1}"
      SEARCH2TARGET="${TARGET:1:-1}"
      SEARCH2MAJMIN="${MAJ_MIN:1:-1}"
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
        if [[ "$SEARCH1TARGET" == "/" ]]
        then
          SEARCH1TARGET=""
        fi
        DONE2FSES+="$SEARCH2FS"$'\n'
        if [[ -f $SEARCH2TARGET ]]
        then
          >&2 echo "$SEARCH2TARGET is a bind mounted file"
          FILE_IS_BIND_MOUNTED=1
        fi
        MOUNT_MAP_OUTPUT+="MOUNTSOURCE=\"$SEARCH1TARGET$SEARCH2FSROOT\" MOUNTDEST=\"$SEARCH2TARGET\" ISBIND=\"1\" DOOVERLAY=\"0\""$'\n'
      fi

      if [[ ($FS2WASHANDLED == 0) && ("$SEARCH1TARGET" == "$SEARCH2TARGET" ) ]]
      then
        if [[ $TARGETEXCLUDED == 0 ]]
        then
          checkcanoverlay "$SEARCH2TARGET"
          filesystemcanoverlay=$?
          if [[ $filesystemcanoverlay != 0 ]]
          then
            >&2 echo "$SEARCH2TARGET is not supported by overlayfs"
            UNSUPPORTED_LOWERDIR_FS=1
          fi
          MOUNT_MAP_OUTPUT+="MOUNTSOURCE=\"\" MOUNTDEST=\"$SEARCH2TARGET\" ISBIND=\"0\" DOOVERLAY=\"1\""$'\n'
        else
          MOUNT_MAP_OUTPUT+="MOUNTSOURCE=\"\" MOUNTDEST=\"$SEARCH2TARGET\" ISBIND=\"0\" DOOVERLAY=\"0\""$'\n'
        fi
      fi

    done

    fi
  done

  if [[ $UNSUPPORTED_LOWERDIR_FS == 1 || $FILE_IS_BIND_MOUNTED == 1 ]]
  then
    return 1
  else
    echo "$MOUNT_MAP_OUTPUT" | sort -k3,3 -k2,2 -k4,4
  fi
}


function createtraslationmounts
{
  MAPPEDMOUNTS=$(</dev/stdin)
  mkdir "${TMP_DIR}/TRANSL"
  mkdir "${TMP_DIR}/workdir"
  mkdir "${TMP_DIR}/uniondirs"
  declare -i MOUNTFAILCOUNT=0
  mount --make-rprivate /
  MOUNTRESULT=$?
  MOUNTFAILCOUNT+=$MOUNTRESULT
  if [[ $MOUNTRESULT != 0 ]]
  then
    >&2 echo "Failed to make all mounts private"
  fi
  MOUNTS=$(findmnt -lUno TARGET|sort)
  #Go through each mount, and create an overlayfs, or bind it in, or create a bind mount, based on an existing bind mount
  IFS=$'\n'
  for MAPPEDMOUNT in $MAPPEDMOUNTS
  do
    eval "$MAPPEDMOUNT"
    if [[ $ISBIND == 0 ]]
    then
      if [[ $DOOVERLAY == 1 ]]
      then
        WORKDIRNAME=$RANDOM$RANDOM$RANDOM$RANDOM$RANDOM
        mkdir -p "${TMP_DIR}/uniondirs/$WORKDIRNAME"
        mkdir -p "${TMP_DIR}/workdir/$MOUNTDEST"
        mkdir -p "${TMP_DIR}/TRANSL/$MOUNTDEST"

        mount -t overlay overlay -o lowerdir="$MOUNTDEST",upperdir="${TMP_DIR}/TRANSL/$MOUNTDEST",workdir="${TMP_DIR}/uniondirs/$WORKDIRNAME" "${TMP_DIR}/workdir/$MOUNTDEST"
        MOUNTRESULT=$?
        MOUNTFAILCOUNT+=$MOUNTRESULT
        if [[ $MOUNTRESULT != 0 ]]
        then
          >&2 echo "Failed to union mount $MOUNTDEST"
        fi
      else
        mount --bind $MOUNTDEST "${TMP_DIR}/workdir/$MOUNTDEST"
        MOUNTRESULT=$?
        MOUNTFAILCOUNT+=$MOUNTRESULT
        if [[ $MOUNTRESULT != 0 ]]
        then
          >&2 echo "Failed to bind in non unioned $MOUNTDEST"
        fi
      fi
    else
      if [[ -d "$MOUNTSOURCE" ]]
      then
        mkdir -p "${TMP_DIR}/TRANSL/$MOUNTSOURCE"
        mkdir -p "${TMP_DIR}/TRANSL/$MOUNTDEST"
        mount --bind "${TMP_DIR}/TRANSL/$MOUNTSOURCE" "${TMP_DIR}/TRANSL/$MOUNTDEST"
        MOUNTRESULT=$?
        MOUNTFAILCOUNT+=$MOUNTRESULT
        if [[ $MOUNTRESULT != 0 ]]
        then
          >&2 echo "Failed bind mount real $MOUNTSOURCE to $MOUNTDEST"
        fi
        mount --bind "${TMP_DIR}/workdir/$MOUNTSOURCE" "${TMP_DIR}/workdir/$MOUNTDEST"
        MOUNTRESULT=$?
        MOUNTFAILCOUNT+=$MOUNTRESULT
        if [[ $MOUNTRESULT != 0 ]]
        then
          >&2 echo "Failed bind mount translation $MOUNTSOURCE to $MOUNTDEST"
        fi
      else
        >&2 echo "$MOUNTSOURCE does not exist"
        MOUNTFAILCOUNT+=1
      fi
    fi

  done
  unset IFS

  pivot_root "${TMP_DIR}/workdir" "${TMP_DIR}/workdir/${TMP_DIR}/uniondirs"
  MOUNTRESULT=$?
  MOUNTFAILCOUNT+=$MOUNTRESULT
  if [[ $MOUNTRESULT != 0 ]]
  then
    >&2 echo "Failed to pivot_root"
  fi

  if [[ $MOUNTFAILCOUNT == 0 ]]
  then
    return 0
  else
    return 1
  fi
}
createtraslationmounts < <(echo "$FILESYSTEMMAP")
MOUNTSTATUS=$?
if [[ $MOUNTSTATUS != 0 ]]
then
  echo "An overlay traslation file system mount, or bind mount failed"
  return 1
fi

cd "$DIRECTORIO_FUENTE"

"${INSTALLCMD[@]}" 
# Report success or failure
if [ $? -eq 0 ]; then
   exit 0
else
   exit 1
fi

