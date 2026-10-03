#!/bin/sh
# NAT44 SOLO para la red empresarial y SOLO por el enlace WAN eth1.
# Se ejecuta automaticamente al desplegar el lab. No toca eth0 de gestion.
set -eu
command -v nft >/dev/null 2>&1 || { echo 'ERROR: nft no instalado en CPE' >&2; exit 1; }

# Idempotente ante una posible reejecucion manual.
if nft list table ip pc1_nat >/dev/null 2>&1; then
    nft delete table ip pc1_nat
fi
nft -f - <<'NFT'
table ip pc1_nat {
    chain postrouting {
        type nat hook postrouting priority srcnat; policy accept;
        oifname "eth1" ip saddr 192.168.50.0/24 counter masquerade
    }
}
NFT
# Verificar instalacion; fallar durante el deploy si el kernel rechaza NAT.
nft list chain ip pc1_nat postrouting >/dev/null
