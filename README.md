# Frankenstein - Modem 4G UFI003 (postmarketOS)

Roteador 4G + WiFi + WireGuard + CLAT num modem UFI003 rodando postmarketOS/Alpine Linux.

## Arquivos

| Arquivo | Destino no modem | Descrição |
|---|---|---|
| `frankenstein-v2.sh` | `/usr/local/bin/frankenstein-v2.sh` | Script unificado (4G + WiFi + WG + CLAT + watchdog) |
| `frankenstein-v2.service` | `/etc/systemd/system/frankenstein-v2.service` | Systemd service |
| `conectar_4g.sh` | `/home/ilunne/conectar_4g.sh` | Script legado de conexão 4G |
| `clatd.conf` | `/etc/clatd.conf` | Configuração do CLAT (464XLAT) |
| `processo-instalacao.txt` | — | Log da instalação do postmarketOS |

## Configurações no modem

### hostapd (`/etc/hostapd/hostapd.conf`)
- SSID: `Modem_Frankenstein`, senha: `celestia`
- Canal 6, 2.4GHz, WPA2
- Interface `wlan0`

### dnsmasq (`/etc/dnsmasq.conf`)
- DHCP: `192.168.10.10-50` (wlan0) e `172.16.42.10-50` (usb0)
- RA para IPv6 ULA `fd00:42:42::/64`
- DNS: 8.8.8.8, 8.8.4.4

### WireGuard (`/etc/wireguard/wg0.conf`)
- Endpoint: `2804:6368:c0:8::2:13500` (MikroTik em casa)
- AllowedIPs: `0.0.0.0/0`
- NAT via MikroTik para IPv4
- Rota default IPv6 via wwan0 é essencial para o handshake funcionar

### CLAT (`/etc/clatd.conf`)
- Converte IPv4 -> IPv6 via NAT64 da Vivo (prefixo `64:ff9b::/96`)
- Permite clients WiFi acessarem IPv4 mesmo com WAN IPv6-only

## Sequência de inicialização

1. `sysctl`: IP forwarding ativado (IPv4 e IPv6)
2. `nftables`: Firewall + NAT (WG para IPv4, wwan0 para IPv6) + MSS clamping
3. IPs locais: `192.168.10.1/24` (wlan0), `172.16.42.1/24` (usb0), `fd00:42:42::1/64` (ULA)
4. `hostapd` + `dnsmasq`: WiFi AP + DHCP
5. `qmicli raw`: Conexão 4G (APN `zap.vivo.com.br`, IPv6-only)
6. DNS fixo: Google IPv6
7. `wg-quick@wg0`: WireGuard
8. `clatd`: CLAT (464XLAT)

## Watchdog

O watchdog verifica a cada 30s:
- Rota default IPv6 existe na wwan0?
- Ping6 para 2001:4860:4860::8888 funciona?

Se a rota sumiu mas o bearer QMI ainda existe: reaplica IP/gateway.
Se o bearer morreu: reconecta o 4G do zero (kill qmicli + qmi commands).

## Instalação (no modem)

```bash
# Copiar os arquivos
chmod +x /usr/local/bin/frankenstein-v2.sh
cp frankenstein-v2.service /etc/systemd/system/

# Desabilitar serviços conflitantes
systemctl disable --now NetworkManager wpa_supplicant systemd-resolved
systemctl disable --now conectar-4g-init conectar-4g-watchdog frankenstein

# DNS estático (não usar systemd-resolved)
echo -e "nameserver 2001:4860:4860::8888\nnameserver 2606:4700:4700::1111" > /etc/resolv.conf

# Habilitar e iniciar
systemctl daemon-reload
systemctl enable frankenstein-v2.service
systemctl start frankenstein-v2.service

# Verificar
systemctl status frankenstein-v2.service
journalctl -u frankenstein-v2.service -f
```

## Testes

```bash
# 4G
ping6 -c 2 -I wwan0 2001:4860:4860::8888

# WireGuard
ping -c 2 -I wg0 198.19.1.13

# WiFi clients
ping -c 2 192.168.10.1

# CLAT (de um client WiFi)
ping 8.8.8.8
```

## Notas

- A Vivo só entrega IPv6 (APN `zap.vivo.com.br`). IPv4 é recusado.
- NetworkManager e wpa_supplicant entram em conflito com hostapd — manter desabilitados.
- O mirror `dl-cdn.alpinelinux.org` pode time out por IPv6 (problema de rota). Se precisar instalar pacotes, usar proxy ou baixar .apk externamente.
- wwan0 é raw-ip (precisa de `qmicli --wda-set-data-format=raw-ip` antes de configurar IP).
