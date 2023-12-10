# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

# NixOS-WSL specific options are documented on the NixOS-WSL repository:
# https://github.com/nix-community/NixOS-WSL

{ outputs, config, lib, pkgs, ... }:

{
  networking.hostName = "morpheus";

  wsl.enable = true;
  wsl.defaultUser = "berkan";

  services.openssh.enable = true;
  nix.settings.trusted-users = [ "berkan" "root" "nixremote" "@wheel" ];
  nix.extraOptions = ''
    secret-key-files = /root/cache-priv-key.pem
  '';

  containers.database =
    {
      restartIfChanged = true;
      config =
        { config, pkgs, ... }:
        {
          system.stateVersion = "23.05";
          environment.shellAliases = {
            psql-login = "sudo -u postgres psql postgres";
          };

          nixpkgs.config.allowUnfree = true;

          services.mongodb = {
            enable = true;
            enableAuth = true;
            bind_ip = "0.0.0.0";
            initialRootPassword = "root";
          };

          services.postgresql.enable = true;
          services.pgadmin.enable = true;
          services.pgadmin.initialEmail = "bee1850@thi.de";
          services.pgadmin.initialPasswordFile = pkgs.writeText "pgadminPW" ''
            adminadmin
          '';
          #services.prometheus.exporters.postgres.enable = true;
          #services.prometheus.exporters.postgres.port = 9003;
        };
        forwardPorts = [
        {
          containerPort = 5432;
          hostPort = 5432;
          protocol = "tcp";
        }
        {
          containerPort = 5050;
          hostPort = 5050;
          protocol = "tcp";
        }
        {
          containerPort = 27017;
          hostPort = 27017;
          protocol = "tcp";
        }
      ];
    };

   networking.firewall.allowedTCPPorts = [ "5432" "5050" "27017" ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}

