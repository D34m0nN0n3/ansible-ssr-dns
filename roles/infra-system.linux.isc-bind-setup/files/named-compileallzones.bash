#!/usr/bin/env bash
# The file we will be editing DNS zone.
# Copyright (C) 2022 Dmitriy Prigoda <deamon.none@gmail.com> 
# This script is free software: Everyone is permitted to copy and distribute verbatim copies of 
# the GNU General Public License as published by the Free Software Foundation, either version 3
# of the License, but changing it is not allowed.
#*********************************************************************************************************************

if [[ $EUID -ne 0 ]]; then
  if [[ $(id -g -r) -ne 25 ]]; then
     echo "[-] This script must be run as root or named group users" 1>&2
     exit 255
  fi
fi

# Export LANG so we get consistent results
# For instance, fr_FR uses comma (,) as the decimal separator.
export LANG=en_US.UTF-8

# initialize PRINT_* counters to zero
pass_count=0 ; invalid_count=0 ; fail_count=0 ; success_count=0

function pad {
  PADDING="..............................................................."
  TITLE=$1
  printf "%s%s  " "${TITLE}" "${PADDING:${#TITLE}}"
}

function print_INVALID {
  echo -e "$@ \e[1;33mINVALID\e[0;39m\n"
  let exist_count++
  return 0
}

function print_PASS {
  echo -e "$@ \e[1;32mPASS\e[0;39m\n"
  let pass_count++
  return 0
}

function panic {
  local error_code=${1} ; shift
  echo "Error: ${@}" 1>&2
  exit ${error_code}
}

ZDIR=$1
ZFILE=''

# Create dir for binary files.
mkdir zones_db > /dev/null 2>&1

for ZFILE in $(ls ${ZDIR})
do
ZTYPE=$(file ${ZFILE} | grep -oe 'ASCII text';)
# Conver RAW to TEXT or creat backup file ZONE.
if [[ ZTYPE == 'ASCII text' ]]; then
named-compilezone -f text -F raw -o zones_db/${ZFILE} ${ZFILE} ${ZDIR}/${ZFILE} > /dev/null 2>&1
fi
pad "${ZFILE} "
# Check zone.
named-checkzone -f raw ${ZFILE} zones_db/${ZFILE} > /dev/null 2>&1
if [ $? -ne 0 ]; then
    print_INVALID
else
    print_PASS
fi
done

exit 0
