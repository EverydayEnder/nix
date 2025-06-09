#!/bin/bash
# Enhanced NixOS pentest setup script
set -e

echo "🚀 Setting up NixOS pentesting environment..."

# Check if on NixOS
if [ ! -f /etc/nixos/configuration.nix ]; then
    echo "❌ Error: This requires NixOS to be installed first"
    exit 1
fi

# Enable flakes
echo "📦 Enabling Nix flakes..."
mkdir -p ~/.config/nix
if ! grep -q "experimental-features.*flakes" ~/.config/nix/nix.conf 2>/dev/null; then
    echo 'experimental-features = nix-command flakes' >> ~/.config/nix/nix.conf
    echo "✅ Flakes enabled"
else
    echo "✅ Flakes already enabled"
fi

# Clone/update the repo
REPO_DIR="$HOME/pentesting-nixos"
if [ -d "$REPO_DIR" ]; then
    echo "📁 Updating existing repo..."
    cd "$REPO_DIR"
    git pull
else
    echo "📁 Cloning repo..."
    git clone https://github.com/EverydayEnder/pentesting-nixos.git "$REPO_DIR"
    cd "$REPO_DIR"
fi

# Update hardware configuration for this machine
echo "🔧 Updating hardware configuration..."
sudo cp /etc/nixos/hardware-configuration.nix ./hardware-configuration.nix

# Setup WireGuard configuration
echo ""
echo "🔑 WireGuard VPN Configuration"
echo "Paste your complete WireGuard config below."
echo "When done, press Enter on a new line, then type 'END' and press Enter:"
echo ""

WG_CONFIG=""
while true; do
    read -r line
    if [ "$line" = "END" ]; then
        break
    fi
    WG_CONFIG+="$line"$'\n'
done

if [ -n "$WG_CONFIG" ] && [ "$WG_CONFIG" != $'\n' ]; then
    # Create WireGuard directory and config file
    sudo mkdir -p /etc/wireguard
    echo "$WG_CONFIG" | sudo tee /etc/wireguard/wg0.conf > /dev/null
    sudo chmod 600 /etc/wireguard/wg0.conf
    echo "✅ WireGuard configuration saved"
else
    echo "⚠️  Skipping WireGuard setup"
fi

# Test build
echo "🧪 Testing configuration..."
sudo nixos-rebuild dry-build --flake .#pentest

if [ $? -eq 0 ]; then
    echo "✅ Configuration test passed!"
    echo ""
    echo "🚀 Applying configuration (this may take 15-30 minutes)..."
    sudo nixos-rebuild switch --flake .#pentest
    
    # Start WireGuard if config was provided
    if [ -n "$WG_CONFIG" ] && [ "$WG_CONFIG" != $'\n' ]; then
        echo "🌐 Starting WireGuard VPN..."
        sudo systemctl enable --now wg-quick@wg0
        echo "✅ WireGuard VPN started"
    fi
    
    echo ""
    echo "🎉 Setup complete!"
    echo ""
    echo "📋 What's installed:"
    echo "  • Deepin desktop environment"
    echo "  • Firefox & Google Chrome"
    echo "  • Full pentesting toolkit (Metasploit, Burp, nmap, etc.)"
    echo "  • Blue team tools (Suricata, Zeek, Wireshark)"
    echo "  • Development tools (Python, Docker, Go, Node.js)"
    echo "  • VPN support (WireGuard, Cisco AnyConnect)"
    echo ""
    echo "🔄 Reboot and login as 'jesus' user"
    echo ""
    read -p "Reboot now? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        sudo reboot
    fi
else
    echo "❌ Configuration test failed - check errors above"
    exit 1
fi
