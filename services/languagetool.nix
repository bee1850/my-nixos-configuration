{ outputs, config, pkgs, lib, ... }:
let
  servicePort = 9954;

in
{
  containers.languagetool =
    {
      autoStart = true;
      config = { config, pkgs, lib, ... }: {
        services.languagetool = {
          enable = true;
	  public = true;
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
