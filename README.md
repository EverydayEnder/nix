# NixOS Pentesting & Blue Team Environment

A comprehensive, reproducible penetration testing and blue team environment built with NixOS flakes.

## 🎯 What's Included

### Desktop Environment
- **Deepin Desktop** - Modern, clean interface
- **Firefox & Google Chrome** - Web browsers  
- **Essential desktop apps** - File manager, terminal, text editor

### Red Team Tools
- **Network Scanning**: nmap, masscan, whatweb, nikto
- **Web Testing**: burp suite, sqlmap, dirb, ffuf, gobuster
- **Password Attacks**: thc-hydra, hashcat, john
- **Exploitation**: metasploit, exploitdb
- **Wireless**: aircrack-ng, kismet, reaverwps-t6x
- **Reverse Engineering**: ghidra, radare2, gdb
- **Forensics**: sleuthkit, volatility3, binwalk

### Blue Team Tools
- **Network Monitoring**: suricata, zeek, wireshark, tcpdump
- **System Monitoring**: osquery
- **Network Analysis**: bettercap, ettercap

### Development Environment
- **Languages**: Python 3, Go, Node.js
- **Containers**: Docker, Docker Compose
- **Tools**: gcc, make, git, vim, tmux

### VPN Support
- **WireGuard** - Custom configuration during setup
- **Cisco AnyConnect** - OpenConnect client

## 🚀 Installation Methods

### Method 1: Fresh Installation (Recommended)
For a completely clean system with no leftover data:

1. **Boot from NixOS installer ISO**
2. **Clone the repository and run install script**:
   ```bash
   git clone https://github.com/EverydayEnder/nix.git
   cd nix
   bash install.sh
   ```
3. **Follow prompts**:
   - Confirm disk wipe (⚠️ **Will erase everything!**)
   - Paste WireGuard config (or type `END` to skip)
   - Wait 15-30 minutes for installation
   - Set password for `jesus` user when prompted
4. **Reboot and login** as `jesus` user with your new password

### Method 2: Existing NixOS System
To add pentesting tools to an existing NixOS installation:

1. **Clone and run setup script**:
   ```bash
   git clone https://github.com/EverydayEnder/nix.git
   cd nix
   bash setup.sh
   ```
2. **Follow prompts**:
   - Paste WireGuard config (or type `END` to skip)
   - Wait 15-30 minutes for configuration
3. **Reboot when prompted**
3. **Login** as `jesus` user

### Method 3: Manual Installation
```bash
# Enable flakes
mkdir -p ~/.config/nix
echo 'experimental-features = nix-command flakes' >> ~/.config/nix/nix.conf

# Clone and apply configuration
git clone https://github.com/EverydayEnder/nix.git
cd nix
sudo cp /etc/nixos/hardware-configuration.nix ./
sudo nixos-rebuild switch --flake .#pentest
```

## 🔧 Post-Installation

### Important First Steps
1. **Update system**: `sudo nixos-rebuild switch --upgrade --flake .#pentest`
2. **Start WireGuard** (if configured): `sudo systemctl enable --now wg-quick@wg0`

### Tool Setup
- **Metasploit**: Run `sudo msfdb init` to initialize database
- **Burp Suite**: Configure browser proxy (127.0.0.1:8080)
- **Docker**: Test with `docker run hello-world`

### WireGuard Setup
If you configured WireGuard during installation:

**Check if configured**:
```bash
sudo ls -la /etc/wireguard/
```

**Start the VPN**:
```bash
sudo systemctl enable --now wg-quick@wg0
```

**Verify connection**:
```bash
sudo wg show
ip addr show wg0
```

**Test connectivity**:
```bash
ping 10.10.0.1  # Adjust to your gateway IP
```

## 🛠️ Customization

### Adding Tools
1. Edit `flake.nix`
2. Add packages to `environment.systemPackages` list
3. Rebuild: `sudo nixos-rebuild switch --flake .#pentest`

### Updating System
```bash
cd ~/pentesting-nixos  # or wherever you cloned it
git pull
sudo nixos-rebuild switch --flake .#pentest
```

## 📁 Repository Structure

```
pentesting-nixos/
├── flake.nix              # Main system configuration
├── install.sh             # Fresh installation script
├── setup.sh               # Existing system setup script
├── hardware-configuration.nix  # Hardware-specific config (auto-generated)
└── README.md              # This file
```

## 🔄 Installation Method Comparison

| Method | Use Case | Data Preservation | Installation Time | VPN Setup |
|--------|----------|-------------------|-------------------|-----------|
| **Fresh Install** | New VM, complete reset | ❌ Wipes everything | 20-40 min | ✅ During install |
| **Setup Script** | Existing NixOS | ✅ Keeps user data | 15-30 min | ✅ During setup |
| **Manual** | Custom setup | ✅ Keeps user data | 10-20 min | ⚠️ Manual config |

## 🔧 Troubleshooting

### Common Issues

**WireGuard not connecting**:
```bash
sudo systemctl status wg-quick@wg0
sudo journalctl -u wg-quick@wg0 -f
```

**Build failures**:
```bash
sudo nixos-rebuild switch --flake .#pentest --show-trace
```

**Tool not found**:
```bash
nix search nixpkgs tool-name
```

**Rollback if something breaks**:
```bash
sudo nixos-rebuild switch --rollback
```

### Getting Help
- Check the error trace with `--show-trace`
- Look at system logs with `journalctl`
- Verify your flake syntax
- Ensure all required files are committed to git

## ⚠️ Security Notice

This environment is designed for **authorized testing only**. Users are responsible for complying with all applicable laws and regulations. Only test systems you own or have explicit written permission to test.

## 🤝 Contributing

1. Fork the repository
2. Make your changes
3. Test the configuration thoroughly
4. Submit a pull request

## 📄 License

MIT License - See LICENSE file for details.

## 🔗 Useful Resources

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Nix Flakes Documentation](https://nixos.wiki/wiki/Flakes)
- [NixOS Hardware Configurations](https://github.com/NixOS/nixos-hardware)

---

**Happy Ethical Hacking!** 🛡️

*Built with ❤️ and NixOS*
