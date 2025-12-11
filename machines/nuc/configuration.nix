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
    daemon.settings = {
      "metrics-addr" = "127.0.0.1:9323"
    };
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
    openFirewall = true;
    settings = {
      global = {
        security = "user";
      };
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

  environment.systemPackages = with pkgs; [
    wireguard-tools
    tailscale
    wakeonlan
  ];

  services.clamav.daemon.enable = lib.mkForce false; # Currently /dev/sdb is way to big to be scanned by ClamAV

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall = {
    enable = true;
    trustedInterfaces = [ "tailscale0" ];
    allowedUDPPorts = [ config.services.tailscale.port ];
    allowedTCPPorts = [ 22 ];
  };

  # enable NAT
  networking.nat.enable = true;
  networking.nat.externalInterface = "eth0";

  # enable the tailscale service
  services.tailscale = {
    enable = true;
    extraSetFlags = [ "--advertise-exit-node" ];
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


