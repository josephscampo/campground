{ config, pkgs, ... }:

{
  services.nginx.enable = true;
  
  services.nginx.virtualHosts."campground.asuscomm.com" = {
    enableACME = true;
    forceSSL = true;
    
    locations."/" = {
      proxyPass = "http://127.0.0.1:61208";
      proxyWebsockets = true;
    
      # Point Nginx to a path that your config will build automatically
      basicAuthFile = "/run/nginx/.htpasswd"; 
    };
  };
  
  # Systemd automation trick: Create the password file in RAM on startup!
  systemd.services.nginx = {
    # Using a normal double-quoted string lets us pass the $ symbols completely untouched by Nix
    preStart = "
      mkdir -p /run/nginx
      echo 'joe:$6$ejalmdDoznQXS6Mh$AATCMicDKyMghwja.SFfMA5bBz80M9qnLW3oWceDiaAuXMgxmlYr4WczgqSLermCqOzOe8jIodUVsKznsmATV.' > /run/nginx/.htpasswd
      chmod 600 /run/nginx/.htpasswd
    ";
  };
  
  security.acme = {
    acceptTerms = true;
    defaults.email = "josephscampo@gmail.com"; 
  };

  # Open HTTP (80) and HTTPS (443) ports in the NixOS firewall
  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
