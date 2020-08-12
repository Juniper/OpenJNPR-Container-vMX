#!/bin/bash
# Copyright (c) 2017, Juniper Networks, Inc.
# All rights reserved.
#

#echo 1 > /var/jnx/docker

PFE_SRC=/usr/share/pfe
ukern_init_file="/etc/vmxt/init"
mv /etc/riot/riot_init.conf /etc/riot/init.conf
mv /etc/vmxt/vmxt_init.conf /etc/vmxt/init.conf


# "$ukern_init_file contains default value of ukern core to use
# change that to user supplied core value."
write_vmxt_init()
{
  local ukern_cpu
  local non_ukern_cpu
  ukern_cpu=$1
  non_ukern_cpu=$1
  ukern_cpu=$(echo "obase=10;2^$ukern_cpu" | bc)
  non_ukern_cpu=$(echo "obase=10;2^$non_ukern_cpu" | bc)

  if grep -qe "^ukern_cpu" $ukern_init_file${fpc_name}.conf; then
        sed -i "s/^ukern_cpu=.*/ukern_cpu=\"${ukern_cpu}\"/" $ukern_init_file${fpc_name}.conf
    else
        echo "ukern_cpu=\"${ukern_cpu}\"" >> $ukern_init_file${fpc_name}.conf
    fi
    if grep -qe "^non_ukern_cpu" $ukern_init_file${fpc_name}.conf; then
        sed -i "s/^non_ukern_cpu=.*/non_ukern_cpu=\"$non_ukern_cpu\"/" $ukern_init_file${fpc_name}.conf
    else
        echo "non_ukern_cpu=\"$non_ukern_cpu\"" >> $ukern_init_file${fpc_name}.conf
    fi
    if [ "x$ukern_cpu" == "x$non_ukern_cpu" ];then
        if grep -qe "^lazy_alloc" $ukern_init_file${fpc_name}.conf; then
            sed -i "s/^lazy_alloc=.*/lazy_alloc=\"1\"/" $ukern_init_file${fpc_name}.conf
        else
            echo "lazy_alloc=\"1\"" >> $ukern_init_file${fpc_name}.conf
        fi
    else
        sed -i "s/^lazy_alloc//" $ukern_init_file${fpc_name}.conf
    fi
}


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

# create eDB with interface description taken from docker
/create_ephemeral_db.sh > /tmp/vfp0.cli
if [ -s /tmp/vfp0.cli ]; then
  rcp /tmp/vfp0.cli 128.0.0.1:/tmp/
  rsh 128.0.0.1 "cli < /tmp/vfp0.cli"
fi

vmxtcore="${VMXT_CORE:-2}"
write_vmxt_init $vmxtcore

# patch riot to allow macvlan interfaces too
echo "patching riot.tgz ..."
cd /tmp

rcp 128.0.0.1:/usr/share/pfe/riot_lnx.tgz .
tar zxf riot_lnx.tgz
patch -Np0 < /riot.patch

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
