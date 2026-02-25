#!/bin/sh
# Script de Despertar UFI 2.0 - Simulando dois terminais

APN="zap.vivo.com.br"
DEV="/dev/wwan0qmi0"
INT="wwan0"

echo "[*] Limpando vestígios..."
sudo killall -9 qmicli 2>/dev/null
sudo ip addr flush dev $INT 2>/dev/null
sudo ip link set $INT down

echo "[*] Forçando Raw-IP e subindo interface física..."
sudo qmicli -d $DEV --wda-set-data-format=raw-ip
sudo ip link set $INT up
sleep 2

echo "[*] Iniciando conexão em background (Terminal 1)..."
# O '&' no final joga o comando para o fundo, mantendo a sessão viva
sudo qmicli -d $DEV --device-open-net='net-raw-ip|net-no-qos-header' --wds-start-network="apn='$APN',ip-type=6" --wds-follow-network > /tmp/qmi_log 2>&1 &

# Guardamos o ID do processo para fechar depois se quisermos
QMI_PID=$!

echo "[*] Aguardando o modem estabilizar..."
sleep 10

echo "[*] Lendo configurações (Terminal 2)..."
SETTINGS=$(sudo qmicli -d $DEV --wds-get-current-settings)

# Verifica se pegou o IP ou se deu OutOfCall de novo
if echo "$SETTINGS" | grep -q "OutOfCall"; then
    echo "[!] Erro: O modem ainda deu OutOfCall. Tentando novamente..."
    sudo kill $QMI_PID
    exit 1
fi

IP=$(echo "$SETTINGS" | grep "IPv6 address" | awk '{print $3}' | cut -d'/' -f1)
GW=$(echo "$SETTINGS" | grep "IPv6 gateway" | awk '{print $4}' | cut -d'/' -f1)

echo "[*] Aplicando IP: $IP"
sudo ip -6 addr add $IP/64 dev $INT
sudo ip -6 route add default via $GW dev $INT metric 100

echo "[+] Online! Testando ping..."
ping6 -c 3 -I $INT google.com
