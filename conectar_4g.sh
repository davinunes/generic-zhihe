#!/bin/sh
# Script de Despertar UFI 3.0 - Híbrido e Resiliente

APN="zap.vivo.com.br"
DEV="/dev/wwan0qmi0"
INT="wwan0"

conectar() {
    echo "[*] Limpando vestígios..."
    sudo killall -9 qmicli 2>/dev/null
    sudo ip addr flush dev $INT 2>/dev/null
    sudo ip link set $INT down
    sudo qmicli -d $DEV --wda-set-data-format=raw-ip
    sudo ip link set $INT up
    sleep 2

    echo "[*] Tentando conexão Dual Stack (IPv4v6)..."
    # Tenta 4v6 primeiro
    OUT=$(sudo qmicli -d $DEV --device-open-net='net-raw-ip|net-no-qos-header' --wds-start-network="apn='$APN',ip-type=4v6" --wds-follow-network > /tmp/qmi_log 2>&1 &)
    sleep 8

    # Verifica se a Vivo rejeitou o v4
    if grep -q "pdn-ipv4-call-disallowed\|ipv6-only-allowed" /tmp/qmi_log; then
        echo "[!] IPv4 recusado pela operadora. Mudando para IPv6-only..."
        sudo killall -9 qmicli 2>/dev/null
        sudo qmicli -d $DEV --device-open-net='net-raw-ip|net-no-qos-header' --wds-start-network="apn='$APN',ip-type=6" --wds-follow-network > /tmp/qmi_log 2>&1 &
        sleep 8
    fi

    SETTINGS=$(sudo qmicli -d $DEV --wds-get-current-settings)
    
    # Configura IPv6
    IP6=$(echo "$SETTINGS" | grep "IPv6 address" | awk '{print $3}' | cut -d'/' -f1)
    GW6=$(echo "$SETTINGS" | grep "IPv6 gateway" | awk '{print $4}' | cut -d'/' -f1)
    if [ ! -z "$IP6" ]; then
        sudo ip -6 addr add $IP6/64 dev $INT
        sudo ip -6 route add default via $GW6 dev $INT metric 100
        echo "[+] IPv6 configurado: $IP6"
    fi

    # Configura IPv4 (se a Vivo permitir)
    IP4=$(echo "$SETTINGS" | grep "IP address" | grep -v "IPv6" | awk '{print $3}')
    if [ ! -z "$IP4" ]; then
        sudo ip addr add $IP4/30 dev $INT
        sudo ip route add default dev $INT metric 200
        echo "[+] IPv4 configurado: $IP4"
    fi
}

# LOOP DE RESILIÊNCIA (Watchdog)
while true; do
    # Testa se o Google responde via interface 4G
    if ! ping6 -c 2 -I $INT 2001:4860:4860::8888 > /dev/null 2>&1; then
        echo "[!] Conexão caiu ou não iniciada. Reconectando..."
        conectar
    fi
    sleep 30 # Verifica a cada 30 segundos
done
