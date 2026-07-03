login as: ilunne
Authenticating with public key "rsa-key-20210403"
Welcome to postmarketOS! o/

This distribution is based on Alpine Linux.
First time using postmarketOS? Make sure to read the cheatsheet in the wiki:

-> https://postmarketos.org/cheatsheet

You may change this message by editing /etc/motd.
generic-zhihe:~$ duso su
-ash: duso: not found
generic-zhihe:~$ sudo su
doas (ilunne@generic-zhihe) password:
/home/ilunne # killall wpa_supplicant hostapd NetworkManager 2>/dev/null
/home/ilunne # ip link set wlan0 down
/home/ilunne # iw dev wlan0 set type ap
You need to run a management daemon, e.g. hostapd,
see http://wireless.kernel.org/en/users/Documentation/hostapd
for more information on how to do that.
/home/ilunne # ip link set wlan0 up
/home/ilunne # hostapd -dd /etc/hostapd/hostapd.conf 2>&1 | head -80
random: Trying to read entropy from /dev/random
Configuration file: /etc/hostapd/hostapd.conf
ctrl_interface_group=0
nl80211: Kernel version: Linux 6.12.1-msm8916 (#3 SMP PREEMPT Sun Dec  7 23:30:58 UTC 2025; aarch64)
nl80211: Maximum supported attribute ID: 332
nl80211: Initialize interface wlan0 (driver: wcn36xx)
nl80211: Supported cipher 00-0f-ac:1
nl80211: Supported cipher 00-0f-ac:5
nl80211: Supported cipher 00-0f-ac:2
nl80211: Supported cipher 00-0f-ac:4
nl80211: Using driver-based off-channel TX
nl80211: Driver-advertised extended capabilities (default) - hexdump(len=8): 04 00 00 00 00 00 00 40
nl80211: Driver-advertised extended capabilities mask (default) - hexdump(len=8): 04 00 00 00 00 00 00 40
nl80211: key_mgmt=0x1fd0f enc=0xf auth=0x7 flags=0x40005104b03d0e0 flags2=0x103 rrm_flags=0x10 probe_resp_offloads=0x0 max_stations=0 max_remain_on_chan=5000 max_scan_ssids=9
nl80211: interface wlan0 in phy phy0
nl80211: Set mode ifindex 3 iftype 3 (AP)
nl80211: Failed to set interface 3 to mode 3: -16 (Resource busy)
nl80211: Try mode change after setting interface down
nl80211: Set mode ifindex 3 iftype 3 (AP)
nl80211: Mode change succeeded while interface is down
nl80211: Setup AP(wlan0) - device_ap_sme=0 use_monitor=0
nl80211: Subscribe to mgmt frames with AP handle 0xffff9adf7050
nl80211: Register frame type=0xb0 (WLAN_FC_STYPE_AUTH) nl_handle=0xffff9adf7050 match= multicast=0
nl80211: Register frame type=0x0 (WLAN_FC_STYPE_ASSOC_REQ) nl_handle=0xffff9adf7050 match= multicast=0
nl80211: Register frame type=0x20 (WLAN_FC_STYPE_REASSOC_REQ) nl_handle=0xffff9adf7050 match= multicast=0
nl80211: Register frame type=0xa0 (WLAN_FC_STYPE_DISASSOC) nl_handle=0xffff9adf7050 match= multicast=0
nl80211: Register frame type=0xc0 (WLAN_FC_STYPE_DEAUTH) nl_handle=0xffff9adf7050 match= multicast=0
nl80211: Register frame type=0x40 (WLAN_FC_STYPE_PROBE_REQ) nl_handle=0xffff9adf7050 match= multicast=0
nl80211: Register frame type=0xd0 (WLAN_FC_STYPE_ACTION) nl_handle=0xffff9adf7050 match=04 multicast=0
nl80211: Register frame type=0xd0 (WLAN_FC_STYPE_ACTION) nl_handle=0xffff9adf7050 match=0501 multicast=0
nl80211: Register frame type=0xd0 (WLAN_FC_STYPE_ACTION) nl_handle=0xffff9adf7050 match=0503 multicast=0
nl80211: Register frame type=0xd0 (WLAN_FC_STYPE_ACTION) nl_handle=0xffff9adf7050 match=0504 multicast=0
nl80211: Register frame type=0xd0 (WLAN_FC_STYPE_ACTION) nl_handle=0xffff9adf7050 match=06 multicast=0
nl80211: Register frame type=0xd0 (WLAN_FC_STYPE_ACTION) nl_handle=0xffff9adf7050 match=08 multicast=0
nl80211: Register frame type=0xd0 (WLAN_FC_STYPE_ACTION) nl_handle=0xffff9adf7050 match=09 multicast=0
nl80211: Register frame type=0xd0 (WLAN_FC_STYPE_ACTION) nl_handle=0xffff9adf7050 match=0a multicast=0
nl80211: Register frame type=0xd0 (WLAN_FC_STYPE_ACTION) nl_handle=0xffff9adf7050 match=11 multicast=0
nl80211: Register frame type=0xd0 (WLAN_FC_STYPE_ACTION) nl_handle=0xffff9adf7050 match=12 multicast=0
nl80211: Register frame type=0xd0 (WLAN_FC_STYPE_ACTION) nl_handle=0xffff9adf7050 match=7f multicast=0
rfkill: initial event: idx=0 type=1 op=0 soft=0 hard=0
nl80211: Add own interface ifindex 3 (ifidx_reason -1)
nl80211: if_indices[16]: 3(-1)
nl80211: Do not open EAPOL RX socket - using control port for RX
phy: phy0
BSS count 1, BSSID mask 00:00:00:00:00:00 (0 bits)
Using existing control interface directory.
ctrl_iface bind(PF_UNIX) failed: Address in use
ctrl_iface exists, but does not allow connections - assuming it was leftover from forced program termination
Successfully replaced leftover ctrl_iface socket '/var/run/hostapd/wlan0'
nl80211: Regulatory information - country=00
nl80211: 2402-2472 @ 40 MHz 20 mBm
nl80211: 2457-2482 @ 20 MHz 20 mBm (no IR)
nl80211: 2474-2494 @ 20 MHz 20 mBm (no OFDM) (no IR)
nl80211: 5170-5250 @ 80 MHz 20 mBm (no IR)
nl80211: 5250-5330 @ 80 MHz 20 mBm (DFS) (no IR)
nl80211: 5490-5730 @ 160 MHz 20 mBm (DFS) (no IR)
nl80211: 5735-5835 @ 80 MHz 20 mBm (no IR)
nl80211: 57240-63720 @ 2160 MHz 0 mBm
nl80211: Added 802.11b mode based on 802.11g information
nl80211: Mode IEEE 802.11g: 2412 2417 2422 2427 2432 2437 2442 2447 2452 2457 2462 2467[NO_IR] 2472[NO_IR] 2484[NO_IR]
nl80211: Mode IEEE 802.11b: 2412 2417 2422 2427 2432 2437 2442 2447 2452 2457 2462 2467[NO_IR] 2472[NO_IR] 2484[NO_IR]
Allowed channel: mode=1 chan=1 freq=2412 MHz max_tx_power=20 dBm
Allowed channel: mode=1 chan=2 freq=2417 MHz max_tx_power=20 dBm
Allowed channel: mode=1 chan=3 freq=2422 MHz max_tx_power=20 dBm
Allowed channel: mode=1 chan=4 freq=2427 MHz max_tx_power=20 dBm
Allowed channel: mode=1 chan=5 freq=2432 MHz max_tx_power=20 dBm
Allowed channel: mode=1 chan=6 freq=2437 MHz max_tx_power=20 dBm
Allowed channel: mode=1 chan=7 freq=2442 MHz max_tx_power=20 dBm
Allowed channel: mode=1 chan=8 freq=2447 MHz max_tx_power=20 dBm
Allowed channel: mode=1 chan=9 freq=2452 MHz max_tx_power=20 dBm
Allowed channel: mode=1 chan=10 freq=2457 MHz max_tx_power=20 dBm
Allowed channel: mode=1 chan=11 freq=2462 MHz max_tx_power=20 dBm
Allowed channel: mode=0 chan=1 freq=2412 MHz max_tx_power=20 dBm
Allowed channel: mode=0 chan=2 freq=2417 MHz max_tx_power=20 dBm
Allowed channel: mode=0 chan=3 freq=2422 MHz max_tx_power=20 dBm
Allowed channel: mode=0 chan=4 freq=2427 MHz max_tx_power=20 dBm
Allowed channel: mode=0 chan=5 freq=2432 MHz max_tx_power=20 dBm
Allowed channel: mode=0 chan=6 freq=2437 MHz max_tx_power=20 dBm
Allowed channel: mode=0 chan=7 freq=2442 MHz max_tx_power=20 dBm
Allowed channel: mode=0 chan=8 freq=2447 MHz max_tx_power=20 dBm
/home/ilunne # ps aux | grep -iE 'wpa|hostap|network|dhcp'
 1103 dnsmasq   0:00 /usr/sbin/dnsmasq --no-resolv --keep-in-foreground --no-hosts --bind-interfaces --pid-file=/run/NetworkManager/dnsmasq.pid --listen-address=127.0.0.1 --cache-size=400 --clear-on-reload --conf-file=/dev/null --enable-dbus=org.freedesktop.NetworkManager.dnsmasq --conf-dir=/etc/NetworkManager/dnsmasq.d
 1443 root      0:00 unudhcpd -i usb0 -s 172.16.42.1 -c 172.16.42.2
 1747 root      0:00 grep -iE wpa|hostap|network|dhcp
/home/ilunne # cat /usr/local/bin/frankenstein-start.sh
#!/bin/bash

# 1. Limpeza e preparação
killall unudhcpd dnsmasq hostapd 2>/dev/null || true

# 2. Configura IPs das interfaces locais
ip addr add 192.168.10.1/24 dev wlan0 2>/dev/null
ip addr add 172.16.42.1/24 dev usb0 2>/dev/null
ip -6 addr add fd00:42:42::1/64 dev wlan0 2>/dev/null
ip -6 addr add fd00:42:42::1/64 dev usb0 2>/dev/null
ip link set wlan0 up
ip link set usb0 up

# 3. Encaminhamento e Firewall
sysctl -w net.ipv4.ip_forward=1
sysctl -w net.ipv6.conf.all.forwarding=1

nft flush ruleset
nft add table inet filter
nft add chain inet filter input { type filter hook input priority 0 \; policy accept \; }
nft add chain inet filter forward { type filter hook forward priority 0 \; policy accept \; }

# NAT IPv4 via VPN (Casa)
nft add table ip nat
nft add chain ip nat postrouting { type nat hook postrouting priority 100 \; }
nft add rule ip nat postrouting oifname "wg0" masquerade

# NAT IPv6 via Vivo (Direto)
nft add table ip6 nat
nft add chain ip6 nat postrouting { type nat hook postrouting priority 100 \; }
nft add rule ip6 nat postrouting oifname "wwan0" masquerade

# Fix MSS (Obrigatório para 4G/VPN)
nft add rule inet filter forward tcp flags syn tcp option maxseg size set 1300

# 4. Sobe os serviços
/usr/sbin/hostapd -B /etc/hostapd/hostapd.conf
/usr/sbin/dnsmasq -C /etc/dnsmasq.conf

echo "Frankenstein pronto: USB e Wi-Fi online!"
/home/ilunne # systemctl status NetworkManager 2>&1 | head -10
○ NetworkManager.service - Network Manager
     Loaded: loaded (/usr/lib/systemd/system/NetworkManager.service; enabled; preset: enabled)
    Drop-In: /usr/lib/systemd/system/NetworkManager.service.d
             └─NetworkManager-ovs.conf
     Active: inactive (dead) since Mon 2026-04-13 08:08:27 -03; 37s ago
   Duration: 18min 59.034s
 Invocation: 0bc2dffeb879432a9c42765eb8e7d66a
       Docs: man:NetworkManager(8)
    Process: 917 ExecStart=/usr/sbin/NetworkManager --no-daemon (code=exited, status=0/SUCCESS)
   Main PID: 917 (code=exited, status=0/SUCCESS)
/home/ilunne # ps aux | grep -i network
 1103 dnsmasq   0:00 /usr/sbin/dnsmasq --no-resolv --keep-in-foreground --no-hosts --bind-interfaces --pid-file=/run/NetworkManager/dnsmasq.pid --listen-address=127.0.0.1 --cache-size=400 --clear-on-reload --conf-file=/dev/null --enable-dbus=org.freedesktop.NetworkManager.dnsmasq --conf-dir=/etc/NetworkManager/dnsmasq.d
 1756 root      0:00 grep -i network
/home/ilunne # cat /etc/deviceinfo
# Override settings from /usr/share/deviceinfo/deviceinfo with this file.
# After modifying: Some settings require running "mkinitfs" as root and/or
# a reboot to apply.
# Reference: https://postmarketos.org/deviceinfo

# Examples:
# deviceinfo_kernel_cmdline_append=" PMOS_NOSPLASH"
# deviceinfo_usb_network_function="ncm.usb0"
deviceinfo_usb_idVendor="0x0525"
deviceinfo_usb_idProduct="0xa4a1"
deviceinfo_usb_network_function="ncm.usb0"
/home/ilunne #
/home/ilunne #
/home/ilunne #
/home/ilunne #
/home/ilunne #
/home/ilunne #
/home/ilunne #
/home/ilunne #
/home/ilunne #
/home/ilunne #
/home/ilunne #
/home/ilunne #
/home/ilunne #
/home/ilunne #
/home/ilunne #
/home/ilunne #
/home/ilunne #
/home/ilunne #
/home/ilunne #
/home/ilunne #
/home/ilunne #
/home/ilunne #
/home/ilunne #
/home/ilunne #
/home/ilunne #
/home/ilunne #
/home/ilunne #
/home/ilunne #
/home/ilunne #
/home/ilunne #
/home/ilunne #
/home/ilunne #
/home/ilunne #
/home/ilunne #
/home/ilunne #
/home/ilunne #
/home/ilunne #
/home/ilunne #
/home/ilunne #
/home/ilunne #
/home/ilunne #
/home/ilunne #
/home/ilunne #
/home/ilunne #
/home/ilunne #
/home/ilunne #
/home/ilunne #
/home/ilunne #
/home/ilunne #
/home/ilunne #
/home/ilunne #
/home/ilunne #
/home/ilunne #
/home/ilunne #
/home/ilunne #
/home/ilunne #
/home/ilunne #
/home/ilunne #
/home/ilunne #
/home/ilunne #
/home/ilunne #
/home/ilunne #
/home/ilunne #
/home/ilunne #
/home/ilunne #
/home/ilunne #
/home/ilunne #
/home/ilunne #
/home/ilunne #
/home/ilunne # killall hostapd 2>/dev/null
/home/ilunne # hostapd -dd /etc/hostapd/hostapd.conf
random: Trying to read entropy from /dev/random
Configuration file: /etc/hostapd/hostapd.conf
ctrl_interface_group=0
nl80211: Kernel version: Linux 6.12.1-msm8916 (#3 SMP PREEMPT Sun Dec  7 23:30:58 UTC 2025; aarch64)
nl80211: Maximum supported attribute ID: 332
nl80211: Initialize interface wlan0 (driver: wcn36xx)
nl80211: Supported cipher 00-0f-ac:1
nl80211: Supported cipher 00-0f-ac:5
nl80211: Supported cipher 00-0f-ac:2
nl80211: Supported cipher 00-0f-ac:4
nl80211: Using driver-based off-channel TX
nl80211: Driver-advertised extended capabilities (default) - hexdump(len=8): 04 00 00 00 00 00 00 40
nl80211: Driver-advertised extended capabilities mask (default) - hexdump(len=8): 04 00 00 00 00 00 00 40
nl80211: key_mgmt=0x1fd0f enc=0xf auth=0x7 flags=0x40005104b03d0e0 flags2=0x103 rrm_flags=0x10 probe_resp_offloads=0x0 max_stations=0 max_remain_on_chan=5000 max_scan_ssids=9
nl80211: interface wlan0 in phy phy0
nl80211: Set mode ifindex 3 iftype 3 (AP)
nl80211: Setup AP(wlan0) - device_ap_sme=0 use_monitor=0
nl80211: Subscribe to mgmt frames with AP handle 0xffffaeeda040
nl80211: Register frame type=0xb0 (WLAN_FC_STYPE_AUTH) nl_handle=0xffffaeeda040 match= multicast=0
nl80211: Register frame type=0x0 (WLAN_FC_STYPE_ASSOC_REQ) nl_handle=0xffffaeeda040 match= multicast=0
nl80211: Register frame type=0x20 (WLAN_FC_STYPE_REASSOC_REQ) nl_handle=0xffffaeeda040 match= multicast=0
nl80211: Register frame type=0xa0 (WLAN_FC_STYPE_DISASSOC) nl_handle=0xffffaeeda040 match= multicast=0
nl80211: Register frame type=0xc0 (WLAN_FC_STYPE_DEAUTH) nl_handle=0xffffaeeda040 match= multicast=0
nl80211: Register frame type=0x40 (WLAN_FC_STYPE_PROBE_REQ) nl_handle=0xffffaeeda040 match= multicast=0
nl80211: Register frame type=0xd0 (WLAN_FC_STYPE_ACTION) nl_handle=0xffffaeeda040 match=04 multicast=0
nl80211: Register frame type=0xd0 (WLAN_FC_STYPE_ACTION) nl_handle=0xffffaeeda040 match=0501 multicast=0
nl80211: Register frame type=0xd0 (WLAN_FC_STYPE_ACTION) nl_handle=0xffffaeeda040 match=0503 multicast=0
nl80211: Register frame type=0xd0 (WLAN_FC_STYPE_ACTION) nl_handle=0xffffaeeda040 match=0504 multicast=0
nl80211: Register frame type=0xd0 (WLAN_FC_STYPE_ACTION) nl_handle=0xffffaeeda040 match=06 multicast=0
nl80211: Register frame type=0xd0 (WLAN_FC_STYPE_ACTION) nl_handle=0xffffaeeda040 match=08 multicast=0
nl80211: Register frame type=0xd0 (WLAN_FC_STYPE_ACTION) nl_handle=0xffffaeeda040 match=09 multicast=0
nl80211: Register frame type=0xd0 (WLAN_FC_STYPE_ACTION) nl_handle=0xffffaeeda040 match=0a multicast=0
nl80211: Register frame type=0xd0 (WLAN_FC_STYPE_ACTION) nl_handle=0xffffaeeda040 match=11 multicast=0
nl80211: Register frame type=0xd0 (WLAN_FC_STYPE_ACTION) nl_handle=0xffffaeeda040 match=12 multicast=0
nl80211: Register frame type=0xd0 (WLAN_FC_STYPE_ACTION) nl_handle=0xffffaeeda040 match=7f multicast=0
rfkill: initial event: idx=0 type=1 op=0 soft=0 hard=0
nl80211: Add own interface ifindex 3 (ifidx_reason -1)
nl80211: if_indices[16]: 3(-1)
nl80211: Do not open EAPOL RX socket - using control port for RX
phy: phy0
BSS count 1, BSSID mask 00:00:00:00:00:00 (0 bits)
Using existing control interface directory.
ctrl_iface bind(PF_UNIX) failed: Address in use
ctrl_iface exists, but does not allow connections - assuming it was leftover from forced program termination
Successfully replaced leftover ctrl_iface socket '/var/run/hostapd/wlan0'
nl80211: Regulatory information - country=00
nl80211: 2402-2472 @ 40 MHz 20 mBm
nl80211: 2457-2482 @ 20 MHz 20 mBm (no IR)
nl80211: 2474-2494 @ 20 MHz 20 mBm (no OFDM) (no IR)
nl80211: 5170-5250 @ 80 MHz 20 mBm (no IR)
nl80211: 5250-5330 @ 80 MHz 20 mBm (DFS) (no IR)
nl80211: 5490-5730 @ 160 MHz 20 mBm (DFS) (no IR)
nl80211: 5735-5835 @ 80 MHz 20 mBm (no IR)
nl80211: 57240-63720 @ 2160 MHz 0 mBm
nl80211: Added 802.11b mode based on 802.11g information
nl80211: Mode IEEE 802.11g: 2412 2417 2422 2427 2432 2437 2442 2447 2452 2457 2462 2467[NO_IR] 2472[NO_IR] 2484[NO_IR]
nl80211: Mode IEEE 802.11b: 2412 2417 2422 2427 2432 2437 2442 2447 2452 2457 2462 2467[NO_IR] 2472[NO_IR] 2484[NO_IR]
Allowed channel: mode=1 chan=1 freq=2412 MHz max_tx_power=20 dBm
Allowed channel: mode=1 chan=2 freq=2417 MHz max_tx_power=20 dBm
Allowed channel: mode=1 chan=3 freq=2422 MHz max_tx_power=20 dBm
Allowed channel: mode=1 chan=4 freq=2427 MHz max_tx_power=20 dBm
Allowed channel: mode=1 chan=5 freq=2432 MHz max_tx_power=20 dBm
Allowed channel: mode=1 chan=6 freq=2437 MHz max_tx_power=20 dBm
Allowed channel: mode=1 chan=7 freq=2442 MHz max_tx_power=20 dBm
Allowed channel: mode=1 chan=8 freq=2447 MHz max_tx_power=20 dBm
Allowed channel: mode=1 chan=9 freq=2452 MHz max_tx_power=20 dBm
Allowed channel: mode=1 chan=10 freq=2457 MHz max_tx_power=20 dBm
Allowed channel: mode=1 chan=11 freq=2462 MHz max_tx_power=20 dBm
Allowed channel: mode=0 chan=1 freq=2412 MHz max_tx_power=20 dBm
Allowed channel: mode=0 chan=2 freq=2417 MHz max_tx_power=20 dBm
Allowed channel: mode=0 chan=3 freq=2422 MHz max_tx_power=20 dBm
Allowed channel: mode=0 chan=4 freq=2427 MHz max_tx_power=20 dBm
Allowed channel: mode=0 chan=5 freq=2432 MHz max_tx_power=20 dBm
Allowed channel: mode=0 chan=6 freq=2437 MHz max_tx_power=20 dBm
Allowed channel: mode=0 chan=7 freq=2442 MHz max_tx_power=20 dBm
Allowed channel: mode=0 chan=8 freq=2447 MHz max_tx_power=20 dBm
Allowed channel: mode=0 chan=9 freq=2452 MHz max_tx_power=20 dBm
Allowed channel: mode=0 chan=10 freq=2457 MHz max_tx_power=20 dBm
Allowed channel: mode=0 chan=11 freq=2462 MHz max_tx_power=20 dBm
Completing interface initialization
Mode: IEEE 802.11g  Channel: 1  Frequency: 2412 MHz
DFS 0 channels required radar detection
nl80211: Set freq 2412 (ht_enabled=0, vht_enabled=0, he_enabled=0, eht_enabled=0, bandwidth=20 MHz, cf1=2412 MHz, cf2=0 MHz)
  * freq=2412
  * eht_enabled=0
  * he_enabled=0
  * vht_enabled=0
  * ht_enabled=0
  * radar_background=0
  * channel_type=0
RATE[0] rate=10 flags=0x1
RATE[1] rate=20 flags=0x1
RATE[2] rate=55 flags=0x1
RATE[3] rate=110 flags=0x1
RATE[4] rate=60 flags=0x0
RATE[5] rate=90 flags=0x0
RATE[6] rate=120 flags=0x0
RATE[7] rate=180 flags=0x0
RATE[8] rate=240 flags=0x0
RATE[9] rate=360 flags=0x0
RATE[10] rate=480 flags=0x0
RATE[11] rate=540 flags=0x0
hostapd_setup_bss(hapd=0xffffaeedb050 (wlan0), first=1)
nl80211: flush -> DEL_STATION wlan0 (all)
Using interface wlan0 with hwaddr 02:00:44:93:b2:a6 and ssid "test"
Deriving WPA PSK based on passphrase
SSID - hexdump_ascii(len=4):
     74 65 73 74                                       test
PSK (ASCII passphrase) - hexdump_ascii(len=8): [REMOVED]
PSK (from passphrase) - hexdump(len=32): [REMOVED]
random: Got 20/20 random bytes
Get randomness: len=32 entropy=0
GMK - hexdump(len=32): [REMOVED]
Get randomness: len=32 entropy=0
Key Counter - hexdump(len=32): [REMOVED]
WPA: Delay group state machine start until Beacon frames have been configured
VLAN: vlan_set_name_type(name_type=2)
nl80211: Set beacon (beacon_set=0)
nl80211: Beacon head - hexdump(len=55): 80 00 00 00 ff ff ff ff ff ff 02 00 44 93 b2 a6 02 00 44 93 b2 a6 00 00 00 00 00 00 00 00 00 00 64 00 11 04 00 04 74 65 73 74 01 08 82 84 8b 96 0c 12 18 24 03 01 01
nl80211: Beacon tail - hexdump(len=67): 2a 01 04 32 04 30 48 60 6c 30 14 01 00 00 0f ac 04 01 00 00 0f ac 04 01 00 00 0f ac 02 0c 00 7f 08 04 00 00 02 00 00 00 40 dd 18 00 50 f2 02 01 01 01 00 03 a4 00 00 27 a4 00 00 42 43 5e 00 62 32 2f 00
nl80211: ifindex=3
nl80211: beacon_int=100
nl80211: beacon_rate=0
nl80211: rate_type=0
nl80211: dtim_period=2
nl80211: ssid=test
  * beacon_int=100
  * dtim_period=2
nl80211: hidden SSID not in use
nl80211: privacy=2
nl80211: auth_algs=0x3
nl80211: wpa_version=0x2
nl80211: key_mgmt_suites=0x2
nl80211: pairwise_ciphers=0x10
nl80211: group_cipher=0x10
nl80211: beacon_ies - hexdump(len=10): 7f 08 04 00 00 02 00 00 00 40
nl80211: proberesp_ies - hexdump(len=10): 7f 08 04 00 00 02 00 00 00 40
nl80211: assocresp_ies - hexdump(len=10): 7f 08 04 00 00 02 00 00 00 40
  * freq=2412
  * eht_enabled=0
  * he_enabled=0
  * vht_enabled=0
  * ht_enabled=0
  * radar_background=0
  * channel_type=0
nl80211: multicast to unicast disabled on interface wlan0
wlan0: Deauthenticate all stations at BSS start
nl80211: send_mlme - da=ff:ff:ff:ff:ff:ff sa=02:00:44:93:b2:a6 bssid=02:00:44:93:b2:a6 noack=0 freq=0 no_cck=0 offchanok=0 wait_time=0 no_encrypt=0 fc=0xc0 (WLAN_FC_STYPE_DEAUTH) nlmode=3
nl80211: send_mlme - Use bss->freq=2412
nl80211: send_mlme -> send_frame_cmd
nl80211: CMD_FRAME freq=2412 wait=0 no_cck=0 no_ack=0 offchanok=0
CMD_FRAME - hexdump(len=26): c0 00 00 00 ff ff ff ff ff ff 02 00 44 93 b2 a6 02 00 44 93 b2 a6 00 00 02 00
nl80211: Frame TX command accepted; cookie 0xa
nl80211: Set wlan0 operstate 0->1 (UP)
netlink: Operstate: ifindex=3 linkmode=-1 (no change), operstate=6 (IF_OPER_UP)
WPA: Start group state machine to set initial keys
WPA: group state machine entering state GTK_INIT (VLAN-ID 0)
Get randomness: len=16 entropy=0
GTK - hexdump(len=16): [REMOVED]
WPA: group state machine entering state SETKEYSDONE (VLAN-ID 0)
wpa_driver_nl80211_set_key: ifindex=3 (wlan0) alg=3 addr=0xaaaaab23d611 key_idx=1 set_tx=1 seq_len=0 key_len=16 key_flag=0x1a link_id=-1
nl80211: NEW_KEY
nl80211: KEY_DATA - hexdump(len=16): [REMOVED]
   broadcast key
nl80211: NL80211_CMD_SET_KEY - default key
nl80211: link=-1: TX queue param set: queue=0 aifs=1 cw_min=3 cw_max=7 burst_time=15 --> res=-95
Failed to set TX queue parameters for queue 0.
nl80211: link=-1: TX queue param set: queue=1 aifs=1 cw_min=7 cw_max=15 burst_time=30 --> res=-95
Failed to set TX queue parameters for queue 1.
nl80211: link=-1: TX queue param set: queue=2 aifs=3 cw_min=15 cw_max=63 burst_time=0 --> res=-95
Failed to set TX queue parameters for queue 2.
nl80211: link=-1: TX queue param set: queue=3 aifs=7 cw_min=15 cw_max=1023 burst_time=0 --> res=-95
Failed to set TX queue parameters for queue 3.
wlan0: interface state UNINITIALIZED->ENABLED
wlan0: AP-ENABLED
wlan0: Setup of interface done.
ctrl_iface not configured!
VLAN: RTM_NEWLINK: ifi_index=3 ifname=wlan0 ifi_family=0 ifi_flags=0x11043 ([UP][RUNNING][LOWER_UP])
VLAN: vlan_newlink(wlan0)
RTM_NEWLINK: ifi_index=3 ifname=wlan0 operstate=6 linkmode=0 ifi_family=0 ifi_flags=0x11043 ([UP][RUNNING][LOWER_UP])
nl80211: Event message available
nl80211: Drv Event 15 (NL80211_CMD_START_AP) received for wlan0
wlan0: nl80211: Ignored unknown event (cmd=15)
nl80211: Event message available
nl80211: Drv Event 60 (NL80211_CMD_FRAME_TX_STATUS) received for wlan0
nl80211: MLME event 60 (NL80211_CMD_FRAME_TX_STATUS) on wlan0(02:00:44:93:b2:a6) A1=ff:ff:ff:ff:ff:ff A2=02:00:44:93:b2:a6 on link_id=-1
nl80211: MLME event frame - hexdump(len=26): c0 00 00 00 ff ff ff ff ff ff 02 00 44 93 b2 a6 02 00 44 93 b2 a6 00 00 02 00
nl80211: Frame TX status event A1=ff:ff:ff:ff:ff:ff stype=12 cookie=0xa ack=0
wlan0: Event TX_STATUS (16) received
mgmt::deauth cb
nl80211: Event message available
nl80211: BSS Event 59 (NL80211_CMD_FRAME) received for wlan0
nl80211: MLME event 59 (NL80211_CMD_FRAME) on wlan0(02:00:44:93:b2:a6) A1=ff:ff:ff:ff:ff:ff A2=ac:82:47:96:80:d9 on link_id=-1
nl80211: MLME event frame - hexdump(len=91): 40 00 00 00 ff ff ff ff ff ff ac 82 47 96 80 d9 ff ff ff ff ff ff a0 a9 00 00 01 08 02 04 0b 16 0c 12 18 24 32 04 30 48 60 6c 2d 1a e7 09 17 ff ff 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 7f 0a 04 00 88 80 01 40 00 00 00 00 dd 07 50 6f 9a 16 03 01 03
nl80211: Frame event
nl80211: RX frame da=ff:ff:ff:ff:ff:ff sa=ac:82:47:96:80:d9 bssid=ff:ff:ff:ff:ff:ff freq=2412 ssi_signal=-74 fc=0x40 seq_ctrl=0xa9a0 stype=4 (WLAN_FC_STYPE_PROBE_REQ) len=91
nl80211: send_mlme - da=ac:82:47:96:80:d9 sa=02:00:44:93:b2:a6 bssid=02:00:44:93:b2:a6 noack=1 freq=0 no_cck=0 offchanok=0 wait_time=0 no_encrypt=0 fc=0x50 (WLAN_FC_STYPE_PROBE_RESP) nlmode=3
nl80211: send_mlme - Use bss->freq=2412
nl80211: send_mlme -> send_frame_cmd
nl80211: CMD_FRAME freq=2412 wait=0 no_cck=0 no_ack=1 offchanok=0
CMD_FRAME - hexdump(len=122): 50 00 00 00 ac 82 47 96 80 d9 02 00 44 93 b2 a6 02 00 44 93 b2 a6 00 00 00 00 00 00 00 00 00 00 64 00 11 04 00 04 74 65 73 74 01 08 82 84 8b 96 0c 12 18 24 03 01 01 2a 01 04 32 04 30 48 60 6c 30 14 01 00 00 0f ac 04 01 00 00 0f ac 04 01 00 00 0f ac 02 0c 00 7f 08 04 00 00 02 00 00 00 40 dd 18 00 50 f2 02 01 01 01 00 03 a4 00 00 27 a4 00 00 42 43 5e 00 62 32 2f 00
nl80211: Frame TX command accepted (no ACK); cookie 0x0
nl80211: Event message available
nl80211: BSS Event 59 (NL80211_CMD_FRAME) received for wlan0
nl80211: MLME event 59 (NL80211_CMD_FRAME) on wlan0(02:00:44:93:b2:a6) A1=ff:ff:ff:ff:ff:ff A2=70:2a:d5:c6:cc:bf on link_id=-1
nl80211: MLME event frame - hexdump(len=70): 40 00 00 00 ff ff ff ff ff ff 70 2a d5 c6 cc bf ff ff ff ff ff ff f0 99 00 00 01 08 82 84 8b 0c 12 96 18 24 32 04 30 48 60 6c 2d 1a ac 01 02 ff ff 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
nl80211: Frame event
nl80211: RX frame da=ff:ff:ff:ff:ff:ff sa=70:2a:d5:c6:cc:bf bssid=ff:ff:ff:ff:ff:ff freq=2412 ssi_signal=-74 fc=0x40 seq_ctrl=0x99f0 stype=4 (WLAN_FC_STYPE_PROBE_REQ) len=70
nl80211: send_mlme - da=70:2a:d5:c6:cc:bf sa=02:00:44:93:b2:a6 bssid=02:00:44:93:b2:a6 noack=1 freq=0 no_cck=0 offchanok=0 wait_time=0 no_encrypt=0 fc=0x50 (WLAN_FC_STYPE_PROBE_RESP) nlmode=3
nl80211: send_mlme - Use bss->freq=2412
nl80211: send_mlme -> send_frame_cmd
nl80211: CMD_FRAME freq=2412 wait=0 no_cck=0 no_ack=1 offchanok=0
CMD_FRAME - hexdump(len=122): 50 00 00 00 70 2a d5 c6 cc bf 02 00 44 93 b2 a6 02 00 44 93 b2 a6 00 00 00 00 00 00 00 00 00 00 64 00 11 04 00 04 74 65 73 74 01 08 82 84 8b 96 0c 12 18 24 03 01 01 2a 01 04 32 04 30 48 60 6c 30 14 01 00 00 0f ac 04 01 00 00 0f ac 04 01 00 00 0f ac 02 0c 00 7f 08 04 00 00 02 00 00 00 40 dd 18 00 50 f2 02 01 01 01 00 03 a4 00 00 27 a4 00 00 42 43 5e 00 62 32 2f 00
nl80211: Frame TX command accepted (no ACK); cookie 0x0
nl80211: Event message available
nl80211: BSS Event 59 (NL80211_CMD_FRAME) received for wlan0
nl80211: MLME event 59 (NL80211_CMD_FRAME) on wlan0(02:00:44:93:b2:a6) A1=ff:ff:ff:ff:ff:ff A2=28:66:e3:d1:73:1d on link_id=-1
nl80211: MLME event frame - hexdump(len=48): 40 00 00 00 ff ff ff ff ff ff 28 66 e3 d1 73 1d ff ff ff ff ff ff 50 94 00 06 73 67 63 5f 35 67 01 08 82 84 8b 96 0c 12 18 24 32 04 30 48 60 6c
nl80211: Frame event
nl80211: RX frame da=ff:ff:ff:ff:ff:ff sa=28:66:e3:d1:73:1d bssid=ff:ff:ff:ff:ff:ff freq=2412 ssi_signal=-74 fc=0x40 seq_ctrl=0x9450 stype=4 (WLAN_FC_STYPE_PROBE_REQ) len=48
nl80211: Event message available
nl80211: BSS Event 59 (NL80211_CMD_FRAME) received for wlan0
nl80211: MLME event 59 (NL80211_CMD_FRAME) on wlan0(02:00:44:93:b2:a6) A1=ff:ff:ff:ff:ff:ff A2=7c:b5:66:c3:fa:2d on link_id=-1
nl80211: MLME event frame - hexdump(len=135): 40 00 00 00 ff ff ff ff ff ff 7c b5 66 c3 fa 2d ff ff ff ff ff ff 60 e5 00 00 01 08 02 04 0b 16 0c 12 18 24 32 04 30 48 60 6c 2d 1a e7 09 17 ff ff 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 7f 0e 04 00 48 80 00 40 00 80 01 00 00 00 00 00 ff 1e 23 01 78 20 0a c0 ab 0e 30 42 00 fd 09 8c 0e 0f fe 00 fa ff fa ff fa ff fa ff 61 1c c7 71 ff 03 02 00 0b dd 0a 50 6f 9a 16 03 01 03 65 01 01
nl80211: Frame event
nl80211: RX frame da=ff:ff:ff:ff:ff:ff sa=7c:b5:66:c3:fa:2d bssid=ff:ff:ff:ff:ff:ff freq=2412 ssi_signal=-33 fc=0x40 seq_ctrl=0xe560 stype=4 (WLAN_FC_STYPE_PROBE_REQ) len=135
nl80211: send_mlme - da=7c:b5:66:c3:fa:2d sa=02:00:44:93:b2:a6 bssid=02:00:44:93:b2:a6 noack=1 freq=0 no_cck=0 offchanok=0 wait_time=0 no_encrypt=0 fc=0x50 (WLAN_FC_STYPE_PROBE_RESP) nlmode=3
nl80211: send_mlme - Use bss->freq=2412
nl80211: send_mlme -> send_frame_cmd
nl80211: CMD_FRAME freq=2412 wait=0 no_cck=0 no_ack=1 offchanok=0
CMD_FRAME - hexdump(len=122): 50 00 00 00 7c b5 66 c3 fa 2d 02 00 44 93 b2 a6 02 00 44 93 b2 a6 00 00 00 00 00 00 00 00 00 00 64 00 11 04 00 04 74 65 73 74 01 08 82 84 8b 96 0c 12 18 24 03 01 01 2a 01 04 32 04 30 48 60 6c 30 14 01 00 00 0f ac 04 01 00 00 0f ac 04 01 00 00 0f ac 02 0c 00 7f 08 04 00 00 02 00 00 00 40 dd 18 00 50 f2 02 01 01 01 00 03 a4 00 00 27 a4 00 00 42 43 5e 00 62 32 2f 00
nl80211: Frame TX command accepted (no ACK); cookie 0x0
nl80211: Event message available
nl80211: BSS Event 59 (NL80211_CMD_FRAME) received for wlan0
nl80211: MLME event 59 (NL80211_CMD_FRAME) on wlan0(02:00:44:93:b2:a6) A1=ff:ff:ff:ff:ff:ff A2=4a:7e:3a:86:c4:e6 on link_id=-1
nl80211: MLME event frame - hexdump(len=73): 40 00 00 00 ff ff ff ff ff ff 4a 7e 3a 86 c4 e6 ff ff ff ff ff ff e0 bc 00 00 01 08 82 84 8b 96 0c 12 18 24 32 04 30 48 60 6c 03 01 01 2d 1a 6f 10 03 ff ff 00 00 00 00 00 00 00 00 db 78 e8 85 ee 0d 00 00 00 00 00 00 00
nl80211: Frame event
nl80211: RX frame da=ff:ff:ff:ff:ff:ff sa=4a:7e:3a:86:c4:e6 bssid=ff:ff:ff:ff:ff:ff freq=2412 ssi_signal=-68 fc=0x40 seq_ctrl=0xbce0 stype=4 (WLAN_FC_STYPE_PROBE_REQ) len=73
nl80211: send_mlme - da=4a:7e:3a:86:c4:e6 sa=02:00:44:93:b2:a6 bssid=02:00:44:93:b2:a6 noack=1 freq=0 no_cck=0 offchanok=0 wait_time=0 no_encrypt=0 fc=0x50 (WLAN_FC_STYPE_PROBE_RESP) nlmode=3
nl80211: send_mlme - Use bss->freq=2412
nl80211: send_mlme -> send_frame_cmd
nl80211: CMD_FRAME freq=2412 wait=0 no_cck=0 no_ack=1 offchanok=0
CMD_FRAME - hexdump(len=122): 50 00 00 00 4a 7e 3a 86 c4 e6 02 00 44 93 b2 a6 02 00 44 93 b2 a6 00 00 00 00 00 00 00 00 00 00 64 00 11 04 00 04 74 65 73 74 01 08 82 84 8b 96 0c 12 18 24 03 01 01 2a 01 04 32 04 30 48 60 6c 30 14 01 00 00 0f ac 04 01 00 00 0f ac 04 01 00 00 0f ac 02 0c 00 7f 08 04 00 00 02 00 00 00 40 dd 18 00 50 f2 02 01 01 01 00 03 a4 00 00 27 a4 00 00 42 43 5e 00 62 32 2f 00
nl80211: Frame TX command accepted (no ACK); cookie 0x0
nl80211: Event message available
nl80211: BSS Event 59 (NL80211_CMD_FRAME) received for wlan0
nl80211: MLME event 59 (NL80211_CMD_FRAME) on wlan0(02:00:44:93:b2:a6) A1=ff:ff:ff:ff:ff:ff A2=28:66:e3:d1:73:1d on link_id=-1
nl80211: MLME event frame - hexdump(len=42): 40 00 00 00 ff ff ff ff ff ff 28 66 e3 d1 73 1d ff ff ff ff ff ff 10 97 00 00 01 08 82 84 8b 96 0c 12 18 24 32 04 30 48 60 6c
nl80211: Frame event
nl80211: RX frame da=ff:ff:ff:ff:ff:ff sa=28:66:e3:d1:73:1d bssid=ff:ff:ff:ff:ff:ff freq=2412 ssi_signal=-74 fc=0x40 seq_ctrl=0x9710 stype=4 (WLAN_FC_STYPE_PROBE_REQ) len=42
nl80211: send_mlme - da=28:66:e3:d1:73:1d sa=02:00:44:93:b2:a6 bssid=02:00:44:93:b2:a6 noack=1 freq=0 no_cck=0 offchanok=0 wait_time=0 no_encrypt=0 fc=0x50 (WLAN_FC_STYPE_PROBE_RESP) nlmode=3
nl80211: send_mlme - Use bss->freq=2412
nl80211: send_mlme -> send_frame_cmd
nl80211: CMD_FRAME freq=2412 wait=0 no_cck=0 no_ack=1 offchanok=0
CMD_FRAME - hexdump(len=122): 50 00 00 00 28 66 e3 d1 73 1d 02 00 44 93 b2 a6 02 00 44 93 b2 a6 00 00 00 00 00 00 00 00 00 00 64 00 11 04 00 04 74 65 73 74 01 08 82 84 8b 96 0c 12 18 24 03 01 01 2a 01 04 32 04 30 48 60 6c 30 14 01 00 00 0f ac 04 01 00 00 0f ac 04 01 00 00 0f ac 02 0c 00 7f 08 04 00 00 02 00 00 00 40 dd 18 00 50 f2 02 01 01 01 00 03 a4 00 00 27 a4 00 00 42 43 5e 00 62 32 2f 00
nl80211: Frame TX command accepted (no ACK); cookie 0x0
nl80211: Event message available
nl80211: BSS Event 59 (NL80211_CMD_FRAME) received for wlan0
nl80211: MLME event 59 (NL80211_CMD_FRAME) on wlan0(02:00:44:93:b2:a6) A1=ff:ff:ff:ff:ff:ff A2=d4:f5:47:a3:34:d1 on link_id=-1
nl80211: MLME event frame - hexdump(len=139): 40 00 00 00 ff ff ff ff ff ff d4 f5 47 a3 34 d1 ff ff ff ff ff ff e0 a1 00 07 4a 61 67 75 61 72 5f 01 08 02 04 0b 0c 12 16 18 24 03 01 01 2d 1a 6f 01 03 00 00 00 00 01 00 00 00 00 00 00 00 00 00 00 00 00 00 08 46 e7 19 00 32 04 30 48 60 6c 3b 16 80 01 02 03 04 05 0c 16 17 18 19 1a 1b 1c 1d 1e 1f 20 21 80 81 82 7f 0a 04 00 00 00 21 00 00 40 00 00 bf 0c 30 71 d0 33 fe ff 86 01 fe ff 86 01 dd 07 00 50 f2 08 00 0f 00
nl80211: Frame event
nl80211: RX frame da=ff:ff:ff:ff:ff:ff sa=d4:f5:47:a3:34:d1 bssid=ff:ff:ff:ff:ff:ff freq=2412 ssi_signal=-65 fc=0x40 seq_ctrl=0xa1e0 stype=4 (WLAN_FC_STYPE_PROBE_REQ) len=139
nl80211: Event message available
nl80211: BSS Event 59 (NL80211_CMD_FRAME) received for wlan0
nl80211: MLME event 59 (NL80211_CMD_FRAME) on wlan0(02:00:44:93:b2:a6) A1=ff:ff:ff:ff:ff:ff A2=d4:f5:47:a3:34:d1 on link_id=-1
nl80211: MLME event frame - hexdump(len=139): 40 00 00 00 ff ff ff ff ff ff d4 f5 47 a3 34 d1 ff ff ff ff ff ff 10 a2 00 07 4a 61 67 75 61 72 5f 01 08 02 04 0b 0c 12 16 18 24 03 01 01 2d 1a 6f 01 03 00 00 00 00 01 00 00 00 00 00 00 00 00 00 00 00 00 00 08 46 e7 19 00 32 04 30 48 60 6c 3b 16 80 01 02 03 04 05 0c 16 17 18 19 1a 1b 1c 1d 1e 1f 20 21 80 81 82 7f 0a 04 00 00 00 21 00 00 40 00 00 bf 0c 30 71 d0 33 fe ff 86 01 fe ff 86 01 dd 07 00 50 f2 08 00 0f 00
nl80211: Frame event
nl80211: RX frame da=ff:ff:ff:ff:ff:ff sa=d4:f5:47:a3:34:d1 bssid=ff:ff:ff:ff:ff:ff freq=2412 ssi_signal=-72 fc=0x40 seq_ctrl=0xa210 stype=4 (WLAN_FC_STYPE_PROBE_REQ) len=139
^CSignal 2 received - terminating
hostapd_interface_deinit_free(0xffffaeedc030)
hostapd_interface_deinit_free: num_bss=1 conf->num_bss=1
hostapd_interface_deinit(0xffffaeedc030)
wlan0: interface state ENABLED->DISABLED
hostapd_bss_deinit: deinit bss wlan0
wlan0: Deauthenticate all stations
nl80211: send_mlme - da=ff:ff:ff:ff:ff:ff sa=02:00:44:93:b2:a6 bssid=02:00:44:93:b2:a6 noack=0 freq=0 no_cck=0 offchanok=0 wait_time=0 no_encrypt=0 fc=0xc0 (WLAN_FC_STYPE_DEAUTH) nlmode=3
nl80211: send_mlme - Use bss->freq=2412
nl80211: send_mlme -> send_frame_cmd
nl80211: CMD_FRAME freq=2412 wait=0 no_cck=0 no_ack=0 offchanok=0
CMD_FRAME - hexdump(len=26): c0 00 00 00 ff ff ff ff ff ff 02 00 44 93 b2 a6 02 00 44 93 b2 a6 00 00 03 00
nl80211: Frame TX command accepted; cookie 0xb
wlan0: AP-DISABLED
hostapd_cleanup(hapd=0xffffaeedb050 (wlan0))
wlan0: CTRL-EVENT-TERMINATING
hostapd_free_hapd_data(wlan0)
hostapd_interface_deinit_free: driver=0xaaaaab2aceb8 drv_priv=0xffffaee22720 -> hapd_deinit
nl80211: deinit ifname=wlan0 disabled_11b_rates=0
nl80211: Remove monitor interface: refcount=0
nl80211: Remove beacon (ifindex=3)
netlink: Operstate: ifindex=3 linkmode=0 (kernel-control), operstate=6 (IF_OPER_UP)
nl80211: Unsubscribe mgmt frames handle 0xffff266528c9 (deinit)
hostapd_interface_free(0xffffaeedc030)
hostapd_interface_free: free hapd 0xffffaeedb050
hostapd_cleanup_iface(0xffffaeedc030)
hostapd_cleanup_iface_partial(0xffffaeedc030)
hostapd_cleanup_iface: free iface=0xffffaeedc030
/home/ilunne # cat /etc/dnsmasq.conf
# Não trava se uma interface sumir (importante para o USB)
bind-dynamic

# Range para o Wi-Fi
interface=wlan0
dhcp-range=wlan0,192.168.10.10,192.168.10.50,12h

# Range para o USB (ajuste se seu IP de rede USB for outro)
interface=usb0
dhcp-range=usb0,172.16.42.10,172.16.42.50,12h

# DNS para os clientes
dhcp-option=6,8.8.8.8,8.8.4.4

# IPv6 via NAT66 (Já que não temos ndppd)
enable-ra
dhcp-range=fd00:42:42::10,fd00:42:42::50,64,12h

port=0
/home/ilunne # hostapd -dd /etc/hostapd/hostapd.conf
random: Trying to read entropy from /dev/random
Configuration file: /etc/hostapd/hostapd.conf
ctrl_interface_group=0
nl80211: Kernel version: Linux 6.12.1-msm8916 (#3 SMP PREEMPT Sun Dec  7 23:30:58 UTC 2025; aarch64)
nl80211: Maximum supported attribute ID: 332
nl80211: Initialize interface wlan0 (driver: wcn36xx)
nl80211: Supported cipher 00-0f-ac:1
nl80211: Supported cipher 00-0f-ac:5
nl80211: Supported cipher 00-0f-ac:2
nl80211: Supported cipher 00-0f-ac:4
nl80211: Using driver-based off-channel TX
nl80211: Driver-advertised extended capabilities (default) - hexdump(len=8): 04 00 00 00 00 00 00 40
nl80211: Driver-advertised extended capabilities mask (default) - hexdump(len=8): 04 00 00 00 00 00 00 40
nl80211: key_mgmt=0x1fd0f enc=0xf auth=0x7 flags=0x40005104b03d0e0 flags2=0x103 rrm_flags=0x10 probe_resp_offloads=0x0 max_stations=0 max_remain_on_chan=5000 max_scan_ssids=9
nl80211: interface wlan0 in phy phy0
nl80211: Set mode ifindex 3 iftype 3 (AP)
nl80211: Setup AP(wlan0) - device_ap_sme=0 use_monitor=0
nl80211: Subscribe to mgmt frames with AP handle 0xffff8e528040
nl80211: Register frame type=0xb0 (WLAN_FC_STYPE_AUTH) nl_handle=0xffff8e528040 match= multicast=0
nl80211: Register frame type=0x0 (WLAN_FC_STYPE_ASSOC_REQ) nl_handle=0xffff8e528040 match= multicast=0
nl80211: Register frame type=0x20 (WLAN_FC_STYPE_REASSOC_REQ) nl_handle=0xffff8e528040 match= multicast=0
nl80211: Register frame type=0xa0 (WLAN_FC_STYPE_DISASSOC) nl_handle=0xffff8e528040 match= multicast=0
nl80211: Register frame type=0xc0 (WLAN_FC_STYPE_DEAUTH) nl_handle=0xffff8e528040 match= multicast=0
nl80211: Register frame type=0x40 (WLAN_FC_STYPE_PROBE_REQ) nl_handle=0xffff8e528040 match= multicast=0
nl80211: Register frame type=0xd0 (WLAN_FC_STYPE_ACTION) nl_handle=0xffff8e528040 match=04 multicast=0
nl80211: Register frame type=0xd0 (WLAN_FC_STYPE_ACTION) nl_handle=0xffff8e528040 match=0501 multicast=0
nl80211: Register frame type=0xd0 (WLAN_FC_STYPE_ACTION) nl_handle=0xffff8e528040 match=0503 multicast=0
nl80211: Register frame type=0xd0 (WLAN_FC_STYPE_ACTION) nl_handle=0xffff8e528040 match=0504 multicast=0
nl80211: Register frame type=0xd0 (WLAN_FC_STYPE_ACTION) nl_handle=0xffff8e528040 match=06 multicast=0
nl80211: Register frame type=0xd0 (WLAN_FC_STYPE_ACTION) nl_handle=0xffff8e528040 match=08 multicast=0
nl80211: Register frame type=0xd0 (WLAN_FC_STYPE_ACTION) nl_handle=0xffff8e528040 match=09 multicast=0
nl80211: Register frame type=0xd0 (WLAN_FC_STYPE_ACTION) nl_handle=0xffff8e528040 match=0a multicast=0
nl80211: Register frame type=0xd0 (WLAN_FC_STYPE_ACTION) nl_handle=0xffff8e528040 match=11 multicast=0
nl80211: Register frame type=0xd0 (WLAN_FC_STYPE_ACTION) nl_handle=0xffff8e528040 match=12 multicast=0
nl80211: Register frame type=0xd0 (WLAN_FC_STYPE_ACTION) nl_handle=0xffff8e528040 match=7f multicast=0
rfkill: initial event: idx=0 type=1 op=0 soft=0 hard=0
nl80211: Add own interface ifindex 3 (ifidx_reason -1)
nl80211: if_indices[16]: 3(-1)
nl80211: Do not open EAPOL RX socket - using control port for RX
phy: phy0
BSS count 1, BSSID mask 00:00:00:00:00:00 (0 bits)
nl80211: Regulatory information - country=00
nl80211: 2402-2472 @ 40 MHz 20 mBm
nl80211: 2457-2482 @ 20 MHz 20 mBm (no IR)
nl80211: 2474-2494 @ 20 MHz 20 mBm (no OFDM) (no IR)
nl80211: 5170-5250 @ 80 MHz 20 mBm (no IR)
nl80211: 5250-5330 @ 80 MHz 20 mBm (DFS) (no IR)
nl80211: 5490-5730 @ 160 MHz 20 mBm (DFS) (no IR)
nl80211: 5735-5835 @ 80 MHz 20 mBm (no IR)
nl80211: 57240-63720 @ 2160 MHz 0 mBm
nl80211: Added 802.11b mode based on 802.11g information
nl80211: Mode IEEE 802.11g: 2412 2417 2422 2427 2432 2437 2442 2447 2452 2457 2462 2467[NO_IR] 2472[NO_IR] 2484[NO_IR]
nl80211: Mode IEEE 802.11b: 2412 2417 2422 2427 2432 2437 2442 2447 2452 2457 2462 2467[NO_IR] 2472[NO_IR] 2484[NO_IR]
Allowed channel: mode=1 chan=1 freq=2412 MHz max_tx_power=20 dBm
Allowed channel: mode=1 chan=2 freq=2417 MHz max_tx_power=20 dBm
Allowed channel: mode=1 chan=3 freq=2422 MHz max_tx_power=20 dBm
Allowed channel: mode=1 chan=4 freq=2427 MHz max_tx_power=20 dBm
Allowed channel: mode=1 chan=5 freq=2432 MHz max_tx_power=20 dBm
Allowed channel: mode=1 chan=6 freq=2437 MHz max_tx_power=20 dBm
Allowed channel: mode=1 chan=7 freq=2442 MHz max_tx_power=20 dBm
Allowed channel: mode=1 chan=8 freq=2447 MHz max_tx_power=20 dBm
Allowed channel: mode=1 chan=9 freq=2452 MHz max_tx_power=20 dBm
Allowed channel: mode=1 chan=10 freq=2457 MHz max_tx_power=20 dBm
Allowed channel: mode=1 chan=11 freq=2462 MHz max_tx_power=20 dBm
Allowed channel: mode=0 chan=1 freq=2412 MHz max_tx_power=20 dBm
Allowed channel: mode=0 chan=2 freq=2417 MHz max_tx_power=20 dBm
Allowed channel: mode=0 chan=3 freq=2422 MHz max_tx_power=20 dBm
Allowed channel: mode=0 chan=4 freq=2427 MHz max_tx_power=20 dBm
Allowed channel: mode=0 chan=5 freq=2432 MHz max_tx_power=20 dBm
Allowed channel: mode=0 chan=6 freq=2437 MHz max_tx_power=20 dBm
Allowed channel: mode=0 chan=7 freq=2442 MHz max_tx_power=20 dBm
Allowed channel: mode=0 chan=8 freq=2447 MHz max_tx_power=20 dBm
Allowed channel: mode=0 chan=9 freq=2452 MHz max_tx_power=20 dBm
Allowed channel: mode=0 chan=10 freq=2457 MHz max_tx_power=20 dBm
Allowed channel: mode=0 chan=11 freq=2462 MHz max_tx_power=20 dBm
Completing interface initialization
Mode: IEEE 802.11g  Channel: 1  Frequency: 2412 MHz
DFS 0 channels required radar detection
nl80211: Set freq 2412 (ht_enabled=0, vht_enabled=0, he_enabled=0, eht_enabled=0, bandwidth=20 MHz, cf1=2412 MHz, cf2=0 MHz)
  * freq=2412
  * eht_enabled=0
  * he_enabled=0
  * vht_enabled=0
  * ht_enabled=0
  * radar_background=0
  * channel_type=0
RATE[0] rate=10 flags=0x1
RATE[1] rate=20 flags=0x1
RATE[2] rate=55 flags=0x1
RATE[3] rate=110 flags=0x1
RATE[4] rate=60 flags=0x0
RATE[5] rate=90 flags=0x0
RATE[6] rate=120 flags=0x0
RATE[7] rate=180 flags=0x0
RATE[8] rate=240 flags=0x0
RATE[9] rate=360 flags=0x0
RATE[10] rate=480 flags=0x0
RATE[11] rate=540 flags=0x0
hostapd_setup_bss(hapd=0xffff8e529050 (wlan0), first=1)
nl80211: flush -> DEL_STATION wlan0 (all)
Using interface wlan0 with hwaddr 02:00:44:93:b2:a6 and ssid "test"
Deriving WPA PSK based on passphrase
SSID - hexdump_ascii(len=4):
     74 65 73 74                                       test
PSK (ASCII passphrase) - hexdump_ascii(len=8): [REMOVED]
PSK (from passphrase) - hexdump(len=32): [REMOVED]
random: Got 20/20 random bytes
Get randomness: len=32 entropy=0
GMK - hexdump(len=32): [REMOVED]
Get randomness: len=32 entropy=0
Key Counter - hexdump(len=32): [REMOVED]
WPA: Delay group state machine start until Beacon frames have been configured
VLAN: vlan_set_name_type(name_type=2)
nl80211: Set beacon (beacon_set=0)
nl80211: Beacon head - hexdump(len=55): 80 00 00 00 ff ff ff ff ff ff 02 00 44 93 b2 a6 02 00 44 93 b2 a6 00 00 00 00 00 00 00 00 00 00 64 00 11 04 00 04 74 65 73 74 01 08 82 84 8b 96 0c 12 18 24 03 01 01
nl80211: Beacon tail - hexdump(len=67): 2a 01 04 32 04 30 48 60 6c 30 14 01 00 00 0f ac 04 01 00 00 0f ac 04 01 00 00 0f ac 02 0c 00 7f 08 04 00 00 02 00 00 00 40 dd 18 00 50 f2 02 01 01 01 00 03 a4 00 00 27 a4 00 00 42 43 5e 00 62 32 2f 00
nl80211: ifindex=3
nl80211: beacon_int=100
nl80211: beacon_rate=0
nl80211: rate_type=0
nl80211: dtim_period=2
nl80211: ssid=test
  * beacon_int=100
  * dtim_period=2
nl80211: hidden SSID not in use
nl80211: privacy=2
nl80211: auth_algs=0x3
nl80211: wpa_version=0x2
nl80211: key_mgmt_suites=0x2
nl80211: pairwise_ciphers=0x10
nl80211: group_cipher=0x10
nl80211: beacon_ies - hexdump(len=10): 7f 08 04 00 00 02 00 00 00 40
nl80211: proberesp_ies - hexdump(len=10): 7f 08 04 00 00 02 00 00 00 40
nl80211: assocresp_ies - hexdump(len=10): 7f 08 04 00 00 02 00 00 00 40
  * freq=2412
  * eht_enabled=0
  * he_enabled=0
  * vht_enabled=0
  * ht_enabled=0
  * radar_background=0
  * channel_type=0
nl80211: multicast to unicast disabled on interface wlan0
wlan0: Deauthenticate all stations at BSS start
nl80211: send_mlme - da=ff:ff:ff:ff:ff:ff sa=02:00:44:93:b2:a6 bssid=02:00:44:93:b2:a6 noack=0 freq=0 no_cck=0 offchanok=0 wait_time=0 no_encrypt=0 fc=0xc0 (WLAN_FC_STYPE_DEAUTH) nlmode=3
nl80211: send_mlme - Use bss->freq=2412
nl80211: send_mlme -> send_frame_cmd
nl80211: CMD_FRAME freq=2412 wait=0 no_cck=0 no_ack=0 offchanok=0
CMD_FRAME - hexdump(len=26): c0 00 00 00 ff ff ff ff ff ff 02 00 44 93 b2 a6 02 00 44 93 b2 a6 00 00 02 00
nl80211: Frame TX command accepted; cookie 0xc
nl80211: Set wlan0 operstate 0->1 (UP)
netlink: Operstate: ifindex=3 linkmode=-1 (no change), operstate=6 (IF_OPER_UP)
WPA: Start group state machine to set initial keys
WPA: group state machine entering state GTK_INIT (VLAN-ID 0)
Get randomness: len=16 entropy=0
GTK - hexdump(len=16): [REMOVED]
WPA: group state machine entering state SETKEYSDONE (VLAN-ID 0)
wpa_driver_nl80211_set_key: ifindex=3 (wlan0) alg=3 addr=0xaaaade77d611 key_idx=1 set_tx=1 seq_len=0 key_len=16 key_flag=0x1a link_id=-1
nl80211: NEW_KEY
nl80211: KEY_DATA - hexdump(len=16): [REMOVED]
   broadcast key
nl80211: NL80211_CMD_SET_KEY - default key
nl80211: link=-1: TX queue param set: queue=0 aifs=1 cw_min=3 cw_max=7 burst_time=15 --> res=-95
Failed to set TX queue parameters for queue 0.
nl80211: link=-1: TX queue param set: queue=1 aifs=1 cw_min=7 cw_max=15 burst_time=30 --> res=-95
Failed to set TX queue parameters for queue 1.
nl80211: link=-1: TX queue param set: queue=2 aifs=3 cw_min=15 cw_max=63 burst_time=0 --> res=-95
Failed to set TX queue parameters for queue 2.
nl80211: link=-1: TX queue param set: queue=3 aifs=7 cw_min=15 cw_max=1023 burst_time=0 --> res=-95
Failed to set TX queue parameters for queue 3.
wlan0: interface state UNINITIALIZED->ENABLED
wlan0: AP-ENABLED
wlan0: Setup of interface done.
ctrl_iface not configured!
nl80211: Event message available
nl80211: Drv Event 15 (NL80211_CMD_START_AP) received for wlan0
wlan0: nl80211: Ignored unknown event (cmd=15)
VLAN: RTM_NEWLINK: ifi_index=3 ifname=wlan0 ifi_family=0 ifi_flags=0x11043 ([UP][RUNNING][LOWER_UP])
VLAN: vlan_newlink(wlan0)
RTM_NEWLINK: ifi_index=3 ifname=wlan0 operstate=6 linkmode=0 ifi_family=0 ifi_flags=0x11043 ([UP][RUNNING][LOWER_UP])
nl80211: Event message available
nl80211: Drv Event 60 (NL80211_CMD_FRAME_TX_STATUS) received for wlan0
nl80211: MLME event 60 (NL80211_CMD_FRAME_TX_STATUS) on wlan0(02:00:44:93:b2:a6) A1=ff:ff:ff:ff:ff:ff A2=02:00:44:93:b2:a6 on link_id=-1
nl80211: MLME event frame - hexdump(len=26): c0 00 00 00 ff ff ff ff ff ff 02 00 44 93 b2 a6 02 00 44 93 b2 a6 00 00 02 00
nl80211: Frame TX status event A1=ff:ff:ff:ff:ff:ff stype=12 cookie=0xc ack=0
wlan0: Event TX_STATUS (16) received
mgmt::deauth cb
nl80211: Event message available
nl80211: BSS Event 59 (NL80211_CMD_FRAME) received for wlan0
nl80211: MLME event 59 (NL80211_CMD_FRAME) on wlan0(02:00:44:93:b2:a6) A1=ff:ff:ff:ff:ff:ff A2=7c:b5:66:c3:fa:2d on link_id=-1
nl80211: MLME event frame - hexdump(len=135): 40 00 00 00 ff ff ff ff ff ff 7c b5 66 c3 fa 2d ff ff ff ff ff ff 90 e7 00 00 01 08 02 04 0b 16 0c 12 18 24 32 04 30 48 60 6c 2d 1a e7 09 17 ff ff 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 7f 0e 04 00 48 80 00 40 00 80 01 00 00 00 00 00 ff 1e 23 01 78 20 0a c0 ab 0e 30 42 00 fd 09 8c 0e 0f fe 00 fa ff fa ff fa ff fa ff 61 1c c7 71 ff 03 02 00 10 dd 0a 50 6f 9a 16 03 01 03 65 01 01
nl80211: Frame event
nl80211: RX frame da=ff:ff:ff:ff:ff:ff sa=7c:b5:66:c3:fa:2d bssid=ff:ff:ff:ff:ff:ff freq=2412 ssi_signal=-36 fc=0x40 seq_ctrl=0xe790 stype=4 (WLAN_FC_STYPE_PROBE_REQ) len=135
nl80211: send_mlme - da=7c:b5:66:c3:fa:2d sa=02:00:44:93:b2:a6 bssid=02:00:44:93:b2:a6 noack=1 freq=0 no_cck=0 offchanok=0 wait_time=0 no_encrypt=0 fc=0x50 (WLAN_FC_STYPE_PROBE_RESP) nlmode=3
nl80211: send_mlme - Use bss->freq=2412
nl80211: send_mlme -> send_frame_cmd
nl80211: CMD_FRAME freq=2412 wait=0 no_cck=0 no_ack=1 offchanok=0
CMD_FRAME - hexdump(len=122): 50 00 00 00 7c b5 66 c3 fa 2d 02 00 44 93 b2 a6 02 00 44 93 b2 a6 00 00 00 00 00 00 00 00 00 00 64 00 11 04 00 04 74 65 73 74 01 08 82 84 8b 96 0c 12 18 24 03 01 01 2a 01 04 32 04 30 48 60 6c 30 14 01 00 00 0f ac 04 01 00 00 0f ac 04 01 00 00 0f ac 02 0c 00 7f 08 04 00 00 02 00 00 00 40 dd 18 00 50 f2 02 01 01 01 00 03 a4 00 00 27 a4 00 00 42 43 5e 00 62 32 2f 00
nl80211: Frame TX command accepted (no ACK); cookie 0x0
