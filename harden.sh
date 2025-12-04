#!/bin/bash
set -e

echo "[+] Updating system packages..."
apt update && apt upgrade -y

echo "[+] Installing core security packages..."
DEBIAN_FRONTEND=noninteractive apt install -y \
	vim git curl wget net-tools ufw fail2ban unattended-upgrades apt-listchanges\
	libpam-pwquality openssh-server

echo "[+] Configuring automatic security updates..."
dpkg-reconfigure -f noninteractive unattended-upgrades

echo "[+] Setting firewall rules..."
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp
ufw --force enable

echo "[+] Applying SSH hardening..."

if [ ! -f /etc/ssh/sshd_config ]; then
	echo "[!] ERROR: /etc/ssh/sshd_config not found. Aborting SSH hardening."
	exit 1
fi

cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak.$(date +%F)

sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/^#\?X11Forwarding.*/X11Forwarding no/' /etc/ssh/sshd_config

systemctl restart ssh

echo "[+] Setting Fail2Ban configuration..."
cat > /etc/fail2ban/jail.local << 'EOF'
[sshd]
enabled = true
port = 22
logpath = /var/log/auth.log
backend = systemd
maxretry = 5
bantime = 1h
findtime = 10m
EOF

systemctl restart fail2ban

echo "[+] Applying kernel hardeneing..."
cat > /etc/sysctl.d/99-hardened.conf << 'EOF'
net.ipv4.ip_forward = 0
net.ipv6.conf.all.forwarding = 0
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.conf.all.accept_redirects = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv4.conf.all.accept_source_route = 0
net.ipv6.conf.all.accept_source_route = 0
net.ipv4.conf.all.rp_filter = 1
net.ipv4.tcp_syncookies = 1
net.ipv4.conf.all.send_redirects = 0
kernel.dmesg_restrict = 1
kernel.kptr_restrict = 2
kernel.sysrq = 0
EOF

sysctl --system

echo "[+] Hardening completed successfully."
echo "[+]Reboot recommended."

