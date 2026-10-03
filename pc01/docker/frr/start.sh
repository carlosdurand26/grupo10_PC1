#!/bin/bash

set -e

echo "=============================================="
echo " FRRouting"
echo " IPv4 + IPv6"
echo " OSPF + OSPFv3 + BGP + LDP"
echo "=============================================="


mkdir -p /run/sshd
mkdir -p /run/frr

chown -R frr:frr /run/frr
chown -R frr:frr /etc/frr


echo "[+] Starting SSH..."

ssh-keygen -A

/usr/sbin/sshd


echo "[+] Checking IPv6..."

if [ -f /proc/sys/net/ipv6/conf/all/disable_ipv6 ]; then
    echo 0 > /proc/sys/net/ipv6/conf/all/disable_ipv6 || true
fi

if [ -f /proc/sys/net/ipv6/conf/default/disable_ipv6 ]; then
    echo 0 > /proc/sys/net/ipv6/conf/default/disable_ipv6 || true
fi


echo "[+] Starting FRR..."

/usr/lib/frr/frrinit.sh start


echo
echo "[+] Running FRR processes:"
ps aux | grep -E \
    'watchfrr|zebra|bgpd|ospfd|ospf6d|ldpd|staticd' \
    | grep -v grep || true

echo
echo "[+] IPv6 interfaces:"
ip -6 addr show

echo
echo "[+] Container ready"


exec tail -f /dev/null