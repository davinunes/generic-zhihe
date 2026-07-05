#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# Frankenstein Web Admin Dashboard
# Servidor web leve na porta 80 usando a biblioteca padrão do Python 3.

import http.server
import socketserver
import json
import subprocess
import os
import urllib.parse
import hashlib
import time

PORT = 80
CONFIG_PATH = '/etc/frankenstein.json'

def read_config():
    try:
        with open(CONFIG_PATH, 'r') as f:
            return json.load(f)
    except Exception:
        # Padrão inicial caso não exista
        return {
            "admin_password": "yuk11nn4_admin",
            "apn": "zap.vivo.com.br",
            "wifi": {
                "ssid": "UFI003_4G",
                "wpa_passphrase": "yuk11nn4_wifi"
            },
            "wireguard": {
                "enabled": True,
                "address": "198.19.1.14/30",
                "private_key": "wIQPZEI+qy+rRoPvf5BHJyd7BanLcmdxUrEPEMcfr18=",
                "peer_public_key": "qjScjwzWLqw/zHrP5HsjeOsNuuQEgW2NkapRG821Lwk=",
                "endpoint": "rb.davinunes.eti.br:13500",
                "allowed_ips": "0.0.0.0/0, ::/0",
                "persistent_keepalive": 25
            }
        }

def write_config(config_data):
    try:
        with open(CONFIG_PATH, 'w') as f:
            json.dump(config_data, f, indent=2)
        return True
    except Exception:
        return False

class FrankensteinHandler(http.server.BaseHTTPRequestHandler):


    def check_auth(self):
        config = read_config()
        correct_password = config.get('admin_password', 'yuk11nn4_admin')
        expected_session = hashlib.sha256(correct_password.encode()).hexdigest()
        
        cookie_header = self.headers.get('Cookie', '')
        cookies = {}
        for c in cookie_header.split(';'):
            if '=' in c:
                parts = c.strip().split('=', 1)
                if len(parts) == 2:
                    cookies[parts[0]] = parts[1]
                
        return cookies.get('session') == expected_session

    def send_html(self, content, status=200):
        self.send_response(status)
        self.send_header('Content-type', 'text/html; charset=utf-8')
        self.end_headers()
        self.wfile.write(content.encode('utf-8'))

    def send_json(self, data, status=200):
        self.send_response(status)
        self.send_header('Content-type', 'application/json')
        self.end_headers()
        self.wfile.write(json.dumps(data).encode('utf-8'))

    def redirect(self, path):
        self.send_response(303)
        self.send_header('Location', path)
        self.end_headers()

    def do_GET(self):
        # Rotas públicas
        if self.path == '/login' or self.path == '/login/':
            if self.check_auth():
                self.redirect('/')
            else:
                self.send_html(self.get_login_page())
            return

        # Verificar autenticação para rotas privadas
        if not self.check_auth():
            self.redirect('/login')
            return

        # Rotas privadas
        if self.path == '/' or self.path == '/index.html':
            self.send_html(self.get_dashboard_page())
        elif self.path == '/api/config':
            config = read_config()
            # Omitir a senha por segurança no GET config comum, mas se precisar pode retornar
            self.send_json(config)
        elif self.path == '/api/status':
            self.send_json(self.get_system_status())
        else:
            self.send_response(404)
            self.end_headers()

    def do_POST(self):
        # Rota de Login
        if self.path == '/login':
            content_length = int(self.headers.get('Content-Length', 0))
            post_data = self.rfile.read(content_length).decode('utf-8')
            params = urllib.parse.parse_qs(post_data)
            
            password = params.get('password', [''])[0]
            config = read_config()
            correct_password = config.get('admin_password', 'yuk11nn4_admin')
            
            if password == correct_password:
                session_value = hashlib.sha256(correct_password.encode()).hexdigest()
                self.send_response(303)
                self.send_header('Set-Cookie', f'session={session_value}; Path=/; HttpOnly; Max-Age=86400')
                self.send_header('Location', '/')
                self.end_headers()
            else:
                self.send_html(self.get_login_page(error="Senha incorreta!"), status=401)
            return

        # Verificar autenticação para rotas privadas de escrita
        if not self.check_auth():
            self.send_json({"error": "Não autorizado"}, status=401)
            return

        if self.path == '/logout':
            self.send_response(303)
            self.send_header('Set-Cookie', 'session=deleted; Path=/; HttpOnly; Max-Age=0')
            self.send_header('Location', '/login')
            self.end_headers()
            return

        elif self.path == '/api/config':
            content_length = int(self.headers.get('Content-Length', 0))
            post_data = self.rfile.read(content_length).decode('utf-8')
            try:
                new_config = json.loads(post_data)
                
                # Validação básica
                if not new_config.get('admin_password'):
                    self.send_json({"error": "Senha do administrador não pode ser vazia"}, status=400)
                    return
                
                # Gravar configurações
                if write_config(new_config):
                    self.send_json({"success": True, "message": "Configurações salvas! Reiniciando Frankenstein..."})
                    # Reiniciar o serviço do frankenstein em background para aplicar as mudanças
                    subprocess.Popen(["systemctl", "restart", "frankenstein-v2.service"])
                else:
                    self.send_json({"error": "Erro ao escrever arquivo de configuração"}, status=500)
            except Exception as e:
                self.send_json({"error": f"JSON inválido: {str(e)}"}, status=400)

        elif self.path == '/api/reboot':
            self.send_json({"success": True, "message": "Modem reiniciando..."})
            subprocess.Popen(["reboot"])

        elif self.path == '/api/restart-services':
            self.send_json({"success": True, "message": "Reiniciando serviços do modem..."})
            subprocess.Popen(["systemctl", "restart", "frankenstein-v2.service"])

        elif self.path == '/api/test-ips':
            content_length = int(self.headers.get('Content-Length', 0))
            post_data = self.rfile.read(content_length).decode('utf-8')
            try:
                params = json.loads(post_data)
                action = params.get('action')
                if action in ['add', 'clean']:
                    res = subprocess.run(["/usr/local/bin/test-ips-modem.sh", action], capture_output=True, text=True)
                    self.send_json({
                        "success": True, 
                        "stdout": res.stdout,
                        "stderr": res.stderr
                    })
                else:
                    self.send_json({"error": "Ação inválida"}, status=400)
            except Exception as e:
                self.send_json({"error": str(e)}, status=500)
        else:
            self.send_response(404)
            self.end_headers()

    # ============================================================
    # COLETORES DE STATUS DO SISTEMA
    # ============================================================

    def get_system_status(self):
        status = {}
        
        # 1. Uptime
        try:
            with open('/proc/uptime', 'r') as f:
                uptime_seconds = float(f.readline().split()[0])
                hours = int(uptime_seconds // 3600)
                minutes = int((uptime_seconds % 3600) // 60)
                status['uptime'] = f"{hours}h {minutes}m"
        except Exception:
            status['uptime'] = "Desconhecido"

        # 2. QMI Signal info (com proxy)
        try:
            res = subprocess.run(
                ["qmicli", "-p", "-d", "/dev/wwan0qmi0", "--nas-get-signal-strength"],
                capture_output=True, text=True, timeout=5
            )
            rssi = "N/A"
            sinr = "N/A"
            for line in res.stdout.split('\n'):
                if 'RSSI:' in line:
                    rssi = line.split(':')[-1].strip().replace("'", "")
                elif 'SINR' in line:
                    sinr = line.split(':')[-1].strip().replace("'", "")
            status['signal'] = {"rssi": rssi, "sinr": sinr}
        except Exception:
            status['signal'] = {"rssi": "Erro ao ler", "sinr": "N/A"}

        # 3. Interfaces IP
        status['interfaces'] = {}
        for iface in ['wwan0', 'br0', 'clat', 'wg0']:
            status['interfaces'][iface] = self.get_interface_ips(iface)

        # 4. WireGuard Status
        status['wireguard'] = {"active": False, "handshake": "Sem Handshake", "rx": "0 B", "tx": "0 B"}
        try:
            res = subprocess.run(["wg", "show", "wg0"], capture_output=True, text=True)
            if res.returncode == 0 and res.stdout:
                status['wireguard']['active'] = True
                for line in res.stdout.split('\n'):
                    if 'latest handshake:' in line:
                        status['wireguard']['handshake'] = line.split('latest handshake:')[-1].strip()
                    elif 'transfer:' in line:
                        parts = line.split('transfer:')[-1].strip().split(',')
                        if len(parts) == 2:
                            status['wireguard']['rx'] = parts[0].replace("received", "").strip()
                            status['wireguard']['tx'] = parts[1].replace("sent", "").strip()
        except Exception:
            pass

        # 5. Clientes Conectados (DHCP Leases + Neighbours)
        status['clients'] = self.get_connected_clients()

        return status

    def get_interface_ips(self, iface):
        ips = {"ipv4": "N/A", "ipv6": "N/A"}
        try:
            res = subprocess.run(["ip", "addr", "show", "dev", iface], capture_output=True, text=True)
            for line in res.stdout.split('\n'):
                line = line.strip()
                if line.startswith("inet "):
                    ips["ipv4"] = line.split()[1]
                elif line.startswith("inet6 ") and "scope global" in line:
                    ips["ipv6"] = line.split()[1]
        except Exception:
            pass
        return ips

    def get_connected_clients(self):
        clients = []
        leases = {}
        
        # Ler leases do dnsmasq
        for leases_file in ['/var/lib/misc/dnsmasq.leases', '/var/lib/dnsmasq/dnsmasq.leases', '/tmp/dnsmasq.leases']:
            if os.path.exists(leases_file):
                try:
                    with open(leases_file, 'r') as f:
                        for line in f:
                            parts = line.strip().split()
                            if len(parts) >= 4:
                                # Leases IPv4 ou IPv6
                                ip = parts[2]
                                mac = parts[1]
                                name = parts[3]
                                leases[mac.lower()] = {"ip": ip, "hostname": name}
                except Exception:
                    pass
                break

        # Ler tabela NDP e ARP para identificar as interfaces físicas dos clientes
        try:
            res = subprocess.run(["ip", "neigh", "show"], capture_output=True, text=True)
            for line in res.stdout.split('\n'):
                parts = line.strip().split()
                if len(parts) >= 5:
                    ip = parts[0]
                    dev = ""
                    mac = ""
                    state = ""
                    
                    if "dev" in parts:
                        dev_idx = parts.index("dev")
                        if dev_idx + 1 < len(parts):
                            dev = parts[dev_idx + 1]
                    if "lladdr" in parts:
                        mac_idx = parts.index("lladdr")
                        if mac_idx + 1 < len(parts):
                            mac = parts[mac_idx + 1].lower()
                            
                    state = parts[-1]
                    if state in ["REACHABLE", "STALE", "DELAY"]:
                        # Tentar puxar dados do DHCP
                        hostname = "N/A"
                        if mac in leases:
                            hostname = leases[mac]["hostname"]
                            
                        # Determinar tipo de conexão baseada na interface física detectada pelo kernel
                        conn_type = "Wi-Fi" if "wlan" in dev else "USB" if "usb" in dev else dev
                        
                        clients.append({
                            "ip": ip,
                            "mac": mac,
                            "hostname": hostname,
                            "interface": conn_type,
                            "status": state
                        })
        except Exception:
            pass

        # Adicionar os DHCP leases que talvez não estejam na tabela neigh de imediato
        for mac, lease in leases.items():
            if not any(c['mac'] == mac for c in clients):
                clients.append({
                    "ip": lease["ip"],
                    "mac": mac,
                    "hostname": lease["hostname"],
                    "interface": "Inativo/DHCP",
                    "status": "Leased"
                })

        return clients

    # ============================================================
    # FRONTEND (HTML / CSS / JS)
    # ============================================================

    def get_login_page(self, error=""):
        err_block = f'<div class="error-msg">{error}</div>' if error else ''
        return f"""
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Frankenstein Admin - Login</title>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;600&display=swap" rel="stylesheet">
    <style>
        :root {{
            --bg-color: #0d0f12;
            --card-bg: rgba(22, 28, 36, 0.8);
            --primary: #4f46e5;
            --primary-hover: #4338ca;
            --text-color: #f3f4f6;
            --text-muted: #9ca3af;
            --border: rgba(255, 255, 255, 0.08);
            --red: #ef4444;
        }}
        * {{
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }}
        body {{
            font-family: 'Outfit', sans-serif;
            background-color: var(--bg-color);
            color: var(--text-color);
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            background-image: radial-gradient(circle at 10% 20%, rgba(79, 70, 229, 0.15) 0%, transparent 40%),
                              radial-gradient(circle at 90% 80%, rgba(67, 56, 202, 0.1) 0%, transparent 40%);
        }}
        .login-card {{
            background: var(--card-bg);
            border: 1px solid var(--border);
            border-radius: 16px;
            padding: 40px;
            width: 100%;
            max-width: 400px;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.5);
            backdrop-filter: blur(12px);
            text-align: center;
        }}
        h1 {{
            font-weight: 600;
            font-size: 28px;
            margin-bottom: 8px;
            letter-spacing: -0.5px;
            background: linear-gradient(135deg, #a5b4fc, #6366f1);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }}
        p.subtitle {{
            color: var(--text-muted);
            font-size: 14px;
            margin-bottom: 24px;
        }}
        .input-group {{
            text-align: left;
            margin-bottom: 20px;
        }}
        label {{
            display: block;
            font-size: 13px;
            font-weight: 600;
            color: var(--text-muted);
            margin-bottom: 6px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }}
        input[type="password"] {{
            width: 100%;
            padding: 12px 16px;
            background: rgba(0, 0, 0, 0.2);
            border: 1px solid var(--border);
            border-radius: 8px;
            color: #fff;
            font-size: 16px;
            transition: all 0.3s;
        }}
        input[type="password"]:focus {{
            border-color: var(--primary);
            outline: none;
            box-shadow: 0 0 0 3px rgba(79, 70, 229, 0.2);
        }}
        button {{
            width: 100%;
            padding: 12px;
            background: var(--primary);
            border: none;
            border-radius: 8px;
            color: #fff;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: background 0.2s;
            margin-top: 10px;
        }}
        button:hover {{
            background: var(--primary-hover);
        }}
        .error-msg {{
            background: rgba(239, 68, 68, 0.1);
            border: 1px solid var(--red);
            color: var(--red);
            padding: 10px;
            border-radius: 8px;
            font-size: 14px;
            margin-bottom: 20px;
        }}
    </style>
</head>
<body>
    <div class="login-card">
        <h1>Frankenstein Admin</h1>
        <p class="subtitle">Modem UFI003 Dashboard</p>
        
        {err_block}
        
        <form method="POST" action="/login">
            <div class="input-group">
                <label for="password">Senha do Modem</label>
                <input type="password" id="password" name="password" required autofocus placeholder="Digite a senha admin">
            </div>
            <button type="submit">Entrar</button>
        </form>
    </div>
</body>
</html>
"""

    def get_dashboard_page(self):
        return """
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Frankenstein Control Panel</title>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600&display=swap" rel="stylesheet">
    <style>
        :root {
            --bg-color: #080a0f;
            --card-bg: rgba(17, 22, 34, 0.75);
            --primary: #5850ec;
            --primary-hover: #453eeb;
            --accent: #10b981;
            --text-color: #f9fafb;
            --text-muted: #9ca3af;
            --border: rgba(255, 255, 255, 0.06);
            --red: #ef4444;
            --orange: #f59e0b;
        }
        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }
        body {
            font-family: 'Outfit', sans-serif;
            background-color: var(--bg-color);
            color: var(--text-color);
            min-height: 100vh;
            background-image: radial-gradient(circle at 0% 0%, rgba(88, 80, 236, 0.12) 0%, transparent 50%),
                              radial-gradient(circle at 100% 100%, rgba(16, 185, 129, 0.06) 0%, transparent 50%);
            padding-bottom: 60px;
        }
        .header {
            border-bottom: 1px solid var(--border);
            backdrop-filter: blur(12px);
            background: rgba(8, 10, 15, 0.8);
            position: sticky;
            top: 0;
            z-index: 100;
        }
        .header-container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 16px 24px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .logo-area h1 {
            font-size: 20px;
            font-weight: 600;
            background: linear-gradient(135deg, #a5b4fc, #5850ec);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }
        .logo-area p {
            font-size: 11px;
            color: var(--text-muted);
            text-transform: uppercase;
            letter-spacing: 1px;
        }
        .header-actions {
            display: flex;
            align-items: center;
            gap: 16px;
        }
        .status-pill {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            font-size: 13px;
            font-weight: 500;
            padding: 4px 10px;
            border-radius: 20px;
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid var(--border);
        }
        .status-dot {
            width: 8px;
            height: 8px;
            border-radius: 50%;
            background: var(--red);
        }
        .status-dot.online {
            background: var(--accent);
            box-shadow: 0 0 8px var(--accent);
        }
        .btn {
            padding: 8px 16px;
            border-radius: 6px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s;
            border: none;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            justify-content: center;
        }
        .btn-primary {
            background: var(--primary);
            color: white;
        }
        .btn-primary:hover {
            background: var(--primary-hover);
        }
        .btn-outline {
            background: transparent;
            border: 1px solid var(--border);
            color: var(--text-color);
        }
        .btn-outline:hover {
            background: rgba(255, 255, 255, 0.05);
            border-color: var(--text-muted);
        }
        .btn-danger {
            background: var(--red);
            color: white;
        }
        .btn-danger:hover {
            background: #dc2626;
        }
        .main-container {
            max-width: 1200px;
            margin: 32px auto 0;
            padding: 0 24px;
        }
        .tabs {
            display: flex;
            gap: 12px;
            border-bottom: 1px solid var(--border);
            margin-bottom: 28px;
            padding-bottom: 8px;
        }
        .tab-btn {
            background: transparent;
            border: none;
            color: var(--text-muted);
            font-size: 16px;
            font-weight: 500;
            cursor: pointer;
            padding: 8px 16px;
            border-radius: 6px;
            transition: all 0.2s;
        }
        .tab-btn.active {
            color: var(--text-color);
            background: rgba(255, 255, 255, 0.05);
            font-weight: 600;
        }
        .tab-content {
            display: none;
        }
        .tab-content.active {
            display: block;
        }
        .grid-cards {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 20px;
            margin-bottom: 28px;
        }
        .card {
            background: var(--card-bg);
            border: 1px solid var(--border);
            border-radius: 12px;
            padding: 20px;
            backdrop-filter: blur(10px);
        }
        .card h3 {
            font-size: 14px;
            font-weight: 600;
            color: var(--text-muted);
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 12px;
        }
        .card-value {
            font-size: 22px;
            font-weight: 600;
            margin-bottom: 8px;
        }
        .card-desc {
            font-size: 13px;
            color: var(--text-muted);
            word-break: break-all;
        }
        .table-title {
            font-size: 18px;
            font-weight: 600;
            margin-bottom: 16px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            text-align: left;
            margin-bottom: 28px;
            border: 1px solid var(--border);
            border-radius: 8px;
            overflow: hidden;
        }
        th, td {
            padding: 12px 16px;
            font-size: 14px;
        }
        th {
            background: rgba(255, 255, 255, 0.03);
            color: var(--text-muted);
            font-weight: 600;
            border-bottom: 1px solid var(--border);
        }
        tr {
            border-bottom: 1px solid var(--border);
        }
        tr:last-child {
            border-bottom: none;
        }
        td {
            color: #d1d5db;
        }
        .ip-pill {
            background: rgba(88, 80, 236, 0.1);
            color: #a5b4fc;
            padding: 2px 6px;
            border-radius: 4px;
            font-family: monospace;
            font-size: 12px;
        }
        .mac-pill {
            color: var(--text-muted);
            font-family: monospace;
            font-size: 12px;
        }
        .status-badge {
            display: inline-block;
            padding: 2px 6px;
            border-radius: 4px;
            font-size: 11px;
            font-weight: 600;
            text-transform: uppercase;
        }
        .status-badge.reachable {
            background: rgba(16, 185, 129, 0.15);
            color: var(--accent);
        }
        .status-badge.leased {
            background: rgba(245, 158, 11, 0.15);
            color: var(--orange);
        }
        .status-badge.stale {
            background: rgba(255, 255, 255, 0.08);
            color: var(--text-muted);
        }
        .form-section {
            margin-bottom: 24px;
            border: 1px solid var(--border);
            border-radius: 12px;
            background: var(--card-bg);
            padding: 24px;
        }
        .form-section h4 {
            font-size: 16px;
            font-weight: 600;
            margin-bottom: 16px;
            border-bottom: 1px solid var(--border);
            padding-bottom: 8px;
            color: #a5b4fc;
        }
        .form-group {
            margin-bottom: 16px;
            display: grid;
            grid-template-columns: 220px 1fr;
            align-items: center;
            gap: 16px;
        }
        @media (max-width: 768px) {
            .form-group {
                grid-template-columns: 1fr;
                gap: 6px;
            }
        }
        label {
            font-size: 14px;
            font-weight: 500;
            color: var(--text-muted);
        }
        input[type="text"], input[type="password"], input[type="number"], select {
            width: 100%;
            padding: 10px 12px;
            background: rgba(0, 0, 0, 0.3);
            border: 1px solid var(--border);
            border-radius: 6px;
            color: #fff;
            font-size: 14px;
            transition: all 0.3s;
        }
        input[type="text"]:focus, input[type="password"]:focus, input[type="number"]:focus, select:focus {
            border-color: var(--primary);
            outline: none;
        }
        .checkbox-container {
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .tester-container {
            display: flex;
            flex-direction: column;
            gap: 12px;
        }
        .test-output {
            width: 100%;
            height: 160px;
            background: rgba(0,0,0,0.4);
            border: 1px solid var(--border);
            border-radius: 8px;
            padding: 12px;
            font-family: monospace;
            font-size: 12px;
            color: #10b981;
            overflow-y: auto;
            white-space: pre-wrap;
        }
        .action-bar {
            display: flex;
            justify-content: flex-end;
            gap: 16px;
            margin-top: 24px;
        }
        .alert-info {
            background: rgba(88, 80, 236, 0.08);
            border: 1px solid rgba(88, 80, 236, 0.2);
            color: #a5b4fc;
            padding: 12px;
            border-radius: 8px;
            font-size: 14px;
            margin-bottom: 20px;
        }
    </style>
</head>
<body>
    <header class="header">
        <div class="header-container">
            <div class="logo-area">
                <h1>Frankenstein Admin</h1>
                <p>Modem 4G UFI003 Dashboard</p>
            </div>
            <div class="header-actions">
                <span class="status-pill">
                    <span id="global-status-dot" class="status-dot"></span>
                    <span id="global-status-text">Buscando...</span>
                </span>
                <span id="system-uptime" class="status-pill" style="font-size: 12px;">Uptime: --</span>
                <form action="/logout" method="POST" style="margin: 0;">
                    <button type="submit" class="btn btn-outline" style="padding: 6px 12px; font-size: 13px;">Sair</button>
                </form>
            </div>
        </div>
    </header>

    <main class="main-container">
        <div class="tabs">
            <button class="tab-btn active" onclick="switchTab('dashboard', this)">Dashboard</button>
            <button class="tab-btn" onclick="switchTab('configuration', this)">Configuração</button>
            <button class="tab-btn" onclick="switchTab('diagnostics', this)">Diagnóstico IPv6</button>
        </div>

        <!-- TAB: DASHBOARD -->
        <div id="tab-dashboard" class="tab-content active">
            <div class="grid-cards">
                <div class="card">
                    <h3>Sinal QMI e Tecnologia</h3>
                    <div id="val-signal" class="card-value">-- dBm</div>
                    <div id="val-sinr" class="card-desc">SINR: --</div>
                </div>
                <div class="card">
                    <h3>Rede 4G (Vivo IPv6 WAN)</h3>
                    <div id="val-wan-ip" class="card-value" style="font-size: 15px; word-break: break-all; margin-top: 10px;">Buscando...</div>
                    <div id="val-wan-prefix" class="card-desc" style="margin-top: 6px;">Prefixo: --</div>
                </div>
                <div class="card">
                    <h3>Tradução CLAT (IPv4)</h3>
                    <div id="val-clat-ip" class="card-value">N/A</div>
                    <div id="val-clat-status" class="card-desc">Carregando...</div>
                </div>
                <div class="card">
                    <h3>WireGuard (VPN)</h3>
                    <div id="val-wg-handshake" class="card-value" style="font-size: 16px; margin-top: 10px;">Inativo</div>
                    <div id="val-wg-traffic" class="card-desc">TX/RX: --</div>
                </div>
            </div>

            <div class="card" style="margin-bottom: 28px;">
                <div class="table-title">
                    <span>Clientes Conectados (USB / Wi-Fi)</span>
                    <button class="btn btn-outline" style="padding: 6px 12px; font-size: 13px;" onclick="loadStatus()">Atualizar Lista</button>
                </div>
                <table id="clients-table">
                    <thead>
                        <tr>
                            <th>Dispositivo (Hostname)</th>
                            <th>Endereço IP</th>
                            <th>Endereço MAC</th>
                            <th>Interface Física</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody id="clients-tbody">
                        <tr>
                            <td colspan="5" style="text-align: center; color: var(--text-muted);">Buscando informações dos clientes...</td>
                        </tr>
                    </tbody>
                </table>
            </div>

            <div class="card">
                <h3>Ações Rápidas do Sistema</h3>
                <div style="display: flex; gap: 16px; margin-top: 12px;">
                    <button class="btn btn-outline" onclick="restartServices()">Reiniciar Serviços de Rede</button>
                    <button class="btn btn-danger" onclick="rebootModem()">Reiniciar Modem</button>
                </div>
            </div>
        </div>

        <!-- TAB: CONFIGURATION -->
        <div id="tab-configuration" class="tab-content">
            <div class="alert-info">
                ℹ️ **Aviso:** Alterações de configuração geram e substituem arquivos em `/etc/hostapd/hostapd.conf` e `/etc/wireguard/wg0.conf` automaticamente ao reiniciar os serviços de rede.
            </div>
            
            <form id="config-form" onsubmit="saveConfig(event)">
                <div class="form-section">
                    <h4>Segurança e Acesso</h4>
                    <div class="form-group">
                        <label for="cfg-password">Nova Senha do Admin Web</label>
                        <input type="password" id="cfg-password" placeholder="Mantenha vazia para não alterar">
                    </div>
                </div>

                <div class="form-section">
                    <h4>Celular (4G)</h4>
                    <div class="form-group">
                        <label for="cfg-apn">APN da Operadora</label>
                        <input type="text" id="cfg-apn" required>
                    </div>
                </div>

                <div class="form-section">
                    <h4>Rede Sem Fio (WiFi AP)</h4>
                    <div class="form-group">
                        <label for="cfg-ssid">SSID do WiFi (Nome)</label>
                        <input type="text" id="cfg-ssid" required>
                    </div>
                    <div class="form-group">
                        <label for="cfg-passphrase">Senha do WiFi</label>
                        <input type="text" id="cfg-passphrase" required minlength="8">
                    </div>
                </div>

                <div class="form-section">
                    <h4>Túnel VPN (WireGuard)</h4>
                    <div class="form-group">
                        <label>Ativar VPN no Boot</label>
                        <div class="checkbox-container">
                            <input type="checkbox" id="cfg-wg-enabled" style="width: 18px; height: 18px;">
                            <span>Habilitar Túnel</span>
                        </div>
                    </div>
                    <div class="form-group">
                        <label for="cfg-wg-address">IP do Modem no Túnel</label>
                        <input type="text" id="cfg-wg-address" required placeholder="Ex: 198.19.1.14/30">
                    </div>
                    <div class="form-group">
                        <label for="cfg-wg-private">Chave Privada do Modem</label>
                        <input type="text" id="cfg-wg-private" required>
                    </div>
                    <div class="form-group">
                        <label for="cfg-wg-peer-public">Chave Pública do Servidor</label>
                        <input type="text" id="cfg-wg-peer-public" required>
                    </div>
                    <div class="form-group">
                        <label for="cfg-wg-endpoint">Endpoint do Servidor (IP/Host:Port)</label>
                        <input type="text" id="cfg-wg-endpoint" required placeholder="Ex: vpn.meudominio.com:13500">
                    </div>
                    <div class="form-group">
                        <label for="cfg-wg-allowed">IPs Permitidos (Allowed IPs)</label>
                        <input type="text" id="cfg-wg-allowed" required placeholder="Ex: 0.0.0.0/0, ::/0">
                    </div>
                    <div class="form-group">
                        <label for="cfg-wg-keepalive">Persistent Keepalive (segundos)</label>
                        <input type="number" id="cfg-wg-keepalive" required min="0" max="120">
                    </div>
                </div>

                <div class="action-bar">
                    <button type="button" class="btn btn-outline" onclick="loadConfig()">Descartar Alterações</button>
                    <button type="submit" class="btn btn-primary">Salvar e Aplicar Alterações</button>
                </div>
            </form>
        </div>

        <!-- TAB: DIAGNOSTICS -->
        <div id="tab-diagnostics" class="tab-content">
            <div class="card">
                <h3>Teste de Múltiplos IPs IPv6 (SLAAC / NDP Proxy Check)</h3>
                <p style="font-size: 14px; color: var(--text-muted); margin-bottom: 20px;">
                    Adicione 50 IPs temporários na interface de WAN para testar se a operadora (Vivo) aceita entregar pacotes para múltiplos endereços de IPv6 globais criados dentro do seu prefixo `/64`.
                </p>
                <div class="tester-container">
                    <div style="display: flex; gap: 16px;">
                        <button class="btn btn-primary" onclick="runIpTest('add')">Adicionar 50 IPs de Teste</button>
                        <button class="btn btn-outline" onclick="runIpTest('clean')">Remover IPs de Teste</button>
                    </div>
                    <div>
                        <label style="margin-bottom: 6px; display: block;">Saída do Terminal do Script:</label>
                        <div id="test-terminal-output" class="test-output">Aguardando comando...</div>
                    </div>
                </div>
            </div>
        </div>
    </main>

    <script>
        function switchTab(tabId, btn) {
            document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
            document.querySelectorAll('.tab-content').forEach(c => c.classList.remove('active'));
            
            if (btn) {
                btn.classList.add('active');
            }
            document.getElementById('tab-' + tabId).classList.add('active');
            
            if (tabId === 'configuration') {
                loadConfig();
            }
        }

        async function loadStatus() {
            try {
                const response = await fetch('/api/status');
                if (!response.ok) return;
                const status = await response.json();
                
                // Atualizar Uptime
                document.getElementById('system-uptime').innerText = 'Uptime: ' + status.uptime;
                
                // Status QMI
                const signal = status.signal;
                if (signal.rssi !== "N/A" && signal.rssi !== "Erro ao ler") {
                    document.getElementById('val-signal').innerText = signal.rssi;
                    document.getElementById('val-sinr').innerText = 'SINR: ' + signal.sinr;
                    
                    // Dot Status
                    document.getElementById('global-status-dot').className = 'status-dot online';
                    document.getElementById('global-status-text').innerText = '4G Online';
                } else {
                    document.getElementById('val-signal').innerText = '--';
                    document.getElementById('val-sinr').innerText = 'Sem sinal QMI';
                    
                    document.getElementById('global-status-dot').className = 'status-dot';
                    document.getElementById('global-status-text').innerText = 'Sem Sinal';
                }

                // WAN IPs
                const wan = status.interfaces.wwan0;
                if (wan.ipv6 !== "N/A") {
                    document.getElementById('val-wan-ip').innerText = wan.ipv6;
                    const prefix = wan.ipv6.split(':').slice(0, 4).join(':') + '::/64';
                    document.getElementById('val-wan-prefix').innerText = 'Prefixo: ' + prefix;
                } else {
                    document.getElementById('val-wan-ip').innerText = 'Desconectado';
                    document.getElementById('val-wan-prefix').innerText = 'Prefixo: N/A';
                }

                // CLAT status
                const clat = status.interfaces.clat;
                if (clat.ipv4 !== "N/A") {
                    document.getElementById('val-clat-ip').innerText = clat.ipv4;
                    document.getElementById('val-clat-status').innerText = 'Servidor TAYGA ativo';
                } else {
                    document.getElementById('val-clat-ip').innerText = 'Inativo';
                    document.getElementById('val-clat-status').innerText = 'Interface clat offline';
                }

                // Wireguard status
                const wg = status.wireguard;
                if (wg.active) {
                    document.getElementById('val-wg-handshake').innerText = wg.handshake !== "Sem Handshake" ? 'Handshake: ' + wg.handshake : 'Sem handshake recente';
                    document.getElementById('val-wg-traffic').innerText = 'TX: ' + wg.tx + ' | RX: ' + wg.rx;
                } else {
                    document.getElementById('val-wg-handshake').innerText = 'Desativado';
                    document.getElementById('val-wg-traffic').innerText = 'Túnel wg0 não configurado';
                }

                // Clientes Tabela
                const tbody = document.getElementById('clients-tbody');
                tbody.innerHTML = '';
                if (status.clients.length === 0) {
                    tbody.innerHTML = '<tr><td colspan="5" style="text-align: center; color: var(--text-muted);">Nenhum cliente conectado detectado</td></tr>';
                } else {
                    status.clients.forEach(client => {
                        const tr = document.createElement('tr');
                        
                        const tdName = document.createElement('td');
                        tdName.innerText = client.hostname !== 'N/A' ? client.hostname : 'Dispositivo Desconhecido';
                        
                        const tdIp = document.createElement('td');
                        tdIp.innerHTML = `<span class="ip-pill">${client.ip}</span>`;
                        
                        const tdMac = document.createElement('td');
                        tdMac.innerHTML = `<span class="mac-pill">${client.mac}</span>`;
                        
                        const tdIface = document.createElement('td');
                        tdIface.innerText = client.interface;
                        
                        const tdStatus = document.createElement('td');
                        let badgeClass = 'stale';
                        if (client.status === 'REACHABLE') badgeClass = 'reachable';
                        else if (client.status === 'Leased') badgeClass = 'leased';
                        
                        tdStatus.innerHTML = `<span class="status-badge ${badgeClass}">${client.status}</span>`;
                        
                        tr.appendChild(tdName);
                        tr.appendChild(tdIp);
                        tr.appendChild(tdMac);
                        tr.appendChild(tdIface);
                        tr.appendChild(tdStatus);
                        tbody.appendChild(tr);
                    });
                }

            } catch (e) {
                console.error("Erro ao ler status", e);
            }
        }

        async function loadConfig() {
            try {
                const response = await fetch('/api/config');
                if (!response.ok) return;
                const config = await response.json();
                
                document.getElementById('cfg-password').value = '';
                document.getElementById('cfg-apn').value = config.apn;
                document.getElementById('cfg-ssid').value = config.wifi.ssid;
                document.getElementById('cfg-passphrase').value = config.wifi.wpa_passphrase;
                
                document.getElementById('cfg-wg-enabled').checked = config.wireguard.enabled;
                document.getElementById('cfg-wg-address').value = config.wireguard.address;
                document.getElementById('cfg-wg-private').value = config.wireguard.private_key;
                document.getElementById('cfg-wg-peer-public').value = config.wireguard.peer_public_key;
                document.getElementById('cfg-wg-endpoint').value = config.wireguard.endpoint;
                document.getElementById('cfg-wg-allowed').value = config.wireguard.allowed_ips;
                document.getElementById('cfg-wg-keepalive').value = config.wireguard.persistent_keepalive;
            } catch (e) {
                alert("Erro ao carregar configurações do modem.");
            }
        }

        async function saveConfig(e) {
            e.preventDefault();
            
            const config = {
                apn: document.getElementById('cfg-apn').value,
                wifi: {
                    ssid: document.getElementById('cfg-ssid').value,
                    wpa_passphrase: document.getElementById('cfg-passphrase').value
                },
                wireguard: {
                    enabled: document.getElementById('cfg-wg-enabled').checked,
                    address: document.getElementById('cfg-wg-address').value,
                    private_key: document.getElementById('cfg-wg-private').value,
                    peer_public_key: document.getElementById('cfg-wg-peer-public').value,
                    endpoint: document.getElementById('cfg-wg-endpoint').value,
                    allowed_ips: document.getElementById('cfg-wg-allowed').value,
                    persistent_keepalive: parseInt(document.getElementById('cfg-wg-keepalive').value, 10)
                }
            };
            
            const pwd = document.getElementById('cfg-password').value;
            if (pwd) {
                config.admin_password = pwd;
            } else {
                // Manter senha atual obtendo-a temporariamente do formulário ou carregando
                const response = await fetch('/api/config');
                const current = await response.json();
                config.admin_password = current.admin_password;
            }
            
            if (confirm("Deseja aplicar as novas configurações? Os serviços de rede serão reiniciados e você poderá perder a conexão temporariamente.")) {
                try {
                    const response = await fetch('/api/config', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify(config)
                    });
                    const res = await response.json();
                    if (response.ok) {
                        alert(res.message);
                        setTimeout(() => { location.reload(); }, 3000);
                    } else {
                        alert("Erro: " + res.error);
                    }
                } catch (e) {
                    alert("Erro de comunicação ao salvar.");
                }
            }
        }

        async function restartServices() {
            if (confirm("Deseja reiniciar todos os serviços de rede do modem?")) {
                const response = await fetch('/api/restart-services', { method: 'POST' });
                const res = await response.json();
                alert(res.message);
                setTimeout(loadStatus, 4000);
            }
        }

        async function rebootModem() {
            if (confirm("Tem certeza que deseja REINICIAR O MODEM fisicamente?")) {
                const response = await fetch('/api/reboot', { method: 'POST' });
                const res = await response.json();
                alert(res.message);
            }
        }

        async function runIpTest(action) {
            const outDiv = document.getElementById('test-terminal-output');
            outDiv.innerText = "Executando ação '" + action + "' em background no modem...";
            try {
                const response = await fetch('/api/test-ips', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ action: action })
                });
                const res = await response.json();
                if (response.ok) {
                    outDiv.innerText = "=== STDOUT ===\\n" + res.stdout + "\\n=== STDERR ===\\n" + res.stderr;
                } else {
                    outDiv.innerText = "Erro: " + res.error;
                }
            } catch (e) {
                outDiv.innerText = "Erro de conexão ao rodar teste.";
            }
        }

        // Loop de atualização
        loadStatus();
        setInterval(loadStatus, 6000);
    </script>
</body>
</html>
"""
        return ""

# Rodar o Servidor
if __name__ == '__main__':
    # Aguardar um instante na inicialização para garantir que as interfaces básicas estão prontas
    time.sleep(2)
    socketserver.TCPServer.allow_reuse_address = True
    with socketserver.TCPServer(("", PORT), FrankensteinHandler) as httpd:
        print(f"Servidor Web Frankenstein ativo na porta {PORT}")
        httpd.serve_forever()
