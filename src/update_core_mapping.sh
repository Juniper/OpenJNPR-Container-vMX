#!/bin/bash
# Copyright (c) 2021, Juniper Networks, Inc.
# All rights reserved.
#

echo "$0: Update interace core_mapping"

write_intf_core_mapping()
{
    # parse interfaces.
    fpc_intf_type="af_packet"
    ix_port=$1
    intf=$2
    io_cpu="$3"
    line_num="2"
    line_num=$(expr $line_num + $(cat  ${core_mapping_file}.cfg |grep ix_port | wc -l))
    if grep -qe "^$intf" ${core_mapping_file}.cfg; then
        sed -i "s/^$intf.*/$intf    ix_port=${ix_port}      rx_cpu=${io_cpu}        tx_cpu=${io_cpu}        $fpc_intf_type/" ${core_mapping_file}.cfg
    else
        sed -i "${line_num}i$intf      ix_port=${ix_port}      rx_cpu=${io_cpu}        tx_cpu=${io_cpu}        $fpc_intf_type" ${core_mapping_file}.cfg
    fi
}

core_mapping_file="/usr/share/pfe/core_mapping"
io_core="${IO_CORE:-1}"

ix_port=0
for intf in $(ls /sys/class/net | grep 'eth[1-9][0-9]*'); do
    write_intf_core_mapping $ix_port $intf $io_core
    ((ix_port += 1))
done
