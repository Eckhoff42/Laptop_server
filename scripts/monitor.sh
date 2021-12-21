#!/bin/bash

if [ $# -gt 0 ]; then
  if [ $1 == "-h" ]; then
    printf "run command: monitor [-h] [-m] [-f]\n-h: Help \n-m More info \n-f: failed login \n-c custom <search query>"
  elif [ $1 == "-m" ]; then
    grep 'login.*[new|removed] session\|Failed password'  /var/log/auth.log
  elif [ $1 == "-f" ]; then
    grep 'Failed password' /var/log/auth.log
  elif [ $1 == "-c" ]; then
    grep $2 var/log/auth.log
  fi
else
  grep 'systemd-logind' /var/log/auth.log
  failed_atempts=$(grep -o -i 'Failed password' /var/log/auth.log | wc -l)
  logins=$(grep -o -i 'new session' /var/log/auth.log | wc -l)
  
  printf "\n*** Summary ***\n"
  echo "Number of total failed login attempts: $failed_atempts"
  echo "Number of total logins: $logins"
fi 
