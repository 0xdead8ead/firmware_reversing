#!/bin/sh

# $1: process name by tsrite

while [ 1 ]
do
  sleep 3

  pid=`ps | grep /mydlink/$1 | grep -v grep | sed 's/^[ \t]*//'  | sed 's/ .*//' `
  if [ -z "$pid" ]; then
    echo "[`date`] $1 is not running!"

    killall $1
    if [ -f /mydlink/$1 ]; then
      /mydlink/$1 > /dev/null 2>&1 & 
    elif [ -f /opt/$1 ]; then
      /opt/$1 > /dev/null 2>&1 & 
    fi
  fi

done
