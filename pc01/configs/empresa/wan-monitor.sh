#!/bin/sh
set -eu

TARGET="${1:?Especificar loopback IPv4 del PE}"

case "$TARGET" in
    172.16.1.1) IPV6_GATEWAY="fd10:100:50::" ;;
    10.200.1.1) IPV6_GATEWAY="fd20:200:50::" ;;
    *) echo "Objetivo WAN desconocido: $TARGET" >&2; exit 1 ;;
esac

FAIL_LIMIT=3
RECOVER_LIMIT=2
INTERVAL=2
FAILS=0
OKS=0
STATE=unknown
STATUS=/tmp/pc1-wan-monitor.status

log() {
    printf '%s [wan-monitor %s] %s\n' "$(date '+%H:%M:%S')" "$TARGET" "$*"
}

set_vrrp() {
    action="$1"
    if vtysh -c 'configure terminal' -c 'interface eth2' -c "${action}" >/tmp/pc1-wan-monitor-vtysh.log 2>&1; then
        log "VRRP aplicado: ${action}"
        return 0
    fi
    log "ERROR aplicando VRRP (${action}): $(cat /tmp/pc1-wan-monitor-vtysh.log)"
    return 1
}

restore_ipv6_route() {
    if ip -6 route replace default via "$IPV6_GATEWAY" dev eth1 metric 100 onlink >/tmp/pc1-wan-monitor-ipv6.log 2>&1; then
        log "Ruta IPv6 restaurada: default via $IPV6_GATEWAY dev eth1"
        return 0
    fi
    log "ERROR restaurando ruta IPv6: $(cat /tmp/pc1-wan-monitor-ipv6.log)"
    return 1
}

log "Iniciado: objetivo=$TARGET, intervalo=${INTERVAL}s, perdida=$FAIL_LIMIT, recuperacion=$RECOVER_LIMIT"
printf 'UNKNOWN\n' > "$STATUS"

while :; do
    if ping -4 -n -I eth1 -c 1 -W 1 "$TARGET" >/dev/null 2>&1; then
        FAILS=0
        OKS=$((OKS + 1))
        if [ "$OKS" -ge "$RECOVER_LIMIT" ] && [ "$STATE" != up ]; then
            if restore_ipv6_route && set_vrrp 'no vrrp 50 shutdown'; then
                STATE=up
                printf 'WAN_UP: VRRP habilitado\n' > "$STATUS"
            fi
        fi
    else
        OKS=0
        FAILS=$((FAILS + 1))
        if [ "$FAILS" -ge "$FAIL_LIMIT" ] && [ "$STATE" != down ]; then
            if set_vrrp 'vrrp 50 shutdown'; then
                STATE=down
                printf 'WAN_DOWN: VRRP deshabilitado\n' > "$STATUS"
            fi
        fi
    fi
    sleep "$INTERVAL"
done
