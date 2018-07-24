#!/bin/bash
# Copyright (c) 2018, Juniper Networks, Inc.
# All rights reserved.
#
SALT=$(pwgen 8 1)
HASH=$(openssl passwd -1 -salt $SALT $rootpassword)

if [ -z "$PUBLICKEY" ]; then
  PUBLICKEY=$(cd /u && ls id_*.pub | tail -1)
fi

if [ ! -f "/u/$PUBLICKEY" ]; then
  >&2 echo "WARNING: Can't read ssh public key file $PUBLICKEY. Creating user 'lab' with same root password"
  SSHUSER="lab"
else
  SSHUSER=$(cat /u/$PUBLICKEY | cut -d' ' -f3 | cut -d'@' -f1)
  SSHPUBLIC="ssh-rsa \"$(cat /u/$PUBLICKEY)\""
fi

mygw=$(ip -4 route list 0/0 |cut -d' ' -f3)
if [ ! -z "$mygw" ]; then
   ip4gw="route 0.0.0.0/0 next-hop $mygw"
fi
if [ -z "$myip" ]; then
  ip4cfg=""
else
  ip4cfg="family inet { address $myip; }"
fi
if [ -z "$myip6" ]; then
  ip6cfg=""
else
  ip6cfg="family inet6 { address $myip6mask; }"
fi

cat <<EOF
groups {
  openjnpr-container-vmx {
    system {
      host-name $hostname;
      root-authentication {
        encrypted-password "$HASH";
        $SSHPUBLIC;
      }
      login {
        user $SSHUSER {
          class super-user;
          authentication {
            encrypted-password "$HASH";
            $SSHPUBLIC;
          }
        }
      }
      configuration-database {
        ephemeral {
          instance openjnpr-container-vmx-vfp0;
        }
      }
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
          $ip4cfg;
          $ip6cfg;
        }
      }
    }
    routing-options {
      static {
        $ip4gw;
      }
    }
  }
}
EOF
