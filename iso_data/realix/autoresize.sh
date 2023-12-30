#!/usr/bin/env bash

function resize()
  {
    sudo growpart $1 $2 &> /dev/null
    if [[ 0 == $? ]]; then
      sudo resize2fs "$1"$2 &> /dev/null
      if [[ 0 == $? ]]; then 
          echo "($1/$2) growing done"
      else
          echo "($1/$2) growing FAILED (resize2fs)"
      fi
    fi
  }

# Find the boot disk
BOOT=$(df | grep "/boot\$" | awk '{print $1}' | head -c8)

if [[ $BOOT == "/dev/sda" ]]; then
	resize /dev/sda 2
	resize /dev/sdb 1
else
	resize /dev/sda 1
	resize /dev/sdb 2
fi
