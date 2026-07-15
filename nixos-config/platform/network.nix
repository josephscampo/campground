{ config, pkgs, ... }:

{
  # Enable networking
  networking.networkmanager.enable = true;

  services.openssh = {
    enable = true;
    openFirewall = true;
    ports = [ 22 ];
    settings = {
      # Disable passwords entirely for the main OS over the internet
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "prohibit-password"; 
    };
  };

  services.avahi.enable = true;
  networking.firewall.allowedUDPPorts = [ 5353 ];
  
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKxyMr1ZpmJoarQI2bIgsa75Ch2mLQh13LP1xzAgorcp"
  ];

  # ipv6 dns
  # Automatically update DuckDNS securely
  systemd.services.duckdns-updater = {
    description = "Update DuckDNS IPv6 address securely";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    
    serviceConfig = {
      Type = "oneshot";
      EnvironmentFile = "/etc/duckdns.secret";

      # Use writeShellScript to eliminate the quote-escaping mess
      ExecStart = pkgs.writeShellScript "update-duckdns" ''
        # 1. Grab the stable global IPv6 address
        IP=$(${pkgs.iproute2}/bin/ip -6 addr show dev eno1 scope global | ${pkgs.gnugrep}/bin/grep -v temporary | ${pkgs.gnugrep}/bin/grep -oE '[0-9a-fA-Fmap:]+/[0-9]+' | ${pkgs.coreutils}/bin/head -n1 | ${pkgs.coreutils}/bin/cut -d/ -f1)

        # 2. Ship it off to DuckDNS using the variable loaded from EnvironmentFile
        ${pkgs.curl}/bin/curl -k "https://www.duckdns.org/update?domains=campgroundlabs&token=$DUCKDNS_TOKEN&ipv6=$IP"
      '';
    };
  };

  systemd.timers.duckdns-updater = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "1min";
      OnUnitActiveSec = "15min";
      Unit = "duckdns-updater.service";
    };
  };
}