{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ wireguard-tools ];
 
  networking.nat = {
    enable = true;
    enableIPv6 = true;
    externalInterface = "eno1";
    internalInterfaces = [ "wg0" ];
  };
  
  # Open ports in the firewall
  networking.firewall = {
    allowedTCPPorts = [ ]; # Dropped 53 here so you aren't an open resolver on eno1
    allowedUDPPorts = [ 51820 ]; # Only open WireGuard globally
    
    # Trust the WireGuard interface completely so clients can access DNS (dnsmasq)
    trustedInterfaces = [ "wg0" ];
  };

  networking.wg-quick.interfaces = {
    wg0 = {
      address = [ "10.0.0.1/24" "fdc9:281f:04d7:9ee9::1/64" ];
      listenPort = 51820;
      privateKeyFile = "/etc/wireguard-privatekey.secret";

      # Changed -s flags to use proper network base addresses
      postUp = ''
        ${pkgs.iptables}/bin/iptables -A FORWARD -i wg0 -j ACCEPT
        ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.0.0.0/24 -o eno1 -j MASQUERADE
        ${pkgs.iptables}/bin/ip6tables -A FORWARD -i wg0 -j ACCEPT
        ${pkgs.iptables}/bin/ip6tables -t nat -A POSTROUTING -s fdc9:281f:04d7:9ee9::/64 -o eno1 -j MASQUERADE
      '';

      preDown = ''
        ${pkgs.iptables}/bin/iptables -D FORWARD -i wg0 -j ACCEPT
        ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.0.0.0/24 -o eno1 -j MASQUERADE
        ${pkgs.iptables}/bin/ip6tables -D FORWARD -i wg0 -j ACCEPT
        ${pkgs.iptables}/bin/ip6tables -t nat -D POSTROUTING -s fdc9:281f:04d7:9ee9::/64 -o eno1 -j MASQUERADE
      '';

      peers = [
        { # iphone manual
          publicKey = "IuREBf6VdcV9gWOQa6tgGvutUFAzj6mX9K5cSEmLVSo=";
          allowedIPs = [ "10.0.0.2/32" "fdc9:281f:04d7:9ee9::2/128" ];
        }
      ];
    };
  };
  
  services = {
    dnsmasq = {
      enable = true;
      settings = {
        interface = "wg0";
        bind-interfaces = true; 
      };
    };
  };

  # Force dnsmasq to wait for the WireGuard interface to exist
  systemd.services.dnsmasq = {
    after = [ "wireguard-wg0.service" "network-online.target" ];
    wants = [ "wireguard-wg0.service" ];
  };

  # The missing link: Explicitly turn on packet forwarding in the kernel
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
    "net.ipv6.conf.default.forwarding" = 1;

    # Keep your existing adjustments
    "net.ipv4.conf.all.rp_filter" = 0;
    "net.ipv4.conf.default.rp_filter" = 0;
    "net.ipv6.conf.all.disable_ipv6" = 0;
    "net.ipv6.conf.default.disable_ipv6" = 0;
  };

  
}