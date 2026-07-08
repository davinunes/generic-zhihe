# Tutorial: Configuração Completa do Ecossistema Frankenstein (UFI003)

Este tutorial demonstra como configurar um modem 4G UFI003 a partir de uma instalação limpa do **postmarketOS** (utilizando systemd) para rodar o ecossistema Frankenstein. O ecossistema unifica a conexão 4G celular via QMI, Wi-Fi local, IPv6 público nativo (NDP Proxy), tradução IPv4 (CLAT), WireGuard e um Painel Web.

---

## 🛠️ Passo 1: Instalação de Pacotes Necessários

Com o modem conectado à internet (via cabo USB), atualize os repositórios e instale os pacotes:

```bash
# Atualizar repositórios do Alpine Linux
apk update

# Instalar telefonia, rede, tradução, firewall, Python3 e elevação de privilégios
apk add qmicli dnsmasq hostapd clatd tayga nftables wireguard-tools python3 doas
```

---

## ⚙️ Passo 2: Configuração Centralizada (`/etc/frankenstein.json`)

Crie o arquivo `/etc/frankenstein.json` no modem com a seguinte estrutura. (Altere as senhas e chaves conforme necessidade):

```json
{
  "admin_password": "yuk11nn4_admin",
  "apn": "zap.vivo.com.br",
  "wifi": {
    "ssid": "UFI003_4G",
    "wpa_passphrase": "yuk11nn4_wifi"
  },
  "wireguard": {
    "enabled": true,
    "address": "198.19.1.14/30",
    "private_key": "SUA_CHAVE_PRIVADA_AQUI",
    "peer_public_key": "CHAVE_PUBLICA_DO_PEER_AQUI",
    "endpoint": "rb.davinunes.eti.br:13500",
    "allowed_ips": "0.0.0.0/0, ::/0",
    "persistent_keepalive": 25
  },
  "routes": [
    {
      "network": "192.168.20.0/24",
      "gateway": "198.19.1.13",
      "interface": "wg0"
    }
  ]
}
```

> **Dica sobre o WireGuard (`allowed_ips`):**
> O valor padrão `0.0.0.0/0, ::/0` sequestra **todo** o tráfego do modem para dentro da VPN. Se quiser usar a VPN apenas para acessar máquinas remotas sem perder a rota principal 4G, altere para os IPs da sua rede remota, ex: `"192.168.20.0/24"`.

---

## 📐 Passo 3: Configuração de Serviços de Suporte

### 1. Configuração do CLAT (`/etc/clatd.conf`)
O CLAT (464XLAT) resolve a falta de IPv4 na Vivo criando uma interface IPv4 artificial que viaja pelo IPv6 da operadora.

```ini
# /etc/clatd.conf
plat-prefix=64:ff9b::/96
plat-dev=wwan0
clat-v4-addr=192.0.0.1
# Desativar verificação de conectividade IPv4 nativa (A vivo corta o 4G se tentar v4 puro)
v4-conncheck-enable=0
```

### 2. Configuração do DHCP/RA (`/etc/dnsmasq.conf`)
O dnsmasq distribui os IPs locais IPv4 e repassa os prefixos IPv6 nativos da operadora para a bridge local.

```ini
# /etc/dnsmasq.conf
interface=br0
port=53
bind-dynamic

dhcp-range=192.168.10.10,192.168.10.50,12h
dhcp-range=fd00:42:42::10,fd00:42:42::50,slaac,ra-names,12h
dhcp-range=::10,::50,constructor:br0,ra-names,slaac,12h
enable-ra

dhcp-option=option:dns-server,8.8.8.8,8.8.4.4
dhcp-option=option6:dns-server,2001:4860:4860::8888,2606:4700:4700::1111
```

---

## 📜 Passo 4: Daemon Frankenstein (`/usr/local/bin/frankenstein-v2.sh`)

O arquivo completo do script `frankenstein-v2.sh` deve ser copiado do repositório para o modem. Este script cuida de levantar a interface `br0`, aplicar o NDP Proxy (para IPs globais nativos IPv6, desativando o problemático NAT66), levantar o firewall via `nftables` e monitorar falhas (watchdog).

1. Crie ou copie o arquivo para `/usr/local/bin/frankenstein-v2.sh`.
2. Dê permissão de execução:
```bash
chmod +x /usr/local/bin/frankenstein-v2.sh
```

### Serviço Systemd (`/etc/systemd/system/frankenstein-v2.service`)

```ini
[Unit]
Description=Frankenstein v2 - Modem 4G UFI003
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/frankenstein-v2.sh watch
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
```

---

## 🖥️ Passo 5: Painel Web de Controle (`/usr/local/bin/frankenstein-web.py`)

O painel administrativo facilita a edição do JSON via web. Copie o arquivo fonte para o modem. Ele foi programado em Python base (sem dependências como Flask) para economizar RAM do modem.

```bash
chmod +x /usr/local/bin/frankenstein-web.py
```

### Serviço Systemd (`/etc/systemd/system/frankenstein-web.service`)

```ini
[Unit]
Description=Frankenstein Web Administration Dashboard
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/python3 /usr/local/bin/frankenstein-web.py
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
```

---

## ⚡ Passo 6: Habilitar e Iniciar Tudo

Para desativar serviços conflitantes do postmarketOS padrão e ativar nosso ecossistema:

```bash
# Desabilitar serviços conflitantes
systemctl disable --now NetworkManager wpa_supplicant systemd-resolved

# DNS estático para o sistema local (burlar systemd-resolved)
echo -e "nameserver 2001:4860:4860::8888\nnameserver 2606:4700:4700::1111" > /etc/resolv.conf

# Recarregar o systemd
systemctl daemon-reload

# Habilitar no boot
systemctl enable frankenstein-v2.service
systemctl enable frankenstein-web.service

# Iniciar
systemctl start frankenstein-v2.service
systemctl start frankenstein-web.service
```

---

## 🔍 Passo 7: Como Acessar o Modem

A partir de um PC ou celular conectado via WiFi (`UFI003_4G`) ou Cabo USB:
- Acesso Web / SSH pelo IP WiFi: `192.168.10.1`
- Acesso Web / SSH pelo IP USB: `172.16.42.1`
- Acesso Web / SSH pelo IPv6 ULA: `fd00:42:42::1`

Use a senha estipulada em `frankenstein.json` para logar na tela web.

---

## 🛠️ Passo 8: Comandos de Diagnóstico
Se algo der errado (4G caiu, sem IPv6, instabilidade), acesse por SSH e utilize:

1. **Checar conexões de rede:** `ip -br a` e `ip -6 route`
2. **Checar Logs do Cérebro (Watchdog):** `journalctl -u frankenstein-v2.service -f`
3. **Checar Logs do Painel Web:** `journalctl -u frankenstein-web.service -f`
4. **Modem Crash (Hardware):** `dmesg | tail -n 50` (Procure por `A2 DL PER deadlock`).
5. **Checar conexão bruta do modem celular:**
   - Status: `qmicli -d /dev/wwan0qmi0 --wds-get-packet-service-status`
   - Sinal: `qmicli -d /dev/wwan0qmi0 --nas-get-signal-info`
