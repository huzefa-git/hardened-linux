A simple, automated Linux server hardening script for Debian-based systems. It applies a secure baseline suitable for lab servers, self-hosted services, and security practice.

Features
```
1. SSH hardening
	- Disables root SSH login
	- Disables password authentication (keys only, once configured)
	- Enforces secure defaults
2. Network & firewall
	- UFW configured to deny-all incoming by default
	- Allows only SSH (22/tcp) by default
3. Intrusion protection
	- Fail2Ban configured for SSH  brute-force protection
4. Kernel / sysctl hardening
	- Disables IP forwarding (not a router)
	- Anti-spoofing (`rp_filter`)
	- SYN flood protection (`tcp_syncookies`)
	- Restricts kernel debug info (`dmesg_restrict`, `kptr_restrict`, `sysrq=0`)
5. Password & updates
	- Installs `libpam-pwquality` for strong passwords (configured manually earlier)
	- Enables automatic security updates (`unattended-upgrades`)
```

Requirements
```
- Debian 12 (Bookworm) or similar
- Root or sudo privileges
```

Usage
```bash
git clone https://github.com/huzefa-git/hardened-linux.git
cd hardened-linux
chmod +x harden.sh
sudo ./harden.sh
```

Usage notes
```
- Run only on fresh or non-critical Debian-based systems; it will change SSH, firewall, and kernel settings.
- After running, make sure you have working SSH key authentication before disabling password logins.
- The script creates a backup of `/etc/ssh/sshd_config` as `sshd_config.bak.<date>`.
```

Verification
```
1. Check firewall
sudo ufw status verbose
2. Check Fail2Ban
sudo fail2ban-client status sshd
3. Verify kernel hardening parameters
sudo sysctl net.ipv4.tcp_syncookies
sudo sysctl kernel.kptr_restrict
sudo sysctl net.ipv4.ip_forward
```

Project structure
```
hardened-linux/
|---harden.sh 	# main automation script
|---README.md	# documentation
|---.gitignore
```

Known issues
```
- If SSH blocks access after disabling password login, ensure SSH key authentication is configured first.
- Fail2Ban service logs can be checked using: journalctl -xeu fail2ban
```

Disclaimer
```
This project is intended for educational and lab use only. Review and adapt hardening settings before applying to production systems.
```
