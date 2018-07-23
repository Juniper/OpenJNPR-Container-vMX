# regression testing

The purpose of the [docker-compose.yml](docker-compose.yml) file is to test the successful launch of different vMX versions. The script [check.sh](check.sh) monitors the progress of all launched vMX instances until all of them report operational FPC status (via CLI command 'show chassis fpc') or report FAILURE if it takes more than 10 minutes to complete.

New Junos vMX versions can be added to the [docker-compose.yml](docker-compose.yml) file, together with a unique Junos configuration file. 

Before launching the regression test, make sure the compute host has enough Hugepages configured (1GB per vMX instance). The required Junos vMX versions can be found via grep:

```
$ grep qcow2 regression/docker-compose.yml
      - IMAGE=junos-vmx-x86-64-18.2R1.9.qcow2
      - IMAGE=junos-vmx-x86-64-18.1R1.9.qcow2
      - IMAGE=junos-vmx-x86-64-17.4R1.16.qcow2
      - IMAGE=junos-vmx-x86-64-17.3R2.10.qcow2
      - IMAGE=junos-vmx-x86-64-17.3R1.10.qcow2
      - IMAGE=junos-vmx-x86-64-18.1R2.5.qcow2
```

Then launch the regression test from the main repository directory, where the vMX qcow2 images are located:

```
$ pwd
/home/lab/OpenJNPR-Container-vMX
$ make regress
docker-compose -f regression/docker-compose.yml up -d
Creating network "regression_net-c" with the default driver
Creating network "regression_net-b" with the default driver
Creating network "regression_net-a" with the default driver
Creating network "regression_mgmt" with the default driver
Creating regression_vmx3_1 ... done
Creating regression_vmx2_1 ... done
Creating regression_vmx1_1 ... done
Creating regression_vmx6_1 ... done
Creating regression_vmx5_1 ... done
Creating regression_vmx4_1 ... done
regression/check.sh
wait for fpc0 up in 6 instances (0 seconds)...
vMX regression_vmx4_1 (172.21.0.5) 17.3R2.10 ...
vMX regression_vmx6_1 (172.21.0.3) 18.1R2.5 ...
vMX regression_vmx1_1 (172.21.0.7) 18.2R1.9 ...
vMX regression_vmx3_1 (172.21.0.6) 17.4R1.16 ...
vMX regression_vmx2_1 (172.21.0.4) 18.1R1.9 ...
vMX regression_vmx5_1 (172.21.0.2) 17.3R1.10 ...
wait for fpc0 up in 6 instances (22 seconds)...
vMX regression_vmx4_1 (172.21.0.5) 17.3R2.10 ...
vMX regression_vmx6_1 (172.21.0.3) 18.1R2.5 ...
vMX regression_vmx1_1 (172.21.0.7) 18.2R1.9 ...
vMX regression_vmx3_1 (172.21.0.6) 17.4R1.16 ...
vMX regression_vmx2_1 (172.21.0.4) 18.1R1.9 ...
vMX regression_vmx5_1 (172.21.0.2) 17.3R1.10 ...
wait for fpc0 up in 6 instances (45 seconds)...
vMX regression_vmx4_1 (172.21.0.5) 17.3R2.10 ...
vMX regression_vmx6_1 (172.21.0.3) 18.1R2.5 ...
vMX regression_vmx1_1 (172.21.0.7) 18.2R1.9 ...
vMX regression_vmx3_1 (172.21.0.6) 17.4R1.16 ...
vMX regression_vmx2_1 (172.21.0.4) 18.1R1.9 ...
vMX regression_vmx5_1 (172.21.0.2) 17.3R1.10 ...
wait for fpc0 up in 6 instances (68 seconds)...
vMX regression_vmx4_1 (172.21.0.5) 17.3R2.10 ...
vMX regression_vmx6_1 (172.21.0.3) 18.1R2.5 ...
vMX regression_vmx1_1 (172.21.0.7) 18.2R1.9 ...
vMX regression_vmx3_1 (172.21.0.6) 17.4R1.16 ...
vMX regression_vmx2_1 (172.21.0.4) 18.1R1.9 ...
vMX regression_vmx5_1 (172.21.0.2) 17.3R1.10 ...
wait for fpc0 up in 6 instances (91 seconds)...
vMX regression_vmx4_1 (172.21.0.5) 17.3R2.10 ...
vMX regression_vmx6_1 (172.21.0.3) 18.1R2.5 ...
vMX regression_vmx1_1 (172.21.0.7) 18.2R1.9 ...
vMX regression_vmx3_1 (172.21.0.6) 17.4R1.16 ...
vMX regression_vmx2_1 (172.21.0.4) 18.1R1.9 ...
vMX regression_vmx5_1 (172.21.0.2) 17.3R1.10 ...
wait for fpc0 up in 6 instances (114 seconds)...
vMX regression_vmx4_1 (172.21.0.5) 17.3R2.10 ...
vMX regression_vmx6_1 (172.21.0.3) 18.1R2.5 ...
vMX regression_vmx1_1 (172.21.0.7) 18.2R1.9 ...
vMX regression_vmx3_1 (172.21.0.6) 17.4R1.16 ...
vMX regression_vmx2_1 (172.21.0.4) 18.1R1.9 ...
vMX regression_vmx5_1 (172.21.0.2) 17.3R1.10 ...
wait for fpc0 up in 6 instances (137 seconds)...
vMX regression_vmx4_1 (172.21.0.5) 17.3R2.10 ...
vMX regression_vmx6_1 (172.21.0.3) 18.1R2.5 ...
vMX regression_vmx1_1 (172.21.0.7) 18.2R1.9 ...
vMX regression_vmx3_1 (172.21.0.6) 17.4R1.16 ...
vMX regression_vmx2_1 (172.21.0.4) 18.1R1.9 ...
vMX regression_vmx5_1 (172.21.0.2) 17.3R1.10 ...
wait for fpc0 up in 6 instances (156 seconds)...
vMX regression_vmx4_1 (172.21.0.5) 17.3R2.10 ...
vMX regression_vmx6_1 (172.21.0.3) 18.1R2.5 ...
vMX regression_vmx1_1 (172.21.0.7) 18.2R1.9 ...
vMX regression_vmx3_1 (172.21.0.6) 17.4R1.16 ...
vMX regression_vmx2_1 (172.21.0.4) 18.1R1.9 ...
vMX regression_vmx5_1 (172.21.0.2) 17.3R1.10 ...
wait for fpc0 up in 6 instances (179 seconds)...
vMX regression_vmx4_1 (172.21.0.5) 17.3R2.10 ...
vMX regression_vmx6_1 (172.21.0.3) 18.1R2.5 ...
vMX regression_vmx1_1 (172.21.0.7) 18.2R1.9 ...
vMX regression_vmx3_1 (172.21.0.6) 17.4R1.16 ...
vMX regression_vmx2_1 (172.21.0.4) 18.1R1.9 ...
vMX regression_vmx5_1 (172.21.0.2) 17.3R1.10 ...
wait for fpc0 up in 6 instances (209 seconds)...
vMX regression_vmx4_1 (172.21.0.5) 17.3R2.10 ...
vMX regression_vmx6_1 (172.21.0.3) 18.1R2.5 ...
vMX regression_vmx1_1 (172.21.0.7) 18.2R1.9 ...
vMX regression_vmx3_1 (172.21.0.6) 17.4R1.16 ...
vMX regression_vmx2_1 (172.21.0.4) 18.1R1.9 fpc0 up
vMX regression_vmx5_1 (172.21.0.2) 17.3R1.10 ...
wait for fpc0 up in 6 instances (242 seconds)...
vMX regression_vmx4_1 (172.21.0.5) 17.3R2.10 ...
vMX regression_vmx6_1 (172.21.0.3) 18.1R2.5 ...
vMX regression_vmx1_1 (172.21.0.7) 18.2R1.9 ...
vMX regression_vmx3_1 (172.21.0.6) 17.4R1.16 ...
vMX regression_vmx2_1 (172.21.0.4) 18.1R1.9 fpc0 up
vMX regression_vmx5_1 (172.21.0.2) 17.3R1.10 fpc0 up
wait for fpc0 up in 6 instances (255 seconds)...
vMX regression_vmx4_1 (172.21.0.5) 17.3R2.10 ...
vMX regression_vmx6_1 (172.21.0.3) 18.1R2.5 ...
vMX regression_vmx1_1 (172.21.0.7) 18.2R1.9 fpc0 up
vMX regression_vmx3_1 (172.21.0.6) 17.4R1.16 ...
vMX regression_vmx2_1 (172.21.0.4) 18.1R1.9 fpc0 up
vMX regression_vmx5_1 (172.21.0.2) 17.3R1.10 fpc0 up
wait for fpc0 up in 6 instances (268 seconds)...
vMX regression_vmx4_1 (172.21.0.5) 17.3R2.10 ...
vMX regression_vmx6_1 (172.21.0.3) 18.1R2.5 fpc0 up
vMX regression_vmx1_1 (172.21.0.7) 18.2R1.9 fpc0 up
vMX regression_vmx3_1 (172.21.0.6) 17.4R1.16 ...
vMX regression_vmx2_1 (172.21.0.4) 18.1R1.9 fpc0 up
vMX regression_vmx5_1 (172.21.0.2) 17.3R1.10 fpc0 up
wait for fpc0 up in 6 instances (281 seconds)...
vMX regression_vmx4_1 (172.21.0.5) 17.3R2.10 fpc0 up
vMX regression_vmx6_1 (172.21.0.3) 18.1R2.5 fpc0 up
vMX regression_vmx1_1 (172.21.0.7) 18.2R1.9 fpc0 up
vMX regression_vmx3_1 (172.21.0.6) 17.4R1.16 ...
vMX regression_vmx2_1 (172.21.0.4) 18.1R1.9 fpc0 up
vMX regression_vmx5_1 (172.21.0.2) 17.3R1.10 fpc0 up
wait for fpc0 up in 6 instances (318 seconds)...
vMX regression_vmx4_1 (172.21.0.5) 17.3R2.10 fpc0 up
vMX regression_vmx6_1 (172.21.0.3) 18.1R2.5 fpc0 up
vMX regression_vmx1_1 (172.21.0.7) 18.2R1.9 fpc0 up
vMX regression_vmx3_1 (172.21.0.6) 17.4R1.16 fpc0 up
vMX regression_vmx2_1 (172.21.0.4) 18.1R1.9 fpc0 up
vMX regression_vmx5_1 (172.21.0.2) 17.3R1.10 fpc0 up
6 instances up in 321 seconds
SUCCESS
```
The vMX instances are up and running and ready for manual inspection. The Junos configuration files assign unique IPv4 and link local IPv6 addresses to each interface and OSPF and neighbor-discovery enabled. To find out the management IP address of each instance, use:

```
$ pwd
/home/lab/OpenJNPR-Container-vMX
$ make ps
docker-compose ps
Name   Command   State   Ports
------------------------------
docker-compose -f regression/docker-compose.yml ps
      Name           Command     State                       Ports
--------------------------------------------------------------------------------------
regression_vmx1_1   /launch.sh   Up      0.0.0.0:32862->22/tcp, 0.0.0.0:32861->830/tcp
regression_vmx2_1   /launch.sh   Up      0.0.0.0:32868->22/tcp, 0.0.0.0:32867->830/tcp
regression_vmx3_1   /launch.sh   Up      0.0.0.0:32860->22/tcp, 0.0.0.0:32858->830/tcp
regression_vmx4_1   /launch.sh   Up      0.0.0.0:32866->22/tcp, 0.0.0.0:32865->830/tcp
regression_vmx5_1   /launch.sh   Up      0.0.0.0:32873->22/tcp, 0.0.0.0:32872->830/tcp
regression_vmx6_1   /launch.sh   Up      0.0.0.0:32870->22/tcp, 0.0.0.0:32869->830/tcp
./getpass.sh
vMX regression_vmx4_1 (172.21.0.4) 17.3R2.10 biewiphierieyiewogoojeil 	 ready
vMX regression_vmx1_1 (172.21.0.3) 18.2R1.9 foh0yei5yeDaiHoo8xaf0eiv 	 ready
vMX regression_vmx6_1 (172.21.0.6) 18.1R2.5 zaeraifeizisiegechohnahy 	 ready
vMX regression_vmx5_1 (172.21.0.7) 17.3R1.10 elaekieguisoocohpuvocapa 	 ready
vMX regression_vmx3_1 (172.21.0.2) 17.4R1.16 gaejionohneimeechaegheye 	 ready
vMX regression_vmx2_1 (172.21.0.5) 18.1R1.9 cohxeeyiephohshahzuupoon 	 ready
```

Use 'docker stats' to get interactive resource statistics about all running instances:

```
$ docker stats

CONTAINER ID        NAME                CPU %               MEM USAGE / LIMIT     MEM %               NET I/O             BLOCK I/O           PIDS

20342bccd6ca        regression_vmx4_1   24.85%              1.135GiB / 62.71GiB   1.81%               402kB / 91.8kB      112kB / 36MB        30

e24ebc6bcdf7        regression_vmx5_1   23.69%              1.232GiB / 62.71GiB   1.96%               404kB / 114kB       95.2kB / 181MB      30

abb6d5959fb0        regression_vmx1_1   25.00%              1.163GiB / 62.71GiB   1.85%               419kB / 151kB       389kB / 40.7MB      31

02a5aad9cfe2        regression_vmx2_1   27.47%              1.136GiB / 62.71GiB   1.81%               389kB / 108kB       136kB / 41.8MB      29

983f235d08d8        regression_vmx3_1   19.23%              1.135GiB / 62.71GiB   1.81%               398kB / 98.9kB      133kB / 181MB       29

0262d8206aaf        regression_vmx6_1   24.88%              1.136GiB / 62.71GiB   1.81%               396kB / 124kB       78.8kB / 187MB      30

^C
```


Log into any of the instances and check OSPF and IPv6 neighbors:

```
$ ssh 172.21.0.5
The authenticity of host '172.21.0.5 (172.21.0.5)' can't be established.
ECDSA key fingerprint is SHA256:Jux4ApuGUDdjSBNUtQI49/AartGnz7X8/Avq+Nd/xMo.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added '172.21.0.5' (ECDSA) to the list of known hosts.
--- JUNOS 18.1R1.9 Kernel 64-bit  JNPR-11.0-20180308.0604c57_buil
lab@regression_vmx2_1> show chassis fpc
                     Temp  CPU Utilization (%)   CPU Utilization (%)  Memory    Utilization (%)
Slot State            (C)  Total  Interrupt      1min   5min   15min  DRAM (MB) Heap     Buffer
  0  Online           Testing   8         0        8      8      8    2047        7          0
  1  Empty
  2  Empty
  3  Empty
  4  Empty
  5  Empty
  6  Empty
  7  Empty
  8  Empty
  9  Empty
 10  Empty
 11  Empty

lab@regression_vmx2_1> show ipv6 neighbors
IPv6 Address                 Linklayer Address  State       Exp Rtr Secure Interface
fe80::242:acff:fe12:3        02:42:ac:12:00:03  stale       944 yes no      ge-0/0/2.0
fe80::242:acff:fe12:4        02:42:ac:12:00:04  stale       1036 yes no     ge-0/0/2.0
fe80::242:acff:fe12:5        02:42:ac:12:00:05  stale       954 yes no      ge-0/0/2.0
fe80::242:acff:fe12:6        02:42:ac:12:00:06  stale       968 yes no      ge-0/0/2.0
fe80::242:acff:fe12:7        02:42:ac:12:00:07  stale       973 yes no      ge-0/0/2.0
fe80::242:acff:fe13:3        02:42:ac:13:00:03  stale       999 yes no      ge-0/0/1.0
fe80::242:acff:fe13:4        02:42:ac:13:00:04  stale       962 yes no      ge-0/0/1.0
fe80::242:acff:fe13:5        02:42:ac:13:00:05  stale       938 yes no      ge-0/0/1.0
fe80::242:acff:fe13:6        02:42:ac:13:00:06  stale       957 yes no      ge-0/0/1.0
fe80::242:acff:fe13:7        02:42:ac:13:00:07  stale       986 yes no      ge-0/0/1.0
fe80::242:acff:fe14:3        02:42:ac:14:00:03  stale       1006 yes no     ge-0/0/0.0
fe80::242:acff:fe14:5        02:42:ac:14:00:05  stale       941 yes no      ge-0/0/0.0
fe80::242:acff:fe14:7        02:42:ac:14:00:07  stale       963 yes no      ge-0/0/0.0

lab@regression_vmx2_1> show ospf neighbor
Address          Interface              State     ID               Pri  Dead
10.0.1.13        ge-0/0/0.0             Full      10.0.0.13        128    37
10.0.1.16        ge-0/0/0.0             Full      10.0.0.16        128    39
10.0.1.11        ge-0/0/0.0             Full      10.0.0.11        128    36
10.0.2.13        ge-0/0/1.0             Full      10.0.0.13        128    37
10.0.2.16        ge-0/0/1.0             Full      10.0.0.16        128    36
10.0.2.11        ge-0/0/1.0             Full      10.0.0.11        128    39
10.0.3.13        ge-0/0/2.0             Full      10.0.0.13        128    35
10.0.3.16        ge-0/0/2.0             Full      10.0.0.16        128    39
10.0.3.11        ge-0/0/2.0             Full      10.0.0.11        128    39

```



To terminate the instances, use 'make down', which launches 'docker-compose -f regression/docker-compose.yml down':

```
$ pwd
/home/lab/OpenJNPR-Container-vMX
$ make down
docker-compose down
Removing network openjnprcontainervmx_net-c
WARNING: Network openjnprcontainervmx_net-c not found.
Removing network openjnprcontainervmx_net-b
WARNING: Network openjnprcontainervmx_net-b not found.
Removing network openjnprcontainervmx_net-a
WARNING: Network openjnprcontainervmx_net-a not found.
Removing network openjnprcontainervmx_mgmt
WARNING: Network openjnprcontainervmx_mgmt not found.
docker-compose -f regression/docker-compose.yml down
Stopping regression_vmx4_1 ... done
Stopping regression_vmx1_1 ... done
Stopping regression_vmx6_1 ... done
Stopping regression_vmx5_1 ... done
Stopping regression_vmx3_1 ... done
Stopping regression_vmx2_1 ... done
Removing regression_vmx4_1 ... done
Removing regression_vmx1_1 ... done
Removing regression_vmx6_1 ... done
Removing regression_vmx5_1 ... done
Removing regression_vmx3_1 ... done
Removing regression_vmx2_1 ... done
Removing network regression_net-c
Removing network regression_net-b
Removing network regression_net-a
Removing network regression_mgmt
```

