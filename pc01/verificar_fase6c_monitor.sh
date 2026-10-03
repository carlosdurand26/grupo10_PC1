#!/bin/sh
set -u
for cpe in cpe-isp1 cpe-isp2; do
  echo "===== $cpe | MONITOR ====="
  sudo docker exec "clab-pc01-$cpe" sh -c '
    echo "Estado: $(cat /tmp/pc1-wan-monitor.status 2>/dev/null || echo NO_INICIADO)"
    echo "Ultimos eventos:"
    tail -n 5 /tmp/pc1-wan-monitor.log 2>/dev/null || true
    echo "Estado VRRP:"
    vtysh -c "show vrrp" | grep -E "Status \(v4\)|Status \(v6\)|Shutdown" || true
  '
done
