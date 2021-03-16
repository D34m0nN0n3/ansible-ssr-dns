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

function print_usage_short {
    echo "Get help: \"$0\" for help (-h | --help)"
}

if  [[ $1 == "\-h" ]] ; then
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

# Export LANG so we get consistent results
# For instance, fr_FR uses comma (,) as the decimal separator.
export LANG=en_US.UTF-8

# initialize PRINT_* counters to zero
pass_count=0 ; invalid_count=0

function pad {
  PADDING="..............................................................."
  TITLE=$1
  printf "%s%s  " "${TITLE}" "${PADDING:${#TITLE}}"
}

function print_INVALID {
  echo -e "$@ \e[1;31mINVALID\e[0;39m\n"
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

pad "Check BIND service is active:"
function binding {
	for SERV in {$CHROOT,$NOCHROOT}
	do
	systemctl is-active $SERV > /dev/null && BIND="$SERV" && return 0
	done
	print_INVALID
	return 1
}
if [ $? -ne 0 ]; then
    exit 1
else
    print_PASS
fi

pad "Sanity check configuration:"
named-checkconf /etc/named.conf > /dev/null 2>&1
if [ $? -ne 0 ]; then
    print_INVALID
    exit 1
else
    print_PASS
fi

pad "Sanity check zones:"
named-checkconf -z > /dev/null 2>&1
if [ $? -ne 0 ]; then
    print_INVALID
    exit 1
else
    print_PASS
fi

journalctl -xe _COMM=systemd -u ${BIND} -n 25 --no-pager

exit 0
