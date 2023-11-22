# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

# NixOS-WSL specific options are documented on the NixOS-WSL repository:
# https://github.com/nix-community/NixOS-WSL

{ outputs, config, lib, pkgs, ... }:

{
  networking.hostName = "gaia";
  
  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d -d";
    };
    settings.experimental-features = [ "nix-command" "flakes" ];
  };

  nixpkgs = {
    config.allowUnfree = true;
    overlays = [ outputs.overlays.stable-packages ];
  };

  wsl.enable = true;
  wsl.defaultUser = "berkan";
  
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
    packages = with pkgs; [ vscode ];
  };

  environment.systemPackages = with pkgs; [
    vim
    wget
    alacritty
    nodejs
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

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}

