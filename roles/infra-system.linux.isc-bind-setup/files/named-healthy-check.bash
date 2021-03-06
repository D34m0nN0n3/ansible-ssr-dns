#!/usr/bin/env bash
# The file we will be editing DNS zone.
# Copyright (C) 2019 Dmitriy Prigoda <deamon.none@gmail.com> 
# This script is free software: Everyone is permitted to copy and distribute verbatim copies of 
# the GNU General Public License as published by the Free Software Foundation, either version 3
# of the License, but changing it is not allowed.
#*********************************************************************************************************************

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

echo -e ""
echo -e "Service: named.service is \e[1;33m${ENABLENOCROOT^^}\e[0;39m \n"
echo -e "Service: named-chroot.service is \e[1;33m${ENABLECHOOT^^}\e[0;39m \n"

pad "Check BIND service is active:"
function binding {
        for SERV in {$CHROOT,$NOCHROOT}
        do
        systemctl is-active $SERV && return 0
        done
        return 1
}
binding > /dev/null 2>&1
if [ $? -ne 0 ]; then
    print_INVALID
    echo -e "Last logs: " && journalctl -xe _COMM=systemd -n 7 --no-pager
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

function loger {
        for SERV in {$CHROOT,$NOCHROOT}
        do
        systemctl is-active $SERV > /dev/null && BIND="$SERV" && return 0
        done
        echo Error! No service is active.
        return 1
}

loger
if [ $? -ne 0 ]; then
    exit 1
else
    echo -e "Last logs: " && journalctl -xe _COMM=systemd -u ${BIND} -n 7 --no-pager
fi

exit 0