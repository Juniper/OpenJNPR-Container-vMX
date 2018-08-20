#!/bin/bash
# Copyright (c) 2017, Juniper Networks, Inc.
# All rights reserved.
#

echo 1 > /var/jnx/docker

PFE_SRC=/usr/share/pfe

# Start broadcasting Gratuitous ARP and ping
#  required to keep VCP arp table up-to-date
arping -q -A -I br-int 128.0.0.16  2>&1 > /dev/null &
ping -i 3 -rnq -I br-int 128.0.0.1 2>&1 > /dev/null &

# Wait for VM to start/boot
echo -n "Waiting for VCP to boot... "
start=$(date +"%s")
while ! ping -nqc1 -I br-int -W 1 128.0.0.1 2>&1 > /dev/null; do
  sleep 1
done
end=$(date +"%s")
echo "Done [$(($end - $start))s]"

if [ ! -f /etc/vmxt/init.conf ]; then
  cores=$(cat /proc/self/status |grep Cpus_allowed_list|awk '{print $2}')
  if [ -z "${cores##*,*}" ]; then
    IFS=', ' read -r -a array <<< "$cores" 
    vmxtcore=${array[$RANDOM % ${#array[@]} ]}
  else
    vmxtcore=$(shuf -i $cores -n 1)
  fi
fi

# create eDB with interface description taken from docker
/create_ephemeral_db.sh > /tmp/vfp0.cli
if [ -s /tmp/vfp0.cli ]; then
  rcp /tmp/vfp0.cli 128.0.0.1:/tmp/
  rsh 128.0.0.1 "cli < /tmp/vfp0.cli"
fi

echo "patching start_vmxt.sh ..."
rcp 128.0.0.1:/usr/share/pfe/start_vmxt.sh .
rsh 128.0.0.1 mv /usr/share/pfe/start_vmxt.sh /usr/share/pfe/start_vmxt.sh.orig
if [ ! -f /etc/vmxt/init.conf ]; then
  echo "use cpu $vmxtcore for Junos"
  sed -i "s/C 2/C $vmxtcore -L/" start_vmxt.sh
fi
#mkdir /etc/vmxt
#echo "ukern_cpu \"$vmxtcore\"" > /etc/vmxt/init.conf
rcp start_vmxt.sh 128.0.0.1:/usr/share/pfe/

# patch riot to allow macvlan interfaces too
echo "patching riot.tgz ..."
cd /tmp

rcp 128.0.0.1:/usr/share/pfe/riot_lnx.tgz .
tar zxf riot_lnx.tgz
patch -Np0 < /riot.patch
patch -Np0 < /riot_start.patch
patch -Np0 < /device_list.sh.patch

echo "patching done. Uploading riot_lnx.tgz to VCP ..."
tar zcf riot_lnx.tgz riot
rsh 128.0.0.1 mv /usr/share/pfe/riot_lnx.tgz /usr/share/pfe/riot_lnx.tgz.orig
rcp riot_lnx.tgz 128.0.0.1:/usr/share/pfe/
# fix checksum
rsh 128.0.0.1 mv /usr/share/pfe/riot_lnx.sha1 /usr/share/pfe/riot_lnx.sha1.orig
rsh 128.0.0.1 "sha1 /usr/share/pfe/riot_lnx.tgz > /usr/share/pfe/riot_lnx.sha1"

rcp 128.0.0.1:${PFE_SRC}/mpcsd_lnx ${PFE_SRC}/mpcsd
rcp 128.0.0.1:${PFE_SRC}/mpcsd_lnx.sha1 ${PFE_SRC}/

while true; do
  echo "starting mpcsd"
  ${PFE_SRC}/mpcsd 0 2986 1 -N -L
  sleep 5
done
