#!/bin/bash

#
# Run the OpenVPN server normally
#

echo "Starting OpenVPN container"
set -e

mkdir -p /dev/net
if [ ! -c /dev/net/tun ]; then
    mknod /dev/net/tun c 10 200
fi

if [ ! -d "/etc/openvpn/ccd" ]; then
    mkdir -p /etc/openvpn/ccd
fi

echo "Configurating NAT rules"
iptables -t filter -A FORWARD -s 192.168.255.0/24 -i tun0 -o eth0 -m state --state NEW -j ACCEPT
iptables -t filter -A FORWARD -d 192.168.255.0/24 -i eth0 -o tun0 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -t nat -A POSTROUTING -s 192.168.255.0/24 -o eth0 -j MASQUERADE

# Setup NAT forwarding if requested
#if [ "$OVPN_DEFROUTE" != "0" ] || [ "$OVPN_NAT" == "1" ] ; then
#    iptables -t nat -C POSTROUTING -s 192.168.255.0/24 -o eth0 -j MASQUERADE || {
#      iptables -t nat -A POSTROUTING -s 192.168.255.0/24 -o eth0 -j MASQUERADE
#    }
#    for i in "${OVPN_ROUTES[@]}"; do
#        iptables -t nat -C POSTROUTING -s "$i" -o eth0 -j MASQUERADE || {
#          iptables -t nat -A POSTROUTING -s "$i" -o eth0 -j MASQUERADE
#        }
#    done
#fi

#conf="$OPENVPN/openvpn.conf"

echo "Starting OpenVPN server"
exec openvpn --config /etc/openvpn/server.conf
