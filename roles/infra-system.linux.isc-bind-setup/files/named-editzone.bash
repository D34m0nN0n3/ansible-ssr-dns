#!/usr/bin/env bash
# The file we will be editing DNS zone.
# Copyright (C) 2019 Dmitriy Prigoda <deamon.none@gmail.com> 
# This script is free software: Everyone is permitted to copy and distribute verbatim copies of 
# the GNU General Public License as published by the Free Software Foundation, either version 3
# of the License, but changing it is not allowed.
#*********************************************************************************************************************

if [[ $EUID -ne 0 ]]; then
   echo "[-] This script must be run as root" 1>&2
   exit 1
fi

# Additional functions for this shell script
MINARG=2

function print_usage_short {
    echo "Get help: \"$0\" for help (-h | --help)"
}

if  [[ $1 == "\-h" ]] ; then
    print_usage_short
    exit 1
    else
    if [ $# -lt "$MINARG" ] ; then
    print_usage_short
    exit 1
    fi
fi

function print_usage {
cat <<EOF
Use this script: \"$0\" <domain> <file zone>


EOF
}

if  [[ $1 == "\-\-h" ]] ; then
    print_usage
    exit 1
fi

PACKAGES=( bash )
# Define some default values for this script
DOMAIN=$1
FILE=$2
DATE=$(date +%Y%m%d)
SERNUM=$(grep -m 1 -o -hE '[0-9]{9,10}' $FILE)
SERTMP="${DATE}00"
SERNEW=''
BIND=''
CHROOT='named-chroot.service'
NOCHROOT='named.service'

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

function print_FAIL {
  echo -e "$@ \e[1;31mFAIL\e[0;39m\n"
  let fail_count++
  return 0
}

function print_SUCCESS {
  echo -e "$@ \e[1;32mSUCCESS\e[0;39m\n"
  let success_count++
  return 0
}

function panic {
  local error_code=${1} ; shift
  echo "Error: ${@}" 1>&2
  exit ${error_code}
}

# Creat backup file ZONE.
cp -p ${FILE} ${FILE}.${DATE}.bak > /dev/null 2>&1
[[ ! -f ${FILE}.${DATE}.bak ]] && panic 1 "${FILE}.${DATE}.bak does not exist"

# Run VIM in sudo to open the file.
echo "Editing $FILE..."
vim -c ":set tabstop=8" -c ":set shiftwidth=8" -c ":set noexpandtab" ${FILE}.${DATE}.bak
echo -e "\t\t[OK]"
echo ""
# Force decimal representation, increment.
if [ "${SERNUM}" -lt "${DATE}00" ]; then
    SERNEW="${DATE}01"
else
    PREFIX=${SERNUM::-2}
    if [ "${DATE}" -eq "${PREFIX}" ]; then
      NUM=${SERNUM: -2}
      NUM=$((10#$NUM + 1))
      SERNEW="${DATE}$(printf '%02d' $NUM )"
    else
     SERNEW="${SERTMP}"
    fi
fi
pad "Change serial number:"
awk '/'${SERNUM}'/ && !done { sub(/'${SERNUM}'/, "'${SERNEW}'"); done=1}; 1' ${FILE}.${DATE}.bak > ${FILE}.tmp
if [ $? -ne 0 ]; then 
    print_FAIL
    exit 1
else
    print_SUCCESS
fi
# Sanity check
pad "Sanity check:"
named-checkzone $DOMAIN ${FILE}.tmp > /dev/null 2>&1
if [ $? -ne 0 ]; then
    print_INVALID
    echo -n "Sanity check failed, reverting to old SOA:"
    rm -f ${FILE}.${DATE}.bak && rm -f ${FILE}.tmp;
    exit 1
else
    print_PASS
fi
# Continue to automatic functionality.
read -p "Ready to commit? " choice
    while :
      do
        case "$choice" in
            y|Y) mv ${FILE}.tmp ${FILE} && mv ${FILE}.${DATE}.bak /tmp/${FILE}.${DATE}; break;;
            n|N) echo "Changes will not be automatically committed, exiting."; exit;;
            * ) read -p "Please enter 'y' or 'n': " choice;;
          esac
      done
echo ""
# Restart BIND 
pad "Restarting BIND:"
function binding {
	for SERV in {$CHROOT,$NOCHROOT}
	do
	systemctl is-active $SERV > /dev/null && BIND="$SERV" && return 0
	done
	echo Error! No service is active.
	return 1
}
binding && rndc flush && rndc reload > /dev/null 2>&1
if [ $? -ne 0 ]; then
    exit 1
else
    print_SUCCESS
fi

#END
exit 0