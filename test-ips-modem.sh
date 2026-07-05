#!/bin/bash
# Script para testar se a Vivo permite múltiplos IPs IPv6 na WAN (wwan0)
# Uso: ./test-ips-modem.sh add   (para adicionar 50 IPs)
#      ./test-ips-modem.sh clean (para remover os 50 IPs)

INT="wwan0"

get_prefix() {
    SETTINGS=$(qmicli -p -d /dev/wwan0qmi0 --wds-get-current-settings 2>/dev/null)
    IP6=$(echo "$SETTINGS" | grep "IPv6 address" | awk '{print $3}' | cut -d'/' -f1)
    if [ -z "$IP6" ]; then
        # Tentar obter direto do comando ip addr
        IP6=$(ip -6 addr show dev $INT | grep "global" | awk '{print $2}' | cut -d'/' -f1 | head -n1)
    fi
    if [ -z "$IP6" ]; then
        echo "[!] Erro: Não foi possível obter o IP global da interface $INT."
        exit 1
    fi
    echo "$IP6" | cut -d: -f1-4
}

PREFIX=$(get_prefix)
if [ -z "$PREFIX" ]; then
    echo "[!] Falha ao extrair prefixo."
    exit 1
fi

echo "[+] Prefixo detectado: ${PREFIX}::/64"

case "${1:-}" in
    add)
        echo "[*] Adicionando 50 IPs de teste na interface $INT..."
        for i in $(seq 100 149); do
            HEX=$(printf '%x' $i)
            IP="${PREFIX}::${HEX}"
            echo "Adicionando: $IP"
            ip -6 addr add "$IP/128" dev $INT 2>/dev/null || true
        done
        echo "[+] Concluído! Copie a lista de IPs abaixo para testar o ping a partir de um servidor remoto:"
        echo "--------------------------------------------------"
        for i in $(seq 100 149); do
            HEX=$(printf '%x' $i)
            echo "${PREFIX}::${HEX}"
        done
        echo "--------------------------------------------------"
        echo "Para remover estes IPs após o teste, rode: ./test-ips-modem.sh clean"
        ;;
        
    clean)
        echo "[*] Removendo os 50 IPs de teste da interface $INT..."
        for i in $(seq 100 149); do
            HEX=$(printf '%x' $i)
            IP="${PREFIX}::${HEX}"
            echo "Removendo: $IP"
            ip -6 addr del "$IP/128" dev $INT 2>/dev/null || true
        done
        echo "[+] IPs removidos!"
        ;;
        
    *)
        echo "Uso: $0 [add|clean]"
        exit 1
        ;;
esac
