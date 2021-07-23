#!/bin/bash
# Copyright (c) 2017, Juniper Networks, Inc.
# All rights reserved.

# Hack to fix a pending network ordering issue in Docker
# https://github.com/docker/compose/issues/4645
# We use docker insepct of our very own container to learn the expected network
# order by grabbing the MAC addresses, except eth0, which is always correct.
# Then we swap the ethX interfaces as needed


write_core_mapping()
{
    local total_lines
    local master_core=$1
    local io_cpu=$2
    local worker_core=$3

    if grep -qe "CONFIG START" ${core_mapping_file}.cfg; then
        sed -i "s/^.*CONFIG START.*/###########  CONFIG START #########/" ${core_mapping_file}.cfg
        sed -i "s/^.*CONFIG END.*/###########  CONFIG END #########/" ${core_mapping_file}.cfg
    else
        echo  "###########  CONFIG START #########" >> ${core_mapping_file}.cfg
        echo "###########  CONFIG END #########" >> ${core_mapping_file}.cfg
    fi
    total_lines=$(cat ${core_mapping_file}.cfg |wc -l)
    if grep -qe "^master_core" ${core_mapping_file}.cfg; then
        sed -i "s/^master_core=.*/master_core=0" ${core_mapping_file}.cfg
    else
        sed -i "${total_lines}imaster_core=0" ${core_mapping_file}.cfg
    fi
    total_lines=$(cat ${core_mapping_file}.cfg |wc -l)
    # Let flow manager core be same as worker core. ideally it should be different.
    if [ "x$is_riot_flow_cache" == "x1" ];then
        if grep -qe "^flow_manager" ${core_mapping_file}.cfg; then
            sed -i "s/^flow_manager=.*/flow_manager=2" ${core_mapping_file}.cfg
        else
            sed -i "${total_lines}iflow_manager=2" ${core_mapping_file}.cfg
        fi
    fi
    total_lines=$(cat ${core_mapping_file}.cfg |wc -l)
    if grep -qe "^worker_cpu" ${core_mapping_file}.cfg; then
        sed -i "s/^worker_cpu=.*/worker_cpu=2" ${core_mapping_file}.cfg
    else
	sed -i "${total_lines}iworker_cpu=2" ${core_mapping_file}.cfg
    fi

    lcore_mask="(0)@($master_core),(1-2)@($io_core,$worker_core)"
    total_cpu=($master_core $io_core $worker_core)
    total_num_cpu=${#total_cpu[@]}
    total_lines=$(cat $core_mapping_file${fpc_num}.cfg |wc -l)
    core_mask=$(echo "obase=16;2^$total_num_cpu - 1" | bc)
    if grep -qe "^eal_args" /etc/riot/init.conf; then
        sed -i "s/^eal_args=.*/eal_args=-m 1024 --file-prefix=riot --lcores='$lcore_mask' -c $core_mask --no-huge/" /etc/riot/init.conf
    else
        echo "eal_args=-m 1024 --file-prefix=riot --lcores='$lcore_mask' -c $core_mask --no-huge" >> /etc/riot/init.conf
    fi
}

echo "$0: trying to fix network interface order via docker inspect myself ..."

# get ordered list of MAC addresses, but skip the first empty one 
MACS=$(docker inspect $HOSTNAME 2>/dev/null |grep MacAddr|awk '{print $2}' | cut -d'"' -f2| tail -n +2|tr '\n' ' ')
io_core="${IO_CORE:-1}"
worker_core="${WORKER_CORE:-2}"
master_core="${MASTER_CORE:-0}"
core_mapping_file="/usr/share/pfe/core_mapping"
write_core_mapping $master_core $io_core $worker_core

echo "MACS=$MACS"
index=0
for mac in $MACS; do
  FROM=$(ip link | grep -B1 $mac | head -1 | awk '{print $2}'|cut -d@ -f1)
  TO="eth$index"
  if [ "$FROM" == "$TO" ]; then
    echo "$mac $FROM == $TO"
  else
    echo "$mac $FROM -> $TO"
    FROMIP6=$(ip addr show $FROM | awk '/inet6/ {print $2}' | grep -v fe80)
    TOIP6=$(ip addr show $TO | awk '/inet6/ {print $2}' | grep -v fe80)
    echo "FROM $FROM ($FROMIP6) TO $TO ($TOIP6)"
    ip link set dev $FROM down
    ip link set dev $TO down
    ip link set dev $FROM name peth
    ip link set dev $TO name $FROM
    ip link set dev peth name $TO
    ip link set dev $FROM up
    if [ ! -z "$TOIP6" ]; then
        ip -6 addr add $TOIP6 dev $FROM
    fi
    ip link set dev $TO up
    if [ ! -z "$FROMIP6" ]; then
        ip -6 addr add $FROMIP6 dev $TO
    fi
    ethtool --offload $FROM tx off
    ethtool --offload $TO tx off
  fi
  index=$(($index + 1))
done

