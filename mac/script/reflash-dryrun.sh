#!/bin/bash
SCRIPT=$(basename "$0")
CURPATH=$(dirname "$0")
BINPATH=$CURPATH/../bin
SCRIPTPATH=$CURPATH/../script
EXEC=echo
[ -z "$TARGET" ] && TARGET=atmega32u4
VER=0.7
HEX=
HEX_ORIG=
EEP=

function usage {
  echo "Usage: $SCRIPT (eep | hex [hex | eep])"
  exit 1
}

[ -z "$1" ] && usage
[ ! -f "$1" ] && usage
ARG1=$1
ARG1_NAME=$(basename "$ARG1")
ARG1_EXT=${ARG1_NAME##*.}
case "$ARG1_EXT" in
  "hex")
    if [ "$#" -gt 1 ]
    then
      [ ! -f "$2" ] && usage
      ARG2=$2
      ARG2_NAME=$(basename "$ARG2")
      ARG2_EXT=${ARG2_NAME##*.}
      case "$ARG2_EXT" in
        "hex")
          HEX_ORIG=$ARG1
          HEX=$ARG2
          ;;
        "eep")
          HEX=$ARG1
          EEP=$ARG2
          ;;
      esac
    else
      HEX=$ARG1
    fi
    ;;
  "eep")
    EEP=$ARG1
    ;;
  *)
    usage
    ;;
esac

# get_version
# wait_bootloader

if [ -n "$HEX" ]
then
  echo "Erasing..."
  if [ "$VER" == "0.7" ]
  then
    "$EXEC" dfu-programmer $TARGET erase --force
  else
    "$EXEC" $TARGET erase
  fi
  echo Reflashing HEX file...
  "$EXEC" dfu-programmer $TARGET flash "$HEX"
fi

if [ -n "$EEP" ]
then
  echo "Reflashing EEP file..."
  if [ "$VER" == "0.7" ]
  then
    "$EXEC" dfu-programmer $TARGET flash-eeprom --force "$EEP"
  else
    "$EXEC" $TARGET flash-eeprom "$EEP"
  fi

fi

EXITCODE=$?
if [ $EXITCODE -eq 0 ]
then
  echo "Success!"
else
  echo "Fail!"
fi

"$EXEC" dfu-programmer $TARGET reset

exit $EXITCODE
