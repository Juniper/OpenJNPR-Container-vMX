#!/bin/bash
# Copyright (c) 2017, Juniper Networks, Inc.
# All rights reserved.
#
# simple script to extract root passwords from vmx log file

if [ "$USER" == "root" ]; then
  CLI=cli
fi

list=$(docker ps --format '{{.Names}}')
for vmx in $list; do
  descr=$(docker logs $vmx | grep 'root password' | cut -d' ' -f1-5,8 | tr -d '\r' || echo $vmx)
  if [ ! -z "$descr" ]; then
    ip=$(docker logs $vmx | grep 'root password'| awk -F'v4:' '{print $2}' | awk '{print $1}')
    fpcmem=$(ssh -o StrictHostKeyChecking=no -o ConnectTimeout=1 $ip $CLI show chassis fpc 0 2>/dev/null | grep Online | awk '{print $9}')
    fpcmem="${fpcmem:-0}"
    if [ "$fpcmem" -gt "256" ]; then
      success=$(($success + 1))
      echo -e "$descr \t ready"
    else
      echo -e "$descr \t ..."
    fi
  fi
done
