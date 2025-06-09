{
  description = "Personal NixOS pentesting setup";
  
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
  };
  
  outputs = { self, nixpkgs }: {
    nixosConfigurations.pentest = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        # Hardware configuration - auto-generated during installation
        ./hardware-configuration.nix
        
        ({ config, pkgs, ... }: {
          # Enable flakes
          nix.settings.experimental-features = [ "nix-command" "flakes" ];
          
          # Boot
          boot.loader.systemd-boot.enable = true;
          boot.loader.efi.canTouchEfiVariables = true;
          
          # Network
          networking.hostName = "pentest-vm";
          networking.networkmanager.enable = true;
          networking.firewall.enable = false;
          
          # WireGuard support (config provided via setup scripts)
          networking.wireguard.enable = true;
          
          # Users - Jesus user (password set during installation)
          users.users.jesus = {
            isNormalUser = true;
            extraGroups = [ "wheel" "networkmanager" "docker" "wireshark" ];
            # No password set here - configured during install/setup
          };
          
          # Disable root user completely
          users.users.root.hashedPassword = "!";
          
          # Require password for sudo (more secure)
          security.sudo.wheelNeedsPassword = true;
        
          # Desktop - Deepin
          services.xserver.enable = true;
          services.xserver.displayManager.lightdm.enable = true;
          services.xserver.desktopManager.deepin.enable = true;
          
          # Audio - Use PipeWire (modern audio system)
          hardware.pulseaudio.enable = false;
          security.rtkit.enable = true;
          services.pipewire = {
            enable = true;
            alsa.enable = true;
            alsa.support32Bit = true;
            pulse.enable = true;
          };          
          
          # Services
          services.openssh.enable = true;
          virtualisation.docker.enable = true;
          programs.wireshark.enable = true;
          
          # VPN support
          networking.networkmanager.plugins = with pkgs; [
            networkmanager-openconnect
          ];
          
          # Allow unfree packages
          nixpkgs.config.allowUnfree = true;
          
          # Packages
          environment.systemPackages = with pkgs; [
            # Desktop apps
            firefox google-chrome kdePackages.kate kdePackages.konsole kdePackages.dolphin
            
            # VPN clients
            openconnect wireguard-tools networkmanager-openconnect
            
            # Terminal tools
            curl wget git vim tmux tree htop
            
            # Python
            python3 python3Packages.pip python3Packages.virtualenv
            python3Packages.requests python3Packages.scapy
            
            # Network scanning
            nmap masscan whatweb nikto
            
            # Web testing
            sqlmap burpsuite dirb ffuf gobuster
            
            # Password attacks
            thc-hydra hashcat john
            
            # Exploitation
            metasploit exploitdb
            
            # Wireless
            aircrack-ng kismet reaverwps-t6x
            
            # Network analysis
            wireshark tcpdump bettercap ettercap
            
            # Reverse engineering
            ghidra radare2 gdb
            
            # Forensics
            sleuthkit volatility3 binwalk
            
            # Containers
            docker docker-compose
            
            # Windows/AD
            python3Packages.impacket enum4linux
            
            # Network tools
            netcat-gnu socat traceroute whois dig
            
            # Blue team
            suricata zeek osquery
            
            # Development
            gcc gnumake nodejs go
          ];
          
          system.stateVersion = "24.05";
        })
      ];
    };
  };
}
