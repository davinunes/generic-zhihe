#!/bin/bash
# Frankenstein v2 - Script unificado do modem 4G UFI003
# Uso: ./frankenstein-v2.sh (roda uma vez, sem watchdog)
#       ./frankenstein-v2.sh watch (roda com watchdog)

CONFIG_FILE="/etc/frankenstein.json"

get_cfg() {
    python3 -c "import json; d=json.load(open('$CONFIG_FILE')); print(d$1)" 2>/dev/null
}

# Carregar variáveis do JSON
APN=$(get_cfg "['apn']")
SSID=$(get_cfg "['wifi']['ssid']")
PASSPHRASE=$(get_cfg "['wifi']['wpa_passphrase']")

WG_ENABLED=$(get_cfg "['wireguard']['enabled']")
WG_ADDRESS=$(get_cfg "['wireguard']['address']")
WG_PRIVATE_KEY=$(get_cfg "['wireguard']['private_key']")
WG_PEER_PUBLIC_KEY=$(get_cfg "['wireguard']['peer_public_key']")
WG_ENDPOINT=$(get_cfg "['wireguard']['endpoint']")
WG_ALLOWED_IPS=$(get_cfg "['wireguard']['allowed_ips']")
WG_KEEPALIVE=$(get_cfg "['wireguard']['persistent_keepalive']")

# Fallbacks padrão caso não exista no JSON
[ -z "$APN" ] && APN="zap.vivo.com.br"
[ -z "$SSID" ] && SSID="UFI003_4G"
[ -z "$PASSPHRASE" ] && PASSPHRASE="yuk11nn4_wifi"

DEV="/dev/wwan0qmi0"
INT="wwan0"

# ============================================================
# FUNÇÕES
# ============================================================

setup_sysctl() {
    sysctl -w net.ipv4.ip_forward=1
    sysctl -w net.ipv6.conf.all.forwarding=1
    sysctl -w net.ipv6.conf.all.accept_ra=2
}

setup_firewall() {
    echo "[*] Configurando firewall (nftables)..."
    nft flush ruleset
    nft add table inet filter
    nft add chain inet filter input { type filter hook input priority 0 \; policy accept \; }
    nft add chain inet filter forward { type filter hook forward priority 0 \; policy accept \; }

    nft add table ip nat
    nft add chain ip nat postrouting { type nat hook postrouting priority 100 \; }
    nft add rule ip nat postrouting oifname "wg0" masquerade
    nft add rule ip nat postrouting oifname "clat" masquerade

    nft add table ip6 nat
    nft add chain ip6 nat postrouting { type nat hook postrouting priority 100 \; }
    nft add rule ip6 nat postrouting oifname "$INT" masquerade

    nft add rule inet filter forward tcp flags syn tcp option maxseg size set 1300
}

setup_local_ips() {
    echo "[*] Configurando bridge br0 para WLAN e USB..."
    # Limpar qualquer bridge existente para evitar conflito de rede
    ip link set br0 down 2>/dev/null || true
    ip link delete br0 type bridge 2>/dev/null || true

    # Criar a bridge br0
    ip link add br0 type bridge
    ip link set br0 up

    # Associar usb0 ao br0
    ip link set usb0 down 2>/dev/null || true
    ip link set usb0 master br0 2>/dev/null || true
    ip link set usb0 up 2>/dev/null || true

    # Preparar wlan0 (o hostapd associará wlan0 ao br0 via hostapd.conf)
    ip link set wlan0 down 2>/dev/null || true
    ip link set wlan0 up 2>/dev/null || true

    # Definir IPs locais estáticos na bridge
    ip addr add 192.168.10.1/24 dev br0 2>/dev/null || true
    ip addr add 172.16.42.1/24 dev br0 2>/dev/null || true
    ip -6 addr add fd00:42:42::1/64 dev br0 2>/dev/null || true
}

conectar_4g() {
    echo "[*] Conectando 4G (QMI raw)..."

    killall -9 qmicli 2>/dev/null
    ip addr flush dev $INT 2>/dev/null
    ip link set $INT down
    sleep 1

    qmicli -p -d $DEV --dms-set-operating-mode=online 2>/dev/null
    qmicli -p -d $DEV --wda-set-data-format=raw-ip
    ip link set $INT up
    sleep 2

    qmicli -p -d $DEV --device-open-net='net-raw-ip|net-no-qos-header' \
        --wds-start-network="apn='$APN',ip-type=6" \
        --wds-follow-network > /tmp/qmi_log 2>&1 &
    sleep 8

    SETTINGS=$(qmicli -p -d $DEV --wds-get-current-settings 2>/dev/null)

    IP6=$(echo "$SETTINGS" | grep "IPv6 address" | awk '{print $3}' | cut -d'/' -f1)
    GW6=$(echo "$SETTINGS" | grep "IPv6 gateway" | awk '{print $4}' | cut -d'/' -f1)

    if [ -z "$IP6" ] || [ -z "$GW6" ]; then
        echo "[!] Falha ao obter IP/GW IPv6"
        echo "Debug: $SETTINGS"
        return 1
    fi

    # Garantir que a interface WAN está UP
    ip link set $INT up

    # Aguardar a interface WAN ficar operacional (LOWER_UP) antes de aplicar as rotas
    echo "[*] Aguardando interface $INT ficar pronta..."
    for i in $(seq 1 10); do
        if ip link show dev $INT | grep -q "LOWER_UP"; then
            break
        fi
        sleep 1
    done

    # Configurar wwan0 como /128 para evitar conflito de rota local no bridge br0 (/64)
    ip -6 addr add "$IP6/128" dev $INT
    ip -6 route add "$GW6" dev $INT 2>/dev/null || true
    ip -6 route add default via "$GW6" dev $INT metric 100

    echo "[+] 4G conectado: $IP6 via $GW6"

    # Extrair e configurar o prefixo global no bridge br0
    PREFIX6=$(echo "$IP6" | cut -d: -f1-4)::
    echo "[*] Atribuindo prefixo global Vivo no br0: ${PREFIX6}1/64"
    
    # Limpar global IPv6 anterior da bridge se existir
    ip -6 addr show dev br0 | grep "global" | awk '{print $2}' | xargs -r ip -6 addr del dev br0 2>/dev/null || true
    
    # Adicionar o novo IP global
    ip -6 addr add "${PREFIX6}1/64" dev br0

    # Configurar proxy NDP nativo no kernel para repassar Neighbor Solicitations
    echo "[*] Configurando proxy NDP nativo no kernel..."
    sysctl -w net.ipv6.conf.wwan0.proxy_ndp=1 >/dev/null

    # Limpar proxies antigos
    ip -6 neigh show proxy dev wwan0 | awk '{print $1}' | xargs -r ip -6 neigh del proxy dev wwan0 2>/dev/null || true

    # Adicionar proxies para a faixa de IPs que o dnsmasq vai entregar aos clientes (de ::10 a ::80)
    for i in $(seq 10 80); do
        HEX=$(printf '%x' $i)
        ip -6 neigh add proxy "${PREFIX6}${HEX}" dev wwan0 2>/dev/null || true
    done

    # Reiniciar dnsmasq para aplicar as mudanças de prefixo
    echo "[*] Reiniciando dnsmasq..."
    systemctl restart dnsmasq 2>/dev/null || rc-service dnsmasq restart 2>/dev/null

    return 0
}

check_4g() {
    ip -6 route show default | grep -q "$INT" || return 1
    ping6 -c 1 -W 3 -I $INT 2001:4860:4860::8888 > /dev/null 2>&1
}

start_wifi() {
    echo "[*] Gerando /etc/hostapd/hostapd.conf..."
    cat <<EOF > /etc/hostapd/hostapd.conf
interface=wlan0
driver=nl80211
ssid=${SSID}
hw_mode=g
channel=6
wmm_enabled=1
auth_algs=1
wpa=2
wpa_passphrase=${PASSPHRASE}
wpa_key_mgmt=WPA-PSK
rsn_pairwise=CCMP
ctrl_interface=/var/run/hostapd
ctrl_interface_group=0
bridge=br0
EOF

    killall hostapd dnsmasq 2>/dev/null || true
    sleep 1
    /usr/sbin/hostapd -B /etc/hostapd/hostapd.conf
    /usr/sbin/dnsmasq -C /etc/dnsmasq.conf
    echo "[+] WiFi AP (bridge br0) e DHCP ativos"
}

start_wireguard() {
    if [ "$WG_ENABLED" = "True" ]; then
        echo "[*] Gerando /etc/wireguard/wg0.conf..."
        mkdir -p /etc/wireguard
        cat <<EOF > /etc/wireguard/wg0.conf
[Interface]
Address = ${WG_ADDRESS}
PrivateKey = ${WG_PRIVATE_KEY}
MTU = 1280

[Peer]
PublicKey = ${WG_PEER_PUBLIC_KEY}
Endpoint = ${WG_ENDPOINT}
AllowedIPs = ${WG_ALLOWED_IPS}
PersistentKeepalive = ${WG_KEEPALIVE}
EOF
        echo "[*] Iniciando WireGuard..."
        systemctl restart wg-quick@wg0 2>/dev/null || rc-service wg-quick@wg0 restart 2>/dev/null || wg-quick up wg0 2>/dev/null
        sleep 2
        if wg show wg0 2>/dev/null | grep -q "latest handshake"; then
            echo "[+] WireGuard handshake OK"
        else
            echo "[!] WireGuard: sem handshake ainda"
        fi
    else
        echo "[*] WireGuard desativado nas configurações."
        wg-quick down wg0 2>/dev/null || true
    fi
}

start_clat() {
    if command -v clatd > /dev/null 2>&1; then
        echo "[*] Iniciando CLAT..."
        killall clatd tayga 2>/dev/null || true
        sleep 1
        clatd -c /etc/clatd.conf
        echo "[+] CLAT iniciado"
    else
        echo "[-] CLAT não instalado"
    fi
}

apply_static_routes() {
    if [ -f "$CONFIG_FILE" ]; then
        echo "[*] Aplicando rotas estáticas do config..."
        python3 -c "
import json, subprocess
try:
    d = json.load(open('$CONFIG_FILE'))
    routes = d.get('routes', [])
    for r in routes:
        net = r.get('network')
        gw = r.get('gateway')
        iface = r.get('interface')
        if not net or not iface:
            continue
        ip_ver = '-6' if ':' in net else '-4'
        cmd = ['ip', ip_ver, 'route', 'replace', net, 'dev', iface]
        if gw:
            cmd = ['ip', ip_ver, 'route', 'replace', net, 'via', gw, 'dev', iface]
        subprocess.run(cmd, stderr=subprocess.DEVNULL)
except Exception as e:
    pass
"
    fi
}

# ============================================================
# EXECUÇÃO PRINCIPAL
# ============================================================

echo "=== Frankenstein v2 ==="

setup_sysctl
setup_local_ips
start_wifi

conectar_4g || {
    echo "[!] Falha na conexão 4G"
    sleep 10
    conectar_4g || exit 1
}

echo "[*] DNS fixo..."
echo -e "nameserver 2001:4860:4860::8888\nnameserver 2606:4700:4700::1111" > /etc/resolv.conf

start_wireguard
# wg-quick flushes nftables, então o firewall deve vir DEPOIS do WG
setup_firewall
start_clat
apply_static_routes

echo "[+] Frankenstein v2 pronto. Interfaces:"
ip -4 addr show dev br0 2>/dev/null
ip -6 addr show dev $INT 2>/dev/null
ip -6 route show default

# ============================================================
# WATCHDOG (modo watch)
# ============================================================
if [ "${1:-}" = "watch" ]; then
    echo "[*] Watchdog ativo (verificando a cada 30s)..."
    while true; do
        if ! check_4g; then
            echo "[!] 4G caiu ou sem rota default. Tentando recuperar..."
            SETTINGS=$(qmicli -p -d $DEV --wds-get-current-settings 2>/dev/null)
            IP6=$(echo "$SETTINGS" | grep "IPv6 address" | awk '{print $3}' | cut -d'/' -f1)
            GW6=$(echo "$SETTINGS" | grep "IPv6 gateway" | awk '{print $4}' | cut -d'/' -f1)
            
            if [ -n "$IP6" ] && [ -n "$GW6" ]; then
                # Tentar re-adicionar rotas e IPs (caso a interface tenha dado bounce)
                ip -6 addr add "$IP6/128" dev $INT 2>/dev/null || true
                ip -6 route add "$GW6" dev $INT 2>/dev/null || true
                ip -6 route add default via "$GW6" dev $INT metric 100 2>/dev/null || true
                
                # Restaurar IP do bridge e ndppd.conf
                PREFIX6=$(echo "$IP6" | cut -d: -f1-4)::
                ip -6 addr show dev br0 | grep "global" | awk '{print $2}' | xargs -r ip -6 addr del dev br0 2>/dev/null || true
                ip -6 addr add "${PREFIX6}1/64" dev br0 2>/dev/null || true
                
                # Configurar proxy NDP nativo no kernel
                sysctl -w net.ipv6.conf.wwan0.proxy_ndp=1 >/dev/null
                ip -6 neigh show proxy dev wwan0 | awk '{print $1}' | xargs -r ip -6 neigh del proxy dev wwan0 2>/dev/null || true
                for i in $(seq 10 80); do
                    HEX=$(printf '%x' $i)
                    ip -6 neigh add proxy "${PREFIX6}${HEX}" dev wwan0 2>/dev/null || true
                done

                # Reiniciar serviços dependentes do IP WAN
                systemctl restart dnsmasq 2>/dev/null || rc-service dnsmasq restart 2>/dev/null
                start_wireguard
                setup_firewall
                start_clat
                apply_static_routes
                echo "[+] Rota e serviços IPv6 restaurados"
            else
                echo "[!] Bearer perdido do QMI. Reconectando 4G do zero..."
                conectar_4g
                start_wireguard
                setup_firewall
                start_clat
                apply_static_routes
            fi
        fi
        sleep 30
    done
fi
