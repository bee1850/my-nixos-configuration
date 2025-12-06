{ outputs, config, pkgs, lib, ... }:
{
  containers.prometheus = {
    autoStart = true;
    bindMounts."/secrets" = { hostPath = "/home/berkan/secrets"; isReadOnly = true; };
    config = { config, pkgs, lib, ... }: {
      services.prometheus = {
        enable = true;
        port = 7776;
        globalConfig.scrape_interval = "15s";
        scrapeConfigs = [
          {
            job_name = "prometheus";
            static_configs = [{ targets = [ "192.168.0.107:7776" ]; }];
          }
          {
            job_name = "sonarr-exporter";
            static_configs = [{ targets = [ "192.168.0.107:9707" ]; }];
          }
          {
            job_name = "radarr-exporter";
            static_configs = [{ targets = [ "192.168.0.107:9708" ]; }];
          }
          {
            job_name = "prowlarr-exporter";
            static_configs = [{ targets = [ "192.168.0.107:9709" ]; }];
          }
        ];
        exporters = {
          exportarr-sonarr = {
            enable = true;
            url = "http://192.168.0.107:8989";
            port = 9707;
            environment = {
              API_KEY = "e87ea4c62fc44190af213487851231c0";
            };
          };
          exportarr-radarr = {
            enable = true;
            url = "http://192.168.0.107:7878";
            port = 9708;
            environment = {
              API_KEY = "a7c11c093c454970a2c2eefcde84e661";
            };
          };
          exportarr-prowlarr = {
            enable = true;
            url = "http://192.168.0.107:9696";
            port = 9709;
            environment = {
              API_KEY = "1dd4b43be03848afaa3f065e686cadc1";
              PROWLARR__BACKFILL = "true";
            };
          };
        };
      };
      system.stateVersion = "24.11";
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
        proxyPass = "http://127.0.0.1:${toString config.services.grafana.port}";
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
