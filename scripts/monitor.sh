#!/bin/bash

current_dir=~/magnum_server/scripts/
var_dir=$current_dir/variables

# comand line arguments specified
if [ $# -gt 0 ]; then

  if [ $1 == "-m" ]; then
    grep 'login.*[new|removed] session\|Failed password'  /var/log/auth.log
  
  elif [ $1 == "-f" ]; then
    grep 'Failed password' /var/log/auth.log
  
  elif [ $1 == "-c" ]; then
    grep $2 var/log/auth.log

  else
    printf "run command: monitor [-h] [-m] [-f] [-c]\n-h: Help \n-m: More info \n-f: Failed login \n-c: Custom <search query>\n"
  fi

else
  #find total number of failed passwords
  grep 'systemd-logind' /var/log/auth.log
  failed_attempts=$(grep -o -i 'Failed password' /var/log/auth.log | wc -l)
  last_failed=$(<$var_dir/failed_attempts)
  echo $failed_attempts > $var_dir/failed_attempts

  #find total number of failed logins
  logins=$(grep -o -i 'new session' /var/log/auth.log | wc -l)
  last_logins=$(<$var_dir/logins)
  echo $logins > $var_dir/logins

  
  printf "\n*** Summary ***\n"
  echo "Number of total failed login attempts: $failed_attempts | Failed since last call of monitor $(($failed_attempts-$last_failed))"
  echo "Number of total logins: $logins                  | Logins since last call of monitor $(($logins-$last_logins))"
fi 

