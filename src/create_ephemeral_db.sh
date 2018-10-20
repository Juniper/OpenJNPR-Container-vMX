#!/bin/bash
# Copyright (c) 2018, Juniper Networks, Inc.
# All rights reserved.
#
# create eDB with interface description taken from docker

# start with existing xe interfaces (used by vmx-docker-lwaftr)

netlist=$(ip link|grep ' xe'| cut -d' ' -f2 | cut -d: -f1)
index=0

echo "configure ephemeral openjnpr-container-vmx-vfp0"

for net in $netlist; do
  ifd="ge-0/0/$index"
  cat <<EOF
set interfaces $ifd description "$net"
EOF
  index=$(($index + 1))
done

# docker networks follow next, attached to eth0, eth1, ...

netlist=$(docker inspect --format='{{range $p, $conf := .NetworkSettings.Networks}} {{$p}}  {{end}}' $HOSTNAME || echo "")
netlist=$(echo $netlist | cut -d' ' -f2-)   # remove first net, used for fxp0 already

for net in $netlist; do
  ifd="ge-0/0/$index"
  ethindex=$(($index + 1))
  ip addr flush dev eth${ethindex}
  cat <<EOF
set interfaces $ifd description "$net"
EOF
  index=$(($index + 1))
done

echo "commit and-quit"
