# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).

{ outputs, config, pkgs, lib, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  #age.secrets.berkan-pw.file = ./secrets/berkan-pw.age;

  # Use the systemd-boot EFI boot loader.
  boot = {
    loader.systemd-boot.enable = lib.mkForce false;
    bootspec.enable = true;
    loader.timeout = 0;
    lanzaboote = {
      configurationLimit = 3;
      enable = true;
      pkiBundle = "/etc/secureboot";
    };
    supportedFilesystems = [ "exfat" "ntfs" ];
    loader.efi.canTouchEfiVariables = true;
  };

  nix = {
    settings = {
      substituters = [ "https://nix-gaming.cachix.org" ];
      trusted-public-keys = [ "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4=" ];
    };
  };

  networking.hostName = "prometheus"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.
  networking.nameservers = [ "127.0.0.1" ]; #"1.1.1.1" "8.8.8.8" ];

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";


  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    ntfs3g
    exfat
    stable.AusweisApp2
    ngrok
    nodejs
    nodePackages.prettier
    nodePackages.eslint
    virt-manager
    qemu
    looking-glass-client
    lutris
    protonup-ng
    steam
    wireshark
    steam-run
  ];

  ## Gaming
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };

  # Wireshark
  programs.wireshark.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  users.users.berkan.extraGroups = [ "wireshark" "libvirtd" "networkmanager" ]; # Enable ‘sudo’ for the user.

  # List services that you want to enable:

  # Mullvad VPN Daemon
  services.mullvad-vpn = {
    enable = true;
    enableExcludeWrapper = false;
  };

  # Enable Fail2Ban
  services.fail2ban = {
    enable = true;
    maxretry = 6;
    bantime = "1h";
  };

  containers.database =
    {
      config =
        { config, pkgs, ... }:
        {
          environment.shellAliases = {
            psql-login = "sudo -u postgres psql postgres";
          };
          system.stateVersion = "23.05";
          services.postgresql.enable = true;
          services.pgadmin.enable = true;
          services.pgadmin.initialEmail = "bee1850@thi.de";
          services.pgadmin.initialPasswordFile = pkgs.writeText "pgadminPW" ''
            admin
          '';
        };
    };

  containers.adguard-home =
    {
      config =
        { config, pkgs, ... }:
        {
          system.stateVersion = "23.05";
          services.adguardhome = {
            enable = true;
            openFirewall = true;
          };
        };
      autoStart = true;
    };

  containers.minecraft-server =
    {
      config =
        { config, pkgs, ... }:
        {
          system.stateVersion = "23.05";
          nixpkgs.config.allowUnfree = true;
          services.minecraft-server = {
            enable = true;
            package = pkgs.minecraftServers.vanilla-1-18;
            eula = true;
            openFirewall = true;
          };
        };
      forwardPorts = [
        {
          containerPort = 25565;
          hostPort = 25565;
          protocol = "tcp";
        }
      ];
    };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Enable Virtualisation
  virtualisation = {
    # waydroid.enable = true; # Doesnt Start - Networking issues
    libvirtd.enable = true;
    docker.enable = false;
  };
  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ];
  networking.firewall.allowedUDPPorts = [ 24727 ]; # 24727:AusweisApp2

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

}

