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

# Additional functions for this shell script
MINARG=2

SERVER=$1
ZFILE=$2
ZONE=''
DATE=$(date +%Y%m%d)

for ARG in "$@"; do
  shift
  case "${ARG}" in
    "--list")        set -- "$@" "-l" ;;
    "--server")      set -- "$@" "-s" ;;
    *)               set -- "$@" "${ARG}"
  esac
done

mkdir -p zones > /dev/null 2>&1

while IFS= read -r ZONE
do
cat << 'EOF' > zones/${ZONE}
$ORIGIN .
$TTL 86400      ; 1 day
EOF
cat << EOF >> zones/${ZONE}
${ZONE}    IN SOA  $(hostname -f). postmaster.rzd.ru. (
                                $(dig @${SERVER} SOA ${ZONE} | grep -m 1 -o -hE '[0-9]{9,10}') ; serial
                                900        ; refresh (15 minutes)
                                600        ; retry (10 minutes)
                                2592000    ; expire (4 weeks 2 days)
                                900        ; minimum (15 minutes)
                                )
                        NS      ns-a.rzd.ru.
                        NS      ns-b.rzd.ru.
                        NS      ns-c.rzd.ru.
EOF
dig @${SERVER} AXFR ${ZONE} | sort -h | sed "/\(^;.*$\|^.*SOA.*$\|^${ZONE}.*IN.*NS.*ns-[abc].rzd.ru.$\|^$\)/d" >> zones/${ZONE} | chown :named zones/${ZONE}
pad "${ZONE} Serial: $(head -10 zones/${ZONE} | grep -m 1 -o -hE '[0-9]{9,10}')"
named-checkzone ${ZONE} zones/${ZONE} > /dev/null 2>&1
if [ $? -ne 0 ]; then 
    print_INVALID
else
    print_PASS 
fi
done < "${ZFILE}"

exit 0
