#!/bin/sh
# Pruebas iniciales sin modificar los contenedores.
set -u
C=clab-pc01-cliente-empresa
printf '===== CLIENTE Y DIRECCIONES =====\n'
sudo docker exec "$C" ip -br addr show eth1 || exit 1
printf '\n===== RUTAS DEL CLIENTE =====\n'
sudo docker exec "$C" ip -4 route get 198.51.100.2 || exit 1
sudo docker exec "$C" ip -6 route get 2001:db8:100:50::2 || true
printf '\n===== IPv4 GATEWAY VRRP =====\n'
sudo docker exec "$C" ping -4 -c 2 -W 2 192.168.50.1 || true
printf '\n===== HTTP IPv4 DE EXTREMO A EXTREMO =====\n'
sudo docker exec "$C" curl --noproxy '*' -4 -sS -o /dev/null --max-time 8 -w 'HTTP IPv4: %{http_code}\n' http://198.51.100.2/ || true
printf '\n===== HTTP IPv6 (aun por validar rutas de retorno) =====\n'
sudo docker exec "$C" curl --noproxy '*' -6 -sS -o /dev/null --max-time 8 -w 'HTTP IPv6: %{http_code}\n' 'http://[2001:db8:100:50::2]/' || true
printf '\n===== PUBLICACION LOCAL DE GUI =====\n'
sudo docker port "$C" 5800/tcp || true
printf '\n===== VRRP ACTUAL =====\n'
for name in cpe-isp1 cpe-isp2; do
  echo "$name"
  sudo docker exec "clab-pc01-$name" vtysh -c 'show vrrp' | grep -E 'Status \(v4\)|Status \(v6\)' || true
done
