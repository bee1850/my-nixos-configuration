{ config, pkgs, ... }:

let
  # --- Configuration Variables ---
  domainName = "nuc.dog-torino.ts.net";
  servicePort = 443; 
in
{
  # 1. Network & Firewall
  # Open the custom port (and standard 80/443 just in case)
  networking.firewall.allowedTCPPorts = [ 80 443 servicePort ];

  # 2. Secrets (Agenix)
  age.secrets = {
    nextcloud-admin-pass.file = ../secrets/nextcloud-admin-pass.age;
    nextcloud-s3-secret.file  = ../secrets/nextcloud-s3-secret.age;
    nextcloud-sse-key.file    = ../secrets/nextcloud-sse-key.age;
    nextcloud-sse-key.owner   = "nextcloud";
    sslCertificate.file       = ../secrets/certificate.age;
    sslCertificate.owner      = "nginx";
    sslCertificateKey.file    = ../secrets/certificateKey.age;
    sslCertificateKey.owner   = "nginx";
  };

  # 3. Nextcloud Service
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud32;
    hostName = domainName;
    https = true; 

    database.createLocally = true;
    config = {
      dbtype = "pgsql";
      adminpassFile = config.age.secrets.nextcloud-admin-pass.path;

      objectstore.s3 = {
        enable = true;
        bucket = "nextcloud-bee1850";
        region = "eu-central-1";
        useSsl = true;
        key = "AKIAWZS2DXAXAAAVGM6G"; 
        secretFile = config.age.secrets.nextcloud-s3-secret.path;
        sseCKeyFile = config.age.secrets.nextcloud-sse-key.path;
      };
    };

    settings = {
      trusted_domains = [ "localhost" "nuc" "192.168.0.107" domainName ];
      
      # [CRITICAL FIX 1] Tell Nextcloud it is running on this specific port
      # Without this, redirects (like after login) drop the port and fail.
      overwritehost = "${domainName}:${toString servicePort}";
      
      # [CRITICAL FIX 2] Force HTTPS protocol for link generation
      overwriteprotocol = "https";
    };

    configureRedis = true;
  };

  # 4. Web Server (Nginx) Configuration
  # [CRITICAL FIX 3] You must explicitly tell Nginx to listen on your custom port.
  services.nginx.virtualHosts.${domainName} = {
    # [CRITICAL FIX] We must add 'ssl = true' to the listen config
    listen = [
      { addr = "0.0.0.0"; port = servicePort; ssl = true; }
      { addr = "[::]";    port = servicePort; ssl = true; }
    ];
    
    # Enable SSL to generate the default "Snakeoil" (self-signed) certificate
    forceSSL = true; 
    sslCertificate = config.age.secrets.sslCertificate.path;
    sslCertificateKey = config.age.secrets.sslCertificateKey.path;
    enableACME = false; # We are not asking Let's Encrypt for a cert yet
  }; 
}
