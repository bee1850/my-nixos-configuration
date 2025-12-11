{ outputs, config, pkgs, lib, ... }:
{
  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
    optimise.automatic = true; # Runs daily at 3:45 AM
    settings.experimental-features = [ "nix-command" "flakes" ];
  };

  nixpkgs = {
    config.allowUnfree = true;
    overlays = [ outputs.overlays.default ];
  };

  time.timeZone = "Europe/Berlin";
  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_US.UTF-8";

    extraLocaleSettings = {
      LC_ADDRESS = "de_DE.UTF-8";
      LC_IDENTIFICATION = "de_DE.UTF-8";
      LC_MEASUREMENT = "de_DE.UTF-8";
      LC_MONETARY = "de_DE.UTF-8";
      LC_NAME = "de_DE.UTF-8";
      LC_NUMERIC = "de_DE.UTF-8";
      LC_TELEPHONE = "de_DE.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };
  };

  console.useXkbConfig = true; # use xkbOptions in tty

  environment.variables = {
    TERMINAL = "alacritty";
    EDITOR = "vi";
  };

  programs.zsh.enable = true;

  system.autoUpgrade = {
    enable = true;
    allowReboot = false;
  };

  services.tailscale = {
    enable = true;
    extraDaemonFlags = [ "--no-logs-no-support" ];
  };
  services.pulseaudio.enable = false;

  users.users.berkan = {
    isNormalUser = true;
    description = "Berkan E.";
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAVcE4X0CHiRy1GYX00HnUu7u1qgWZBcZaVYf3BzhSvN"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGjO8XQy9w6Yas1DaTq+4vhWiFeyz6uZcngaHkIeUwf8"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICjtJi8Rbvbe0xEAhMRTZj7f8mOtpBtT5VJj+QB5dDSg"
    ];
  };

  environment.systemPackages = with pkgs; [
    vim
    direnv
    wget
    alacritty
    rrsync
    neovim
    zsh
    zsh-powerlevel10k
    git
  ];

  # Enable ClamAV
  services.clamav = {
    daemon = {
      enable = true;
    };
    updater = {
      enable = true;
      interval = "weekly";
      frequency = 2;
    };
  };

  # Enable Local Prometheus Service and Exporter
  services.prometheus = {
      scrapeConfigs = [
        {
          job_name = "node";
          static_configs = [
            {
              targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.node.port}" ];
            }
          ];
          scrape_interval = "3s";
        }
      ];

      exporters.node = {
        enable = true;
        port = 9002;

        # Updated list of enabled collectors
        enabledCollectors = [
          "ethtool"
          "softirqs"
          "systemd"
          "tcpstat"
          "wifi" # May or may not produce metrics depending on system/NixOS implementation
        ];
      };
  };

  # Enable the OpenSSH SSH Agent
  programs.ssh.startAgent = true;

  networking.firewall.enable = true;

}
