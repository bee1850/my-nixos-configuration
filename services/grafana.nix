{ outputs, config, pkgs, lib, ... }:
{
  services.prometheus = {
        enable = true;
        port = 7776;
        globalConfig.scrape_interval = "15s";
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
        {
          job_name = "docker";
          static_configs = [
            {
              targets = [ toString config.virtualisation.docker.daemon.settings."metrics-addr" ];
            }
          ];
          scrape_interval = "15s";
        }
      ];

      exporters.node = {
        enable = true;
        port = 19002;
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

  services.grafana = {
    enable = true;
    settings = {
      server = { http_port = 3001; domain = "192.168.0.107"; root_url = "http://192.168.0.107"; };
      analytics.reporting_enabled = false;
    };
  };
  services.nginx = {
    enable = true;
    virtualHosts."192.168.0.107" = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString config.services.grafana.settings.server.http_port}";
        recommendedProxySettings = true;
        proxyWebsockets = true;
        extraConfig = ''
          		 if ($request_method = 'OPTIONS') {
                  add_header 'Access-Control-Allow-Origin' '*';
                  add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS';
                  #
                  # Custom headers and headers various browsers *should* be OK with but aren't
                  #
                  add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range';
                  #
                  # Tell client that this pre-flight info is valid for 20 days
                  #
                  add_header 'Access-Control-Max-Age' 1728000;
                  add_header 'Content-Type' 'text/plain; charset=utf-8';
                  add_header 'Content-Length' 0;
                  return 204;
               }
               if ($request_method = 'POST') {
                  add_header 'Access-Control-Allow-Origin' '*' always;
                  add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS' always;
                  add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range' always;
                  add_header 'Access-Control-Expose-Headers' 'Content-Length,Content-Range' always;
               }
               if ($request_method = 'GET') {
                  add_header 'Access-Control-Allow-Origin' '*' always;
                  add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS' always;
                  add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range' always;
                  add_header 'Access-Control-Expose-Headers' 'Content-Length,Content-Range' always;
               }
          	'';
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 ];
}
