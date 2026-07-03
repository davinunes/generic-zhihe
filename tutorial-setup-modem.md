# Tutorial: Configuração de Modem 4G (UFI003) no postmarketOS (Alpine Linux)

Este tutorial demonstra como configurar um modem 4G UFI003 a partir de uma instalação limpa do **postmarketOS** (utilizando systemd) para:
*   Conectar na rede IPv6 da operadora (ex: Vivo) usando QMI (`wwan0`).
*   Configurar uma bridge (`br0`) unificando as interfaces Wi-Fi (`wlan0`) e USB Gadget (`usb0`).
*   Distribuir prefixo global IPv6 dinâmico aos clientes na bridge via **SLAAC/DHCPv6** (`dnsmasq`).
*   Implementar **NDP Proxying nativo do kernel** para repassar solicitações Neighbor Solicitations (NS/NA) sem dependências externas (`ndppd`).
*   Configurar **CLAT** (`clatd` + `tayga` NAT64) para prover tráfego IPv4 transparente aos clientes em uma rede puramente IPv6 WAN.
*   Configurar regras de firewall (`nftables`) para masquerading e ajuste automático de MSS (MTU clamping).

---

## 🛠️ Passo 1: Instalação de Pacotes Necessários

Com o modem conectado à internet (você pode usar uma conexão temporária ou habilitar os repositórios oficiais do Alpine Linux), instale os pacotes principais.

> [!IMPORTANT]
> Certifique-se de que os repositórios `main` e `community` correspondentes à sua versão do Alpine estão habilitados em `/etc/apk/repositories`.

```bash
# Atualizar a lista de repositórios
apk update

# Instalar ferramentas de telefonia, redes, tradução e firewall
apk add qmicli dnsmasq hostapd clatd tayga nftables wireguard-tools
```

---

## 📐 Passo 2: Arquivos de Configuração

Configure cada um dos serviços essenciais abaixo.

### 1. Configuração do CLAT (`/etc/clatd.conf`)
O `clatd` gerencia a interface virtual de tradução. Use o prefixo padrão Well-Known da Vivo/NAT64 (`64:ff9b::/96`).

```ini
# /etc/clatd.conf
clat-interface=clat
plat-prefix=64:ff9b::/96
# wwan0 é a nossa interface WAN física
plat-dev=wwan0
```

### 2. Configuração do DHCP/RA (`/etc/dnsmasq.conf`)
O `dnsmasq` gerenciará a distribuição de IPs na bridge local `br0`. Ele irá escutar nela e utilizar a diretiva `constructor:br0` para construir dinamicamente o prefixo global IPv6 de anúncio a partir do IP atribuído à bridge.

```ini
# /etc/dnsmasq.conf
interface=br0
bind-interfaces

# Desabilitar resolução DNS interna do dnsmasq (ou configure como desejar)
port=0

# Range IPv4 para USB/WLAN
dhcp-range=192.168.10.10,192.168.10.50,12h
dhcp-option=option:router,192.168.10.1

# Anúncio IPv6 (SLAAC e DHCPv6 Stateful usando o prefixo global dinâmico da bridge)
dhcp-range=::10,::50,constructor:br0,ra-names,12h

# Anúncio IPv6 local estático ULA (opcional, para conectividade local persistente)
dhcp-range=fd00:42:42::10,fd00:42:42::50,12h
enable-ra

# Enviar rotas e DNS IPv6 padrão nas propagações de anúncios de roteador (RA)
quiet-ra
```

### 3. Associação da Bridge no Hostapd (`/etc/hostapd/hostapd.conf`)
Edite o arquivo de configuração do seu ponto de acesso Wi-Fi para que a interface de rádio (`wlan0`) seja colocada de forma automática no bridge `br0` quando o AP subir:

```ini
# No arquivo /etc/hostapd/hostapd.conf adicione ou edite:
interface=wlan0
bridge=br0
```

---

## 📜 Passo 3: Script Frankenstein v2 (`/usr/local/bin/frankenstein-v2.sh`)

Este é o coração da automação. Ele configura as interfaces, faz a discagem QMI, extrai o prefixo global da WAN, sobe a bridge com o IP de gateway do cliente, configura o **NDP Proxying nativo no kernel**, ativa o firewall e inicializa os daemons de suporte.

Crie o arquivo `/usr/local/bin/frankenstein-v2.sh` com o conteúdo abaixo:

```bash
#!/bin/bash
# Frankenstein v2 - Script unificado do modem 4G UFI003
# Uso: ./frankenstein-v2.sh (roda uma vez, sem watchdog)
#       ./frankenstein-v2.sh watch (roda com watchdog)

APN="zap.vivo.com.br"
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
    nft add chain inet filter input { type filter hook input priority 0 ; policy accept ; }
    nft add chain inet filter forward { type filter hook forward priority 0 ; policy accept ; }

    nft add table ip nat
    nft add chain ip nat postrouting { type nat hook postrouting priority 100 ; }
    nft add rule ip nat postrouting oifname "clat" masquerade

    nft add table ip6 nat
    nft add chain ip6 nat postrouting { type nat hook postrouting priority 100 ; }
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

    qmicli -d $DEV --dms-set-operating-mode=online 2>/dev/null
    qmicli -d $DEV --wda-set-data-format=raw-ip
    ip link set $INT up
    sleep 2

    qmicli -d $DEV --device-open-net='net-raw-ip|net-no-qos-header' \
        --wds-start-network="apn='$APN',ip-type=6" \
        --wds-follow-network > /tmp/qmi_log 2>&1 &
    sleep 8

    SETTINGS=$(qmicli -d $DEV --wds-get-current-settings 2>/dev/null)

    IP6=$(echo "$SETTINGS" | grep "IPv6 address" | awk '{print $3}' | cut -d'/' -f1)
    GW6=$(echo "$SETTINGS" | grep "IPv6 gateway" | awk '{print $4}' | cut -d'/' -f1)

    if [ -z "$IP6" ] || [ -z "$GW6" ]; then
        echo "[!] Falha ao obter IP/GW IPv6"
        echo "Debug: $SETTINGS"
        return 1
    fi

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

    # Configurar proxy NDP nativo no kernel para repassar solicitações dos clientes
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
    killall hostapd dnsmasq 2>/dev/null || true
    sleep 1
    /usr/sbin/hostapd -B /etc/hostapd/hostapd.conf
    /usr/sbin/dnsmasq -C /etc/dnsmasq.conf
    echo "[+] WiFi AP (bridge br0) e DHCP ativos"
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

setup_firewall
start_clat

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
            SETTINGS=$(qmicli -d $DEV --wds-get-current-settings 2>/dev/null)
            IP6=$(echo "$SETTINGS" | grep "IPv6 address" | awk '{print $3}' | cut -d'/' -f1)
            GW6=$(echo "$SETTINGS" | grep "IPv6 gateway" | awk '{print $4}' | cut -d'/' -f1)
            
            if [ -n "$IP6" ] && [ -n "$GW6" ]; then
                # Tentar re-adicionar rotas e IPs (caso a interface tenha dado bounce)
                ip -6 addr add "$IP6/128" dev $INT 2>/dev/null || true
                ip -6 route add "$GW6" dev $INT 2>/dev/null || true
                ip -6 route add default via "$GW6" dev $INT metric 100 2>/dev/null || true
                
                # Restaurar IP do bridge e proxy NDP
                PREFIX6=$(echo "$IP6" | cut -d: -f1-4)::
                ip -6 addr show dev br0 | grep "global" | awk '{print $2}' | xargs -r ip -6 addr del dev br0 2>/dev/null || true
                ip -6 addr add "${PREFIX6}1/64" dev br0 2>/dev/null || true
                
                sysctl -w net.ipv6.conf.wwan0.proxy_ndp=1 >/dev/null
                ip -6 neigh show proxy dev wwan0 | awk '{print $1}' | xargs -r ip -6 neigh del proxy dev wwan0 2>/dev/null || true
                for i in $(seq 10 80); do
                    HEX=$(printf '%x' $i)
                    ip -6 neigh add proxy "${PREFIX6}${HEX}" dev wwan0 2>/dev/null || true
                done

                # Reiniciar serviços dependentes do IP WAN
                systemctl restart dnsmasq 2>/dev/null || rc-service dnsmasq restart 2>/dev/null
                setup_firewall
                start_clat
                echo "[+] Rota e serviços IPv6 restaurados"
            else
                echo "[!] Bearer perdido do QMI. Reconectando 4G do zero..."
                conectar_4g
                setup_firewall
                start_clat
            fi
        fi
        sleep 30
    done
fi
