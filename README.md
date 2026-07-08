# Frankenstein - Modem 4G UFI003 (postmarketOS)

Roteador 4G + WiFi + WireGuard + CLAT num modem UFI003 rodando postmarketOS/Alpine Linux.

## Visão Geral do Projeto

O Frankenstein é um sistema projetado para contornar as limitações de roteadores 4G (especialmente a ausência nativa de IPv4 em provedores como a Vivo). Ele converte um modem UFI003 básico em um roteador avançado com kernel Linux, entregando:
- **NDP Proxy (IPv6):** Distribuição nativa de endereços IPv6 públicos (via SLAAC) para todos os dispositivos na rede local, sem depender de NAT66.
- **CLAT (464XLAT):** Tradução de IPv4 para IPv6. O modem opera numa rede puramente IPv6, mas o CLAT cria uma rede local IPv4 artificial e encapsula o tráfego via NAT64 da operadora, restaurando o acesso a sites antigos.
- **WireGuard:** VPN moderna e extremamente leve rodando direto no modem.
- **Painel Web:** Uma interface administrativa Dual-Stack para verificar status e editar o JSON de configuração rapidamente.

## Arquivos do Projeto

- `frankenstein-v2.sh`: O script unificado ou "cérebro" da rede. Ele sobe a bridge (`br0`), o firewall, o WiFi, o WireGuard e gerencia o modem (via QMI raw-ip). Fica em modo `watchdog` monitorando quedas do hardware.
- `frankenstein-web.py`: Servidor web administrativo desenvolvido em Python puro (porta 80).
- `frankenstein.json`: Arquivo central de configurações.
- `tutorial-setup-modem.md`: Passo-a-passo técnico para instalação do ecossistema a partir de uma instalação limpa do postmarketOS.

## IPs Padrão de Acesso (Modem)

Após a configuração do Frankenstein, o modem pode ser acessado localmente no Painel Web ou via SSH usando três IPs estáticos diferentes, a depender de como você está conectado:
- **`192.168.10.1`** (Pela rede WiFi `UFI003_4G`)
- **`172.16.42.1`** (Pela porta USB, conectado como RNDIS)
- **`fd00:42:42::1`** (IP Local IPv6 seguro ULA)

## Pontos de Atenção (Avisos Importantes)

### WireGuard - Sequestro de Rotas (Default Route)
O comportamento padrão do WireGuard é rotear **todo o tráfego** da sua rede para dentro da VPN quando a configuração `AllowedIPs = 0.0.0.0/0, ::/0` é utilizada. Isso significa que, se o outro lado da VPN cair, o seu modem ficará sem acesso à internet.
> **Dica:** Se você deseja usar a VPN **apenas** para acessar a rede de outra casa ou empresa e navegar livremente pelo 4G para os demais sites, altere o `AllowedIPs` no JSON para conter *apenas* a rede de destino (ex: `192.168.20.0/24, 198.19.1.13/32`).

### Firewall (nftables) e NAT66
- **IPv4:** Utilizamos NAT (Masquerade) para a VPN (`wg0`) e para o CLAT (`clat`), pois toda a internet IPv4 local do modem é emulada/artificial.
- **IPv6:** O NAT66 (Masquerade) **ESTÁ DESABILITADO INTENCIONALMENTE**. Implementamos um recurso sofisticado chamado **NDP Proxy**. Isso garante que computadores na sua rede local recebam IPs IPv6 públicos *reais* (SLAAC) e não fiquem "escondidos" pelo firewall do modem. Isso é essencial para que o tráfego chegue com o IP real do seu PC em firewalls superiores (Mikrotik) ou se você quiser liberar portas externas (RDP 3389).

### CLAT (464XLAT)
A Vivo (e várias outras operadoras) só entrega redes IPv6-only nativamente (APN `zap.vivo.com.br`). Tentar requisitar um IP IPv4 causa desconexão. Sem o CLAT, seus dispositivos não conseguiriam acessar sites, jogos ou aplicativos que só usam IPv4. O `clatd` no modem cuida dessa mágica rodando em background.

## Comandos Principais de Diagnóstico

Se a internet cair, o 4G ficar instável ou houver lentidão, acesse o SSH do modem e utilize as ferramentas abaixo para diagnosticar a causa raiz:

**1. Analisar Travamentos de Hardware (Crash do Modem)**
Esses modems (chips Qualcomm) costumam dar kernel panic em cargas altas (`A2 DL PER deadlock timer expired`). O watchdog foi feito para recuperar isso, mas se quiser confirmar o que ocorreu, veja as últimas 50 linhas de log do kernel:
```bash
dmesg | tail -n 50
```

**2. Checar a Conexão com a Torre (Sinal e QMI)**
Para ver se o chip perdeu sinal ou o provedor cortou a conexão:
```bash
# O status deve ser 'online' (Modem ligado)
qmicli -d /dev/wwan0qmi0 --dms-get-operating-mode

# O status deve ser 'connected' (Sessão de dados estabelecida)
qmicli -d /dev/wwan0qmi0 --wds-get-packet-service-status

# Ver a força do sinal em dBm (RSSI / RSRP)
qmicli -d /dev/wwan0qmi0 --nas-get-signal-info
```

**3. Ver Logs do Watchdog (O que o script está tentando fazer)**
```bash
journalctl -u frankenstein-v2.service -n 50 --no-pager
```

**4. Logs do Servidor Web**
```bash
journalctl -u frankenstein-web.service -n 50 --no-pager
```

**5. Checar a Topologia de Rede (IPs)**
```bash
ip -br a
```
*A interface `br0` deve ter IPs locais IPv4 e o IP global IPv6.*
*A interface `wwan0` deve estar UP, possuir o IP local fe80, e possivelmente o /128 da operadora.*

**6. Checar Vizinhos IPv6 Mapeados no NDP Proxy**
Para confirmar que um PC foi identificado e exposto publicamente para a internet IPv6:
```bash
ip -6 neigh show proxy dev wwan0
```
