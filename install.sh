#!/bin/bash
# Automated NixOS installation with pentesting flake
set -e

echo "🚀 Installing NixOS with Pentesting Configuration"
echo "⚠️  WARNING: This will erase /dev/vda completely!"
read -p "Continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
fi

# Unmount any existing mounts first
echo "🔄 Cleaning up any existing mounts..."
sudo umount /mnt/boot 2>/dev/null || true
sudo umount /mnt 2>/dev/null || true
sudo umount /dev/vda1 2>/dev/null || true  
sudo umount /dev/vda2 2>/dev/null || true

# Partition the disk
echo "💾 Partitioning disk..."
sudo fdisk /dev/vda << EOF
g
n
1

+1G
t
1
n
2


w
EOF

# Wait a moment for the kernel to update partition table
echo "⏳ Waiting for partition table update..."
sleep 2
sudo partprobe /dev/vda || true

# Unmount again in case kernel remounted anything
echo "🔄 Final cleanup of mounts..."
sudo umount /mnt/boot 2>/dev/null || true
sudo umount /mnt 2>/dev/null || true
sudo umount /dev/vda1 2>/dev/null || true  
sudo umount /dev/vda2 2>/dev/null || true

# Format partitions
echo "📂 Formatting partitions..."
sudo mkfs.fat -F 32 -n boot /dev/vda1
sudo mkfs.ext4 -L nixos /dev/vda2

# Mount partitions
echo "🔗 Mounting partitions..."
sudo mount /dev/disk/by-label/nixos /mnt
sudo mkdir -p /mnt/boot
sudo mount /dev/disk/by-label/boot /mnt/boot

# Clone the repo
echo "📦 Cloning configuration..."
rm -rf /tmp/nixos-config 2>/dev/null || true
git clone https://github.com/EverydayEnder/nix.git /tmp/nixos-config
cd /tmp/nixos-config

# Generate hardware config for this machine
echo "🔧 Generating hardware configuration..."
sudo nixos-generate-config --root /mnt
sudo cp /mnt/etc/nixos/hardware-configuration.nix ./hardware-configuration.nix

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
    sudo mkdir -p /mnt/etc/wireguard
    echo "$WG_CONFIG" | sudo tee /mnt/etc/wireguard/wg0.conf > /dev/null
    sudo chmod 600 /mnt/etc/wireguard/wg0.conf
    echo "✅ WireGuard configuration saved"
else
    echo "⚠️  Skipping WireGuard setup"
fi

# Install NixOS with your flake
echo "⚙️  Installing NixOS (this will take 15-30 minutes)..."
sudo nixos-install --flake .#pentest --root /mnt

echo "🎉 Installation complete!"
echo "💡 Set password for jesus user:"
sudo nixos-enter --root /mnt -c "passwd jesus"

if [ -n "$WG_CONFIG" ] && [ "$WG_CONFIG" != $'\n' ]; then
    echo "🌐 WireGuard VPN config saved - enable with: sudo systemctl enable --now wg-quick@wg0"
fi

echo "🔄 Ready to reboot!"
read -p "Reboot now? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo reboot
fi
