#!/bin/bash

if [ $# -gt 0 ]; then
  if [ $1 == "-h" ]; then
    printf "run command: monitor [-h] [-m] \n-h: Help \n-m More info\n"
  elif [ $1 == "-m" ]; then
    grep 'systemd-logind' /var/log/auth.log
  elif [ $1 == "-f" ]; then
    grep 'Failed password' /var/log/auth.log
  fi
else
  grep '[login.*[new|removed] session|Failed password]'  /var/log/auth.log
fi 
