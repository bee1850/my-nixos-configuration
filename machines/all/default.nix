{ outputs, config, pkgs, lib, ... }:
{
    nix = { 
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 30d";
      };
      settings.experimental-features = [ "nix-command" "flakes" ];
    };

  nixpkgs = {
    config.allowUnfree = true;
    overlays = [ outputs.overlays ];
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

  console.useXkbConfig = true; # use xkbOptions in tty.

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    resolutions = [{ x = 1920; y = 1080; }];
    virtualScreen = { x = 1920; y = 1080; };
    layout = "de";
    displayManager.sddm.enable = true;
    desktopManager.plasma5.enable = true;
    displayManager.defaultSession = "plasmawayland";
    autorun = true;
    libinput.enable = true;
  };

  services.xrdp = {
    enable = true;
    defaultWindowManager = "startplasma-x11";
    openFirewall = false;
  };

  environment.plasma5.excludePackages = [
    pkgs.libsForQt5.okular
  ];

  environment.variables = {
    TERMINAL = "alacritty";
    EDITOR = "vi";
  };

  programs.sway.enable = true;
  xdg.portal.wlr.enable = true;
  programs.zsh.enable = true;

  system.autoUpgrade = {
    enable = true;
    allowReboot = false;
  };

  sound.enable = true;
  hardware.pulseaudio.enable = true;

  users.users.berkan = {
    description = "Berkan E.";
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAVcE4X0CHiRy1GYX00HnUu7u1qgWZBcZaVYf3BzhSvN Private SSH Key" ];
  };

  environment.systemPackages = with pkgs; [
    vim
    wget
    alacritty
    zsh
    libsForQt5.plasma-workspace
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
      interval = "hourly";
      frequency = 12;
    };
  };

  
  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  programs.ssh.startAgent = true;

  networking.firewall.enable = true;

}