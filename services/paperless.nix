{ outputs, config, pkgs, lib, ... }:
let
  servicePort = config.services.paperless.port;

in
{
  containers.paperless =
    {
      autoStart = true;
      bindMounts."/var/lib/paperless" = { hostPath = "/mnt/intenso/paperless"; isReadOnly = false; };
      config = { config, pkgs, lib, ... }: {
        services.paperless = {
          enable = true;
          port = servicePort;
        };
      };
      forwardPorts = [{
        containerPort = servicePort;
        hostPort = servicePort;
        protocol = "tcp";
      }];
    };
      networking.firewall.allowedTCPPorts = [ servicePort ];

}
