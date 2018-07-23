#!/bin/bash
# Copyright (c) 2018, Juniper Networks, Inc.
# All rights reserved.
#
# create eDB with interface description taken from docker

iflist=""
netlist=$(docker inspect --format='{{range $p, $conf := .NetworkSettings.Networks}} {{$p}}  {{end}}' $HOSTNAME || echo "")

if [ -z "$netlist" ]; then
  exit 0
fi

echo "configure ephemeral openjnpr-container-vmx-vfp0"

index=-1
for net in $netlist; do
  if [ "-1" -eq "$index" ]; then
    ifd="fxp0"
  else
    ifd="ge-0/0/$index"
  fi
  cat <<EOF
set interfaces $ifd description "$net"
EOF
  index=$(($index + 1))
done

echo "commit and-quit"
