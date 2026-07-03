# Frankenstein - Resumo Geral

Modem 4G UFI003 (Qualcomm MSM8916) rodando postmarketOS/Alpine Linux como roteador autônomo.

---

## O que está funcionando ✓

### WiFi AP
- **hostapd** com SSID `Modem_Frankenstein`, senha `celestia`, canal 6, 2.4GHz, WPA2
- **dnsmasq** DHCP para wlan0 (192.168.10.10-50) e usb0 (172.16.42.10-50)
- DNS fixo: Google IPv6

### Conexão 4G (QMI raw)
- APN `zap.vivo.com.br`, IPv6-only (Vivo recusa IPv4)
- qmicli raw: `--wda-set-data-format=raw-ip` + `--wds-start-network ip-type=6`
- Comando para obter settings: `qmicli -d /dev/wwan0qmi0 --wds-get-current-settings`
- A Vivo troca o IP e gateway periodicamente — o script precisa reaplicar `ip -6 addr add` e `ip -6 route add default`

### WireGuard
- Handshake estabelecido com MikroTik em casa
- Endpoint: `2804:6368:c0:8::2:13500` (IPv6 nativo, funciona)
- IP do túnel: `198.19.1.14/30`
- Transfer: 92B received, 212B sent (handshake, sem tráfego de dados)

### Serviços desabilitados (conflitos)
- NetworkManager, wpa_supplicant, systemd-resolved
- Scripts legados: conectar-4g-init, conectar-4g-watchdog, frankenstein.service

---

## O que está pendente ❌

### Tráfego WireGuard não passa
- Handshake OK, mas `ping -I wg0 198.19.1.13` e `ping -I wg0 8.8.8.8` falham
- Causa: `wg-quick up` flusha nftables e só recria as regras dele (preraw, premangle), SEM o NAT masquerade
- Fix: rodar `nft add rule ip nat postrouting oifname "wg0" masquerade` **depois** do `wg-quick up`
- Já corrigido no `frankenstein-v2.sh` (ordem alterada: firewall depois do WG)

### CLAT (464XLAT) não testado
- Instalado (clatd 2.1.0 do Alpine edge)
- Config `/etc/clatd.conf` criada mas nunca testada de fato
- Precisa testar com `clatd --help` primeiro pra ver os flags certos

### Persistência após reboot
- `frankenstein-v2.service` criado mas nunca ativado
- Sequência correta: systemctl enable frankenstein-v2.service

### Rotas IPv6 voláteis
- A Vivo troca IP/gateway sem aviso
- Quando o IP muda, o `ip -6 addr` antigo some e a rota default quebra
- O watchdog precisa detectar isso e reaplicar do `--wds-get-current-settings`

### IPv6 para clients WiFi
- Só tem ULA `fd00:42:42::/64` via dnsmasq RA
- Sem rota global, clients WiFi não têm IPv6 público
- Soluções possíveis: ndppd + proxy NDP, ou NAT66 (já configurado no nftables)

---

## Descobertas importantes

| Descoberta | Detalhe |
|---|---|
| Vivo é IPv6-only | APN `zap.vivo.com.br` recusa IPv4 (`ip-type=4` falha). |
| wwano é raw-IP | Precisa `--wda-set-data-format=raw-ip` antes de configurar IP. |
| qmicli bearer persiste | Mesmo que o IP suma da interface, `--wds-get-current-settings` ainda retorna o bearer ativo. |
| Gateway não pinga | O gateway IPv6 não responde ICMP, mas roteia. |
| wg-quick up flusha nftables | Destrói todas as regras de NAT/firewall. |
| Alpine edge tem clatd | `clatd-2.1.0-r0` disponível, mas mirror pode timeout por IPv6. |
| DNS fixo | systemd-resolved desabilitado, `/etc/resolv.conf` estático. |

---

## Arquivos no projeto

| Arquivo | Destino no modem | Descrição |
|---|---|---|
| `frankenstein-v2.sh` | `/usr/local/bin/frankenstein-v2.sh` | Script unificado (4G+WiFi+WG+CLAT+watchdog) |
| `frankenstein-v2.service` | `/etc/systemd/system/` | Systemd service |
| `conectar_4g.sh` | `/home/ilunne/conectar_4g.sh` | Script legado de conexão 4G |
| `clatd.conf` | `/etc/clatd.conf` | Configuração CLAT |
| `RESUMO.md` | — | Este arquivo |

---

## Padrões de falha conhecidos

1. **Bearer caiu**: `--wds-get-current-settings` retorna erro → reconectar 4G do zero
2. **IP mudou**: `--wds-get-current-settings` retorna IP novo mas addr antigo na interface → reaplicar `ip -6 addr add` + `ip -6 route add default`
3. **Rota sumiu sem motivo**: O link wwan0 pode dar UP/DOWN sem razão aparente → reaplicar rota default
4. **WG handshake OK mas sem tráfego**: NAT masquerade foi flusheado pelo wg-quick → reaplicar regra nftables
5. **CLAT não sobe**: Flag errada (`-f` não existe, tentar sem flag ou `--help`)
