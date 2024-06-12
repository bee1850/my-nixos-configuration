# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ outputs, config, pkgs, lib, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    supportedFilesystems = [ "exfat" "ntfs" ];
  };


  networking.hostName = "nuc"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.
  networking.nameservers = [ "8.8.8.8" "1.1.1.1" ];

  services.xrdp = {
    enable = true;
    defaultWindowManager = "startplasma-x11";
    openFirewall = true;
  };

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    openFirewall = true;
    settings.AllowUsers = [ "berkan" ];
  };

  networking.nftables.enable = true;

  users.groups = {
    dockeruser = {
      gid = 1005;
    };
  };
  users.users.dockeruser = {

    isNormalUser = true;
    createHome = lib.mkForce false;
    shell = pkgs.bash;
    uid = 1005;
    group = lib.mkForce "dockeruser";
  };

  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    autoPrune = {
      enable = true;
      flags = [ "-all" ];
    };
    liveRestore = true;
  };

  services.fail2ban = {
    enable = true;
    bantime-increment = {
      enable = true;
      maxtime = "48h";
      multipliers = "1 2 4 8 16 32 64";
    };
  };

  services.samba = {
    enable = true;
    securityType = "user";
    openFirewall = true;
    shares = {
      intenso = {
        path = "/mnt/intenso/";
        browseable = "yes";
        "read only" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "dockeruser";
        "force group" = "dockeruser";
      };
      docker_persistent = {
        path = "/docker_persistent/";
        browseable = "yes";
        "read only" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "dockeruser";
        "force group" = "dockeruser";
      };
    };

  };

  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };

  services.minidlna = {
    enable = true;
    openFirewall = true;
    settings = {
      # notify_interval = 500; # Use when needed
      media_dir = [ "/mnt/intenso/media" ];
      inotify = "yes";
      friendly_name = "Home Drive";
    };
  };

  environment.etc."nextcloud-admin-pass".text = "ZozB^Sh9dw#cgP@";
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud28;
    hostName = "192.168.0.107";
    maxUploadSize = "10G";
    configureRedis = true;
    datadir = "/mnt/intenso/nextcloud";
    config.adminpassFile = "/etc/nextcloud-admin-pass";
    extraOptions.enabledPreviewProviders = [
      "OC\\Preview\\BMP"
      "OC\\Preview\\GIF"
      "OC\\Preview\\JPEG"
      "OC\\Preview\\Krita"
      "OC\\Preview\\MarkDown"
      "OC\\Preview\\MP3"
      "OC\\Preview\\OpenDocument"
      "OC\\Preview\\PNG"
      "OC\\Preview\\TXT"
      "OC\\Preview\\XBitmap"
      "OC\\Preview\\HEIC"
      "OC\\Preview\\Movie"
    ];
  };

  services.nginx.virtualHosts."192.168.0.107".listen = [{ addr = "127.0.0.1"; port = 7654; }];

  services.adguardhome = {
    enable = true;
    mutableSettings = true;
    openFirewall = true;
    settings.bind_port = 9001;
    settings.bind_host = "192.168.0.107";
  };

  environment.systemPackages = with pkgs; [
    wireguard-tools
  ];

  services.clamav.daemon.enable = lib.mkForce false; # Currently /dev/sdb is way to big to be scanned by ClamAV

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = lib.mkForce false;

  # enable NAT
  networking.nat.enable = true;
  networking.nat.externalInterface = "eth0";
  networking.nat.internalInterfaces = [ "wg0" ];
  networking.firewall = {
    allowedUDPPorts = [ 51820 ];
  };

  networking.wireguard.interfaces = {
    # "wg0" is the network interface name. You can name the interface arbitrarily.
    wg0 = {
      # Determines the IP address and subnet of the server's end of the tunnel interface.
      ips = [ "10.100.0.1/24" ];

      # The port that WireGuard listens to. Must be accessible by the client.
      listenPort = 51820;

      # This allows the wireguard server to route your traffic to the internet and hence be like a VPN
      # For this to work you have to set the dnsserver IP of your router (or dnsserver of choice) in your clients
      postSetup = ''
        ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.100.0.0/24 -o eth0 -j MASQUERADE
      '';

      # This undoes the above command
      postShutdown = ''
        ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.100.0.0/24 -o eth0 -j MASQUERADE
      '';

      # Path to the private key file.
      #
      # Note: The private key can also be included inline via the privateKey option,
      # but this makes the private key world-readable; thus, using privateKeyFile is
      # recommended.
      privateKeyFile = "/home/berkan/wireguard_keys/private";

      peers = [
        # List of allowed peers.
        {
          # John Doe
          publicKey = "/K7qw1soMTA+TNsN6+ZIhF/UaDJAFmyL5eOydk1wcVw=";
          allowedIPs = [ "10.100.0.3/32" ];
        }
      ];
    };
  };

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "23.11"; # Did you read the comment?

}


