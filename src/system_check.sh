#!/bin/bash
# Copyright (c) 2017, Juniper Networks, Inc.
# All rights reserved.
#

fatal=0
warning=0

echo " "
uname -snrvm
echo " "

cpumodel=$(grep 'model name' /proc/cpuinfo |head -1|cut -d: -f2)
echo    "CPU Model ................................$cpumodel"
echo -n "CPU affinity of this container ..........."
TASKSET=$(taskset -cp $$ |cut -d: -f2)
echo "$TASKSET"

echo -n "KVM hardware virtualization extension .... "
yesno=$(egrep -q 'vmx|svm' /proc/cpuinfo && echo yes || echo no)
echo $yesno
if [ "$yesno" == "no" ]; then
  fatal=$(($fatal + 1))
  echo "Check http://www.linux-kvm.org/page/FAQ"
  echo " "
fi

echo -n "Total System Memory ...................... "
memtotal=$(cat /proc/meminfo|grep MemTotal:|awk '{print $2}')
memtotalgb=$(expr $memtotal / 1024 / 1024)
echo $memtotalgb GB

echo -n "Free Hugepages ........................... "
freehp=$(grep HugePages_Free /proc/meminfo | awk '{print $2}')
hpsize=$(grep Hugepagesize /proc/meminfo | awk '{print $2}')
hpsizemb=$(expr $hpsize / 1024)
freehpmb=$(expr $freehp \* $hpsizemb)
if [ $freehpmb -gt 1023 ]; then
  echo "yes ($freehp x ${hpsizemb} MB = $freehpmb MB)"
else
  echo "none! Please provision at least 1G (512x2MB or 1x1GB) hugepage"
  fatal=$(($fatal + 1))
fi

echo -n "Check for container privileged mode ...... "
echo "hello" 2>/dev/null > /sys/fs/cgroup/aaa
if [ $? -eq 0 ]; then
  echo yes
else
  echo "no! Please run container with --privileged option"
  fatal=$(($fatal + 1))
fi

echo -n "Check for sudo/root privileges ........... "
if [[ $EUID -eq 0 ]]; then
     echo yes
else
  echo no
  fatal=$(($fatal + 1))
fi

echo -n "Loop mount filesystem capability ......... "
dd if=/dev/zero of=/tmp/test$$  bs=1M count=1 >/dev/null 2>&1
mkfs.vfat /tmp/test$$ >/dev/null 2>&1
mkdir /tmp/mount$$ 2>/dev/null
mount -o loop /tmp/test$$ /tmp/mount$$ 2>/dev/null
rv=$?
umount /tmp/mount$$ 2>/dev/null
rm -rf /tmp/mount$$ /tmp/test$$ 2>/dev/null
if  [ $rv -eq 0 ]; then
  echo yes
else
  echo no
  fatal=$(($fatal + 1))
fi

echo -n "docker access ............................ "
docker ps 2>/dev/null
if [ $? -eq 0 ]; then
  echo yes
else
  echo "no (optional)"
  warning=$(($warning + 1))
fi
echo ""

echo -n "lcpu affinity ............................ "
taskset -cp $$|cut -d: -f2

echo ""
lscpu|grep NUMA
echo ""

if [ $warning -gt 0 ]; then
  echo "$warning optional features missing. Ignored"
fi
if [ $fatal -gt 0 ]; then
  echo "$fatal failed system dependencies. Terminating"
  exit 1
fi

echo "system dependencies ok"
