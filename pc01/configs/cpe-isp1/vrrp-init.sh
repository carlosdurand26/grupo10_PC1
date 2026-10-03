#!/bin/sh
# VRRPv3, ID 50, IPv4 e IPv6. Se ejecuta al desplegar Containerlab.
# FRR requiere macvlan en modo bridge con las MAC virtuales del RFC 5798.
set -eu

# Evitar respuestas ARP por la VIP desde interfaces incorrectas.
sysctl -w net.ipv4.conf.all.arp_ignore=1
ip link show dev eth2 >/dev/null

# Dos macvlan separados: MAC VRRP IPv4 00:00:5e:00:01:32;
# MAC VRRP IPv6 00:00:5e:00:02:32. 0x32 = VRID 50.
if ! ip link show dev vrrp4-eth2-50 >/dev/null 2>&1; then
    ip link add link eth2 name vrrp4-eth2-50 type macvlan mode bridge
    ip link set dev vrrp4-eth2-50 addrgenmode random
fi
ip link set dev vrrp4-eth2-50 address 00:00:5e:00:01:32
ip -4 addr replace 192.168.50.1/24 dev vrrp4-eth2-50
ip link set dev vrrp4-eth2-50 up

if ! ip link show dev vrrp6-eth2-50 >/dev/null 2>&1; then
    ip link add link eth2 name vrrp6-eth2-50 type macvlan mode bridge
    ip link set dev vrrp6-eth2-50 addrgenmode random
fi
ip link set dev vrrp6-eth2-50 address 00:00:5e:00:02:32
ip -6 addr replace fd50:50::1/64 dev vrrp6-eth2-50
ip link set dev vrrp6-eth2-50 up
