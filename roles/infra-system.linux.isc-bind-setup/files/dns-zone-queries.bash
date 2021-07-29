#!/usr/bin/env bash
# Copyright (C) 2021 Dmitriy Prigoda <deamon.none@gmail.com> 
# This script is free software: Everyone is permitted to copy and distribute verbatim copies of 
# the GNU General Public License as published by the Free Software Foundation, either version 3
# of the License, but changing it is not allowed.

# Export LANG so we get consistent results
# For instance, fr_FR uses comma (,) as the decimal separator.
export LANG=en_US.UTF-8

set -u          # Detect undefined variable
set -o pipefail # Return return code in pipeline fails

function pad {
  PADDING="..............................................................."
  TITLE=$1
  printf "%s%s  " "${TITLE}" "${PADDING:${#TITLE}}"
}

# initialize PRINT_* counters to zero
fail_count=0 ; success_count=0

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

function print_USAGE {
cat <<EOF
Check DNS zone(s) and logs. 
     Options:
        -z | --zone <name>      Check one domain zone for authoritative answers (norecurse).
        -l | --list <files>     Check domain zones for authoritative answers from list (norecurse).
        -c | --check            Check logs.
        -r | --recurse          Enable recursion answers.
    
     Example usage:
        From argument:          bash `basename $0` -z example.com 
        From files:             bash `basename $0` -l domain.txt 
        With recursion:         bash `basename $0` -r example.com 
        Check logs:             bash `basename $0` -c 
        Combine check:          bash `basename $0` -l domain.txt -c 
EOF
exit 2
}

for ARG in "$@"; do
  shift
  case "${ARG}" in
    "--zone")       set -- "$@" "-z" ;;
    "--list")       set -- "$@" "-l" ;;
    "--check")      set -- "$@" "-c" ;;
    "--recurse")    set -- "$@" "-r" ;;
    *)              set -- "$@" "${ARG}"
  esac
done

if [[ -z $* ]]; then
   print_USAGE
fi

function CHECK_RECURSION {
ZONE=$INPUT

dig ANY $ZONE +trace +recurse +nosearch +nodefname
}

function CHECK_ZONE {
ZONE=$INPUT

SERVERS=`nslookup -type=ns $ZONE | awk '/nameserver/ {print $NF}' | sort -u`

if test "$SERVERS" = ""
then
  exit 1
fi

for i in $SERVERS
do
nslookup >/tmp/nsout.$$ 2>/tmp/nserr.$$ <<-EOF
  server $i
  set nosearch
  set nodefname
  set norecurse
  set q=soa
  $ZONE
EOF

if egrep "Non-authorithtive|Authoritative answers can be" /tmp/nsout.$$ >/dev/null
then
  echo "$i non-authorithtive for $ZONE"
  continue
fi

SERIAL=`cat /tmp/nsout.$$ | grep serial | sed -e "s/.*= //"`

if test "$SERIAL" = ""
then
  cat /tmp/nserr.$$
else
  echo "$i sireal number: $SERIAL"
fi
done

rm -f /tmp/nsout.$$ /tmp/nserr.$$

PING=`ping -c 3 -W 1 $ZONE | grep rtt`

echo -e ""
pad "Ping server $ZONE  "
if test "$PING" = ""
then
  print_FAIL
else
  print_SUCCESS
fi
}

function CHECK_ZONES {
while read -r LINE; do
INPUT=$LINE
CHECK_ZONE
done < $LIST
}

function PARSING_LOG {
QERRORS=`grep query-errors /var/named/chroot/var/log/query-errors.log | wc -l`

pad "Counte query errors from log  "
echo " $QERRORS"

XFERERRORS=`grep error /var/named/chroot/var/log/xfer.log | wc -l`

pad "Counte transfer errors from log  "
echo " $XFERERRORS"

DEFWR=`grep -e error -e warning /var/named/chroot/var/log/default.log | wc -l`

pad "Counte warning and errors from log  "
echo " $DEFWR"

echo -e ""
echo -e "Query errors:"
grep query-errors /var/named/chroot/var/log/query-errors.log | awk '{$1=$2=$3=$4=$5=$6=$7=""; print $0}' | sort | uniq -c | sort -rn | grep -i --colour=always -C9999 REFUSED

echo -e ""
echo -e "Transfer errors:"
grep error /var/named/chroot/var/log/xfer.log | awk '{$1=$2=$3=$4=$5=$6=$7=""; print $0}' | sort | uniq -c | sort -rn | grep -i --colour=always -C9999 REFUSED

echo -e ""
echo -e "Default log warning and errors:"
grep -e error -e warning /var/named/chroot/var/log/default.log | awk '{$1=$2=$3=""; print $0}' | sort | uniq -c | sort -rn | grep -i --colour=always -C9999 -e 'ignoring out-of-zone data' -e 'record with inherited owner' | grep -wv 'dumping master file'
}

while getopts "z:l::cr:" OPTION
do
     case $OPTION in
         z) INPUT=${OPTARG}; CHECK_ZONE ;;
         l) LIST=${OPTARG}; CHECK_ZONES ;;
         c) PARSING_LOG ;;
         r) INPUT=${OPTARG}; CHECK_RECURSION ;;
         *) echo "Invalid option."; break;;
     esac
done

exit 0