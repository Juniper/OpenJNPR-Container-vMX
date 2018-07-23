# OpenJNPR-Container-vMX

[![](https://images.microbadger.com/badges/version/juniper/openjnpr-container-vmx:bionic.svg)](https://microbadger.com/images/juniper/openjnpr-container-vmx:bionic "Get your own version badge on microbadger.com") [![](https://images.microbadger.com/badges/image/juniper/openjnpr-container-vmx:bionic.svg)](https://microbadger.com/images/juniper/openjnpr-container-vmx:bionic "Get your own image badge on microbadger.com")

[![](https://images.microbadger.com/badges/version/juniper/openjnpr-container-vmx:trusty.svg)](https://microbadger.com/images/juniper/openjnpr-container-vmx:trusty "Get your own version badge on microbadger.com") [![](https://images.microbadger.com/badges/image/juniper/openjnpr-container-vmx:trusty.svg)](https://microbadger.com/images/juniper/openjnpr-container-vmx:trusty "Get your own image badge on microbadger.com")

https://hub.docker.com/r/juniper/openjnpr-container-vmx/


Docker container to launch Junos vMX 17.3 and newer versions on baremetal compute nodes. While the Junos control plane (VCP) runs on top of Qemu-kvm, the forwarding plane (VFP/RIOT) runs natively in the container:

```                                          
       +------------------------------+
       |  +-------------+             |
       |  |  Junos VCP  |             |
       |  |  qcow2 VM   |             |
       |  +-------------+             |
       |  +-------------+  +--------+ |
       |  | qemu-system |  |  riot  | |
       |  +-------------+  +--------+ |
       +------------------------------+
```

## Features

- vMX runs in light mode via attached container network interfaces
- Orchestration via docker-compose and manual launch via 'docker run'
- Container waits for networking interfaces to be attached to container
- Supports all Docker network plugins, including macvlan and overlays
- vMX VCP (Junos control plane) runs on top of qemu within the container
- Forwarding engine (riot) is downloaded from the VCP image at runtime and launched 
- vMX runs in light-mode (no SR-IOV support)
- Virtual network names are learned at runtime from Docker (via socket) and used to provision the interface description via ephemeral DB
- Management interface fxp0, root password and ssh public key for root and the user launching the container are learned at runtime and added to an Junos apply-group openjnpr-container-vmx
- If no Junos configuration file is provided, the apply-group openjnpr-container-vmx is used
- The virtual network list is sorted by network name at runtime (to work around the unpredictable order with docker-compose). This requires docker socket access from the container (provided via volume mount)
- Auto-installation of provided license keys
- Loading of optional Junos configuration file at startup 
- Auto-configuration of ssh and netconf
- Assigned IP address to container becomes the IP address of fxp0 
- Serial console and RIOT messages are available in the container console via [docker attach](https://docs.docker.com/engine/reference/commandline/attach/) and via [docker logs](https://docs.docker.com/engine/reference/commandline/logs/).

## Minimum Requirements

- Linux based compute node with a Linux kernel 4.4.0 and kvm hardware acceleration
- CPU must be of family Ivy Bridge or newer (released 2013)
- Container requires privileged mode (to access hugepages, required by riot)
- Memory hugepages provisioned (1GB per vMX)
- [Docker](https://www.docker.com/get-docker) 17.03 or newer (e.g. ubuntu package docker.io)
- [docker-compose](https://docs.docker.com/compose/) (e.g. ubuntu package docker-compose)
- junos-vmx-x86-64-17.3R1.10.qcow2 image, extracted from the vmx-bundle-*tgz file available at https://www.juniper.net/support/downloads/?p=vmx or as an eval download from https://www.juniper.net/us/en/dm/free-vmx-trial/ (registration required)

## Getting Started

### Required compute host packages

In order to build and launch the containers, the following packages must be installed. Example shown for ubuntu 18.04, adjust accordingly:

```
$ sudo apt-get update
$ sudo apt-get install make git docker.io docker-compose
```

### Clone this repo

```
$ pwd
/home/lab
$ git clone https://github.com/Juniper/OpenJNPR-Container-vMX.git
$ cd OpenJNPR-Container-vMX
```

### Download and extract Junos-vmx-x86-*.qcow2

Download and unpack the qcow2 image from a vmx-bundle-*.tgz file from  https://www.juniper.net/support/downloads/?p=vmx or as an eval download from https://www.juniper.net/us/en/dm/free-vmx-trial/ (registration required):

```
$ pwd
/home/lab/OpenJNPR-Container-vMX
tar zxf vmx-bundle-18.2R1.9.tgz
$ mv vmx/images/junos-vmx-x86-64-18.2R1.9.qcow2 .
$ rm -rf vmx
```

No other file is required from the bundle, hence it is ok to remove the extracted files. 

### Adjust docker-compose.yml

Adjust the environment variables IMAGE for vmx1 and vmx2 to match the qcow2 filename. 

If the junos version is 18.2R1 or newer, make sure to use the container image juniper/openjnpr-container-vmx:bionic. For any Junos version 18.1 and older, use the container image juniper/openjnpr-container-vmx:trusty.

If left unchanged, the compoe file expects junos-vmx-x86-64-18.2R1.9.qcow2 and junos-vmx-x86-64-18.1R1.9.qcow2 to be present in the current directory.

### Enable hugepages

Define at least 1024 x 2MB hugepages or 2 x 1GB hugepages via kernel options by adding 

```
GRUB_CMDLINE_LINUX_DEFAULT="default_hugepagesz=1G hugepagesz=1G hugepages=2"
```

or

```
GRUB_CMDLINE_LINUX_DEFAULT="hugepages=1024"
```

to the file /etc/default/grub, followed by running update-grub and reboot:

```
$ sudo update-grub
$ reboot
```

Once the system is back, check the availability of hugepages (the example shown has 16x1GB pages reserved):

```
$ cat /proc/meminfo |grep Huge
AnonHugePages:         0 kB
ShmemHugePages:        0 kB
HugePages_Total:      16
HugePages_Free:       16
HugePages_Rsvd:        0
HugePages_Surp:        0
Hugepagesize:    1048576 kB
```

### ssh public/private keypair

Create or check the presence of a ssh public/private, rsa based key pair, typically located in ~/.ssh/:

```
$ ls ~/.ssh/
authorized_keys  id_rsa  id_rsa.pub  known_hosts
```

The content of the id_rsa.pub file will automatically be used to create a login user within the Junos configuraiton file at runtime, allowing you to ssh into the vMX instance without password. 

To create a fresh keypair, use the following command and accept all defaults:

```
$ ssh-keygen -t rsa
```

### Build the container

This step is optional, as pre-built containers will automatically be downloaded from Docker Hub. To build the containers locally, use 'make build', then check the binary containers via 'docker images':

```
$ make build
...
Successfully tagged juniper/openjnpr-container-vmx:bionic
...
Successfully tagged juniper/openjnpr-container-vmx:trusty

$ docker images | head -3
REPOSITORY                                      TAG                                        IMAGE ID            CREATED             SIZE
juniper/openjnpr-container-vmx                  trusty                                     8436770a23eb        1 minute ago         597MB
juniper/openjnpr-container-vmx                  bionic                                     7a85db4edd94        1 minute ago         428MB
```

### Launch the containers

Time to launch the images. The vmx1 has a config file in the repo directory: [vmx1.conf](vmx.1conf), which only contains a single apply-group line. The group itself is auto-generated at runtime. vmx2 doesn't have a config file, hence the apply-group statement is auto-generated. This gives the user flexibility to use or not use the auto-generated configuration group.

```
$ make up
$ make up
docker-compose up -d
Creating network "openjnprcontainervmx_net-c" with the default driver
Creating network "openjnprcontainervmx_net-b" with the default driver
Creating network "openjnprcontainervmx_net-a" with the default driver
Creating network "openjnprcontainervmx_mgmt" with the default driver
Creating openjnprcontainervmx_vmx2_1 ... done
Creating openjnprcontainervmx_vmx1_1 ... done
```

If all went well, you should see 2 running containers via 'docker ps':

```
$ docker ps
CONTAINER ID        IMAGE                                   COMMAND             CREATED             STATUS              PORTS                                           NAMES
cdbb818b9afc        juniper/openjnpr-container-vmx:bionic   "/launch.sh"        35 seconds ago      Up 33 seconds       0.0.0.0:32913->22/tcp, 0.0.0.0:32912->830/tcp   openjnprcontainervmx_vmx1_1
749f148658d2        juniper/openjnpr-container-vmx:trusty   "/launch.sh"        35 seconds ago      Up 31 seconds       0.0.0.0:32915->22/tcp, 0.0.0.0:32914->830/tcp   openjnprcontainervmx_vmx2_1
```

If nothing is shown, then the containers likely terminated in error. Their logs are still available and provide details. The container names can be seen via 'docker ps -a' (show also terminated containers). Use 'docker logs <container>' to get more info's. the log shown here is from a healthy container:

```
$ docker logs openjnprcontainervmx_vmx1_1
Juniper Networks vMX Docker Light Container

Linux cdbb818b9afc 4.15.0-29-generic #31-Ubuntu SMP Tue Jul 17 15:39:52 UTC 2018 x86_64

CPU Model ................................ Intel(R) Core(TM) i7-7700 CPU @ 3.60GHz
CPU affinity of this container ........... 0-7
KVM hardware virtualization extension .... yes
Total System Memory ...................... 62 GB
Free Hugepages ........................... yes (16 x 1024 MB = 16384 MB)
Check for container privileged mode ...... yes
Check for sudo/root privileges ........... yes
Loop mount filesystem capability ......... yes
docker access ............................ CONTAINER ID        IMAGE                                   COMMAND             CREATED             STATUS                  PORTS                                           NAMES
cdbb818b9afc        juniper/openjnpr-container-vmx:bionic   "/launch.sh"        2 seconds ago       Up Less than a second   0.0.0.0:32913->22/tcp, 0.0.0.0:32912->830/tcp   openjnprcontainervmx_vmx1_1
yes

lcpu affinity ............................  0-7

NUMA node(s):        1
NUMA node0 CPU(s):   0-7

system dependencies ok
/u contains the following files:
LICENSE				  junos-vmx-x86-64-17.3R2.10.qcow2
Makefile			  junos-vmx-x86-64-17.4R1.16.qcow2
README.md			  junos-vmx-x86-64-18.1R1.9.qcow2
docker-compose.yml		  junos-vmx-x86-64-18.1R2.5.qcow2
down.sh				  junos-vmx-x86-64-18.2R1.9.qcow2
getpass.sh			  license-eval.txt
id_rsa.pub			  regression
junos-vmx-x86-64-16.1R7.7.qcow2   src
junos-vmx-x86-64-17.3R1.10.qcow2  vmx1.conf
/fix_network_order.sh: trying to fix network interface order via docker inspect myself ...
MACS=02:42:ac:15:00:02 02:42:ac:14:00:02 02:42:ac:13:00:03 02:42:ac:12:00:02
02:42:ac:15:00:02 eth0 == eth0
02:42:ac:14:00:02 eth1 == eth1
02:42:ac:13:00:03 eth3 -> eth2
FROM eth3 () TO eth2 ()
Actual changes:
tx-checksumming: off
	tx-checksum-ip-generic: off
	tx-checksum-sctp: off
tcp-segmentation-offload: off
	tx-tcp-segmentation: off [requested on]
	tx-tcp-ecn-segmentation: off [requested on]
	tx-tcp-mangleid-segmentation: off [requested on]
	tx-tcp6-segmentation: off [requested on]
Actual changes:
tx-checksumming: off
	tx-checksum-ip-generic: off
	tx-checksum-sctp: off
tcp-segmentation-offload: off
	tx-tcp-segmentation: off [requested on]
	tx-tcp-ecn-segmentation: off [requested on]
	tx-tcp-mangleid-segmentation: off [requested on]
	tx-tcp6-segmentation: off [requested on]
02:42:ac:12:00:02 eth3 == eth3
using qcow2 image junos-vmx-x86-64-18.2R1.9.qcow2
LICENSE=license-eval.txt
168: eth0@if169: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default
    link/ether 02:42:ac:15:00:02 brd ff:ff:ff:ff:ff:ff link-netnsid 0
Interface  IPv6 address
Bridging  (/02:42:ac:15:00:02) with fxp0
Current MAC:   02:42:ac:15:00:02 (unknown)
Permanent MAC: 00:00:00:00:00:00 (XEROX CORPORATION)
New MAC:       28:c7:18:8a:06:7e (Altierre)
-----------------------------------------------------------------------
vMX openjnprcontainervmx_vmx1_1 (172.21.0.2) 18.2R1.9 root password deica3ootiojohsha5Eethae
-----------------------------------------------------------------------

bridge name	bridge id		STP enabled	interfaces
br-ext		8000.28c7188a067e	no		eth0
							fxp0
br-int		8000.f6cb09cbc6c5	no		em1
Creating config drive /tmp/configdrive.qcow2
METADISK=/tmp/configdrive.qcow2 CONFIG=/tmp/vmx1.conf LICENSE=/u/license-eval.txt
Creating config drive (configdrive.img) ...
extracting licenses from /u/license-eval.txt
  writing license file config_drive/config/license/E435890758.lic ...
adding config file /tmp/vmx1.conf
-rw-r--r-- 1 root root 458752 Jul 23 11:31 /tmp/configdrive.qcow2
Creating empty /tmp/vmxhdd.img for VCP ...
Starting PFE ...
Booting VCP ...
Waiting for VCP to boot... Consoles: serial port
BIOS drive A: is disk0
BIOS drive C: is disk1
BIOS drive D: is disk2
BIOS drive E: is disk3
BIOS 639kB/1047424kB available memory

FreeBSD/x86 bootstrap loader, Revision 1.1
(builder@feyrith.juniper.net, Thu Jun 14 14:21:45 PDT 2018)
-

Booting from Junos volume ...
|
...
```

Use 'make ps' or ''./getpass.sh' to get the containers IP address and auto-generated root password (only required if the ssh id_rsa.pub key was missing):

```
./getpass.sh
vMX openjnprcontainervmx_vmx1_1 (172.21.0.2) 18.2R1.9 deica3ootiojohsha5Eethae 	 ...
vMX openjnprcontainervmx_vmx2_1 (172.21.0.3) 18.1R1.9 eihaekahpeetungeekeerohr 	 ...
```

The '...' at the end of each line indicate, that the vMX aren't fully operational yet. Repeat above step until it says 'ready':

```
$ ./getpass.sh
vMX openjnprcontainervmx_vmx1_1 (172.21.0.2) 18.2R1.9 deica3ootiojohsha5Eethae 	 ready
vMX openjnprcontainervmx_vmx2_1 (172.21.0.3) 18.1R1.9 eihaekahpeetungeekeerohr 	 ready
```

This takes typically less than 5 minutes.

Ready means the vMX is up and running and the forwarding engine is operational with interfaces attached. 

### log into the vMX

Use the IP address shown from the output of './getpass.sh' to log into the vMX:

```
$ ssh 172.21.0.2
The authenticity of host '172.21.0.2 (172.21.0.2)' can't be established.
ECDSA key fingerprint is SHA256:bMtOBbwBrgVcSGWc8FfNHj3Wwm029KBu/mByJWSCBp0.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added '172.21.0.2' (ECDSA) to the list of known hosts.
--- JUNOS 18.2R1.9 Kernel 64-bit  JNPR-11.0-20180614.6c3f819_buil
mwiget@openjnprcontainervmx_vmx1_1> show chassis fpc
                     Temp  CPU Utilization (%)   CPU Utilization (%)  Memory    Utilization (%)
Slot State            (C)  Total  Interrupt      1min   5min   15min  DRAM (MB) Heap     Buffer
  0  Online           Testing   4         0        3      1      0    2047        7          0
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

mwiget@openjnprcontainervmx_vmx1_1> show interfaces descriptions
Interface       Admin Link Description
ge-0/0/0        up    up   openjnprcontainervmx_net-a
ge-0/0/1        up    up   openjnprcontainervmx_net-b
ge-0/0/2        up    up   openjnprcontainervmx_net-c
fxp0            up    up   openjnprcontainervmx_mgmt
```

The interface descriptions are provided via ephemeral DB:

```
mwiget@openjnprcontainervmx_vmx1_1> show ephemeral-configuration instance openjnpr-container-vmx-vfp0
## Last changed: 2018-07-23 11:33:48 UTC
interfaces {
    ge-0/0/0 {
        description openjnprcontainervmx_net-a;
    }
    ge-0/0/1 {
        description openjnprcontainervmx_net-b;
    }
    ge-0/0/2 {
        description openjnprcontainervmx_net-c;
    }
    fxp0 {
        description openjnprcontainervmx_mgmt;
    }
}
```

The login and fxp0 configuration is provided via an apply-group. The actual passwords and keys are excluded from the output by omitting lines with the comment '## SECRET-DATA':

```
mwiget@openjnprcontainervmx_vmx1_1> show configuration groups openjnpr-container-vmx | except SECRET
system {
    configuration-database {
        ephemeral {
            instance openjnpr-container-vmx-vfp0;
        }
    }
    login {
        user mwiget {
            uid 2000;
            class super-user;
            authentication {
            }
        }
    }
    root-authentication {
    }
    host-name openjnprcontainervmx_vmx1_1;
    services {
        ssh {
            client-alive-interval 30;
        }
        netconf {
            ssh;
        }
    }
    syslog {
        file messages {
            any notice;
        }
    }
}
interfaces {
    fxp0 {
        unit 0 {
            family inet {
                address 172.21.0.2/16;
            }
        }
    }
}
routing-options {
    static {
        route 0.0.0.0/0 next-hop 172.21.0.1;
    }
}
```

### Terminate instances

```
$ make down
docker-compose down
Stopping openjnprcontainervmx_vmx1_1 ... done
Stopping openjnprcontainervmx_vmx2_1 ... done
Removing openjnprcontainervmx_vmx1_1 ... done
Removing openjnprcontainervmx_vmx2_1 ... done
Removing network openjnprcontainervmx_net-c
Removing network openjnprcontainervmx_net-b
Removing network openjnprcontainervmx_net-a
Removing network openjnprcontainervmx_mgmt
docker-compose -f regression/docker-compose.yml down
Removing network regression_net-c
WARNING: Network regression_net-c not found.
Removing network regression_net-b
WARNING: Network regression_net-b not found.
Removing network regression_net-a
WARNING: Network regression_net-a not found.
Removing network regression_mgmt
WARNING: Network regression_mgmt not found.
```

## Troubleshooting

### Amensia mode (no config loaded)

If the vMX end up in Amnesia, most likely the kernel doesn't have the loop module loaded yet. Haven't found a workaround yet to this, other than loading that module on the Docker host via

```
$ sudo modprobe loop
```

Based on your linux distribution, it is possible to make this change persistent by placing the word 'loop' in the file /etc/modules.

Stop the containers, e.g. with 'docker-compose down' or 'make down' and launch them again.

### No hugepages

Check if you have enough allocated hugepges left via

```
$ cat /proc/meminfo |grep Huge
AnonHugePages:         0 kB
ShmemHugePages:        0 kB
HugePages_Total:      16
HugePages_Free:       16
HugePages_Rsvd:        0
HugePages_Surp:        0
Hugepagesize:    1048576 kB
```

The actual amount in MB is Hugepagesize x HugePages_Free / 1024. In the example output that would be 16GB.

