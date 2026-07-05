{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [ wireguard-tools ];
 
  networking.nat = {
    enable = true;
    enableIPv6 = true;
    externalInterface = "eno1";
    # Tell the host to explicitly masquerade the specific subnets wg-easy hands out
    internalIPs = lib.mkForce [ "10.8.0.0/24" ];
    internalIPv6s = lib.mkForce [ ];    
  };
  
  # Force manual injection into the root iptables table
  networking.firewall = {
    enable = true;
    trustedInterfaces = [ "docker0" ];
    allowedUDPPorts = [ 51820 ];
    allowedTCPPorts = [ 51821 ]; 

    extraCommands = ''
      # A. FORWARDING RULES - Allow packets to hop across interfaces
      iptables -D FORWARD -s 10.8.0.0/24 -j ACCEPT 2>/dev/null || true
      iptables -A FORWARD -s 10.8.0.0/24 -j ACCEPT
      iptables -D FORWARD -d 10.8.0.0/24 -m state --state ESTABLISHED,RELATED -j ACCEPT 2>/dev/null || true
      iptables -A FORWARD -d 10.8.0.0/24 -m state --state ESTABLISHED,RELATED -j ACCEPT

      ip6tables -D FORWARD -s fdc9:281f:04d7:9ee9::/64 -j ACCEPT 2>/dev/null || true
      ip6tables -A FORWARD -s fdc9:281f:04d7:9ee9::/64 -j ACCEPT
      ip6tables -D FORWARD -d fdc9:281f:04d7:9ee9::/64 -m state --state ESTABLISHED,RELATED -j ACCEPT 2>/dev/null || true
      ip6tables -A FORWARD -d fdc9:281f:04d7:9ee9::/64 -m state --state ESTABLISHED,RELATED -j ACCEPT

      # B. NAT MASQUERADE RULES - Catch everything regardless of eno1 vs Wi-Fi route choices
      iptables -t nat -D POSTROUTING -s 10.8.0.0/24 -j MASQUERADE 2>/dev/null || true
      iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -j MASQUERADE

      ip6tables -t nat -D POSTROUTING -s fdc9:281f:04d7:9ee9::/64 -j MASQUERADE 2>/dev/null || true
      ip6tables -t nat -A POSTROUTING -s fdc9:281f:04d7:9ee9::/64 -j MASQUERADE
    '';
  };


  # Automatically create the host volume directory with correct permissions
  systemd.tmpfiles.rules = [
    "d /var/lib/wg-easy 0700 root root -"
  ];

  # 2. Configure the OCI module to use Docker
  virtualisation.oci-containers = {
    backend = "docker"; # Swapped to docker
    containers = {
      wg-easy = {
        image = "ghcr.io/wg-easy/wg-easy:latest";
        
        # Put the explicit port forwarding rules back
        ports = [
          "51820:51820/udp"
          "51821:51821/tcp"
        ];

        environmentFiles = [
          "/etc/wg-easy.secret"
        ];

        environment = {
          WG_HOST = "campgroundlabs.xyz"; 
          WG_DEFAULT_DNS = "1.1.1.1, 1.0.0.1"; 
          WG_LANG = "en";
          WG_ENABLE_IPV6 = "true";
          WG_IPV6_NETWORK = "fdc9:281f:04d7:9ee9::/64";
          
          # Force the inner script to pass modern nftables commands 
          # instead of searching for missing legacy kernel modules
          WG_IPTABLES_NFT = "1"; 
          WG_POST_UP = "true";
          WG_PRE_DOWN = "true";
          WG_MTU = "1360";
        };

        volumes = [
          "/var/lib/wg-easy:/etc/wireguard"
        ];

        extraOptions = [
          "--cap-add=NET_ADMIN"
          "--cap-add=SYS_MODULE"
          "--sysctl=net.ipv4.ip_forward=1"
          "--sysctl=net.ipv4.conf.all.src_valid_mark=1"
          "--sysctl=net.ipv6.conf.all.forwarding=1"
        ];
        
      };
    };
  };

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
    "net.ipv6.conf.default.forwarding" = 1;
    "net.ipv4.conf.all.rp_filter" = 2;
    "net.ipv4.conf.default.rp_filter" = 2;
    "net.ipv6.conf.all.disable_ipv6" = 0;
    "net.ipv6.conf.default.disable_ipv6" = 0;
  };
}