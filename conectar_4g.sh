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
    sudo qmicli -d $DEV --device-open-net='net-raw-ip|net-no-qos-header' --wds-start-network="apn='$APN',ip-type=4v6" --wds-follow-network > /tmp/qmi_log 2>&1 &
    sleep 8

    if grep -q "pdn-ipv4-call-disallowed\|ipv6-only-allowed" /tmp/qmi_log; then
        echo "[!] IPv4 recusado. Mudando para IPv6-only..."
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

    # Configura IPv4 (se disponível)
    IP4=$(echo "$SETTINGS" | grep "IP address" | grep -v "IPv6" | awk '{print $3}')
    if [ ! -z "$IP4" ]; then
        sudo ip addr add $IP4/30 dev $INT
        sudo ip route add default dev $INT metric 200
        echo "[+] IPv4 configurado: $IP4"
    fi

    # --- A VACINA AGORA FICA AQUI ---
    echo "[*] Injetando DNS IPv6 para garantir a VPN..."
    echo -e "nameserver 2001:4860:4860::8888\nnameserver 2606:4700:4700::1111" | sudo tee /etc/resolv.conf > /dev/null

    echo "[*] Reiniciando o WireGuard para forçar nova resolução..."
    sudo systemctl restart wg-quick@wg0
}

# LOOP DE RESILIÊNCIA (Watchdog)
echo "[*] Iniciando Watchdog do Frankenstein..."
while true; do
    # Testa se o Google responde via interface 4G (IPv6)
    if ! ping6 -c 2 -I $INT 2001:4860:4860::8888 > /dev/null 2>&1; then
        echo "[!] Conexão caiu ou não iniciada. Reconectando..."
        conectar
    fi
    sleep 30
done
