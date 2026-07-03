{ config, pkgs, ... }:

{

  # Allow the server to pass packets between devices (required for Exit Nodes/routing)
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };

  # Headscale configuration
  services.headscale = {
    enable = true;
    address = "127.0.0.1";
    port = 8080;
    settings = {
      # Change this to point to your new subdomain:
      server_url = "https://vpn.campgroundlabs.xyz";
      dns = {
        magic_dns = true;
        base_domain = "vpnet.campgroundlabs.xyz";
        nameservers = { global = [ "1.1.1.1" ]; };
      };
      wireguard = { listen_port = 41641; };
    };
  };

  services.headplane = {
    enable = true;
    settings = {
      server = {
        host = "0.0.0.0";
        base_url = "https://vpn.campgroundlabs.xyz"; 
        cookie_secret_path = "/etc/headplane_cookie.secret";
        port = 3300;
      };
      headscale = {
        url = "http://127.0.0.1:8080";
        config_path = "/etc/headscale/config.yaml"; 
      };
    };
  };
}