{ config, pkgs, lib, ... }:

let
  # (Keep your existing mkLegacySubpath, mkNativeSubpath, makeCard, and registeredServices blocks here)
in
{
  # =========================================================================
  # 1. CORE NETWORKING & FIREWALL
  # =========================================================================
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };

  networking.firewall = {
    allowedTCPPorts = [ 80 443 8443 ]; 
    allowedUDPPorts = [ 41641 ]; 
  };

  # =========================================================================
  # 2. BACKEND VPN DAEMONS
  # =========================================================================
  services.headscale = {
    enable = true;
    address = "127.0.0.1";
    port = 8080;
    settings = {
      server_url = "https://campgroundlabs.xyz:8443";
      dns = {
        magic_dns = true;
        base_domain = "homelab.net";
        nameservers = { global = [ "1.1.1.1" ]; };
      };
      wireguard = { listen_port = 41641; };
    };
  };

  services.headplane = {
    enable = true;
    settings = {
      server = {
        base_url = "https://campgroundlabs.xyz/vpn-admin"; 
      };
      headscale = {
        url = "http://127.0.0.1:8080";
        config_path = "/etc/headscale/config.yaml"; 
      };
    };
  };

  # =========================================================================
  # 3. CONSOLIDATED PROXY LAYER: Merging the Hub Array & Port 8443
  # =========================================================================
  services.nginx = {
    enable = true;

    virtualHosts."campgroundlabs.asuscomm.com" = {
      enableACME = true;
      forceSSL = true;
      serverAliases = [ "campgroundlabs.xyz" ];

      # Explicitly listen on both ports
      listen = [
        { addr = "0.0.0.0"; port = 443; ssl = true; }
        { addr = "0.0.0.0"; port = 8443; ssl = true; }
      ];

      # Mix your automated array generator with the custom root port router
      locations = 
        let
          partitioned = lib.lists.partition (s: s.useNativeSubpath or false) registeredServices;
          nativeServices = partitioned.right; 
          legacyServices = partitioned.wrong; 
        in
          (builtins.listToAttrs (map (service: {
            name = "/${service.path}/";
            value = mkLegacySubpath service;
          }) legacyServices)) 

          // (builtins.listToAttrs (map (service: {
            name = "/${service.path}/";
            value = mkNativeSubpath service;
          }) nativeServices))
          
          // (builtins.listToAttrs (map (service: {
            name = "/${service.path}";
            value = { return = "301 https://campgroundlabs.xyz/${service.path}/"; };
          }) registeredServices))
          
          // {
            # Core interceptor: If traffic hits port 8443 at "/", send to Headscale.
            # If it hits port 443, render the visual HTML dashboard list.
            "/" = {
              extraConfig = ''
                if ($server_port = 8443) {
                  proxy_pass http://127.0.0.1:8080;
                }
                charset utf-8;
              '';
              root = pkgs.writeTextDir "index.html" ''
                ...
              '';
            };
          };
    };
  };

  # =========================================================================
  # 4. GLOBAL SERVICE PROVISIONS
  # =========================================================================
  systemd.services.nginx.preStart = ''
    mkdir -p /run/nginx
    echo 'joe:$6$ejalmdDoznQXS6Mh$AATCMicDKyMghwja.SFfMA5bBz80M9qnLW3oWceDiaAuXMgxmlYr4WczgqSLermCqOzOe8jIodUVsKznsmATV.' > /run/nginx/.htpasswd
    chmod 600 /run/nginx/.htpasswd
  '';

  users.users.nginx.extraGroups = [ "acme" ];
  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "josephscampo@gmail.com";
      dnsProvider = "porkbun";
      environmentFile = "/etc/porkbun-api.secret";
    };
    
    # Tell ACME to fetch a wildcard cert covering everything
    certs."campgroundlabs.xyz" = {
      extraDomainNames = [ "*.campgroundlabs.xyz" ];
    };
  };
}