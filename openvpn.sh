#!/bin/sh /etc/rc.common

START=99

. /etc/profile

install() {  
  local OVPNPATH=/tmp/openvpn
  local OSSLPATH=/tmp/libopenssl
  [ ! -d ${OVPNPATH} ] && mkdir ${OVPNPATH}
  [ ! -d ${OSSLPATH} ] && mkdir ${OSSLPATH}
  command opkg update || exit 1
  # install openvpn
  cd ${OVPNPATH}
  tar xzf $(opkg download openvpn-openssl |grep Downloaded |cut -d\  -f4 |sed '$s/.$//')
  tar xzf data.tar.gz
  # delete unnecessary things (save space)
  rm -f pkg.tar.gz data.tar.gz control.tar.gz debian-binary getopenvpn.sh
  # install libopenssl
  cd ${OSSLPATH}
  tar xzf $(opkg download libopenssl |grep Downloaded |cut -d\  -f4 |sed '$s/.$//')
  tar xzf data.tar.gz
  # delete unnecessary things (save space)
  rm -f control.tar.gz debian-binary data.tar.gz
}

start () {  
  # lvl 99 is not enough the script is too
  sleep 10 # fast for the install step
  install # setup openvpn and libssl
  command openvpn --writepid /tmp/openvpn/ovpn.pid --daemon --config /etc/openvpn/client.conf
}

stop() {  
  PIDOF=$(ps |egrep openvpn |egrep  -v grep |awk '{print $1}')
  kill ${PIDOF}
}
