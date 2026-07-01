{ config, pkgs, lib, ... }:

let
  # Reusable subpath template
  mkSubpath = path: port: {
    proxyPass = "http://127.0.0.1:${toString port}/";
    proxyWebsockets = true;
    basicAuthFile = "/run/nginx/.htpasswd";
    extraConfig = ''
      sub_filter_types text/html text/css application/javascript;
      sub_filter 'href="/' 'href="/${path}/';
      sub_filter 'src="/' 'src="/${path}/';
      sub_filter 'url("/' 'url("/${path}/';
      sub_filter_once off;
    '';
  };

  # Helper function to generate individual HTML cards from the array data
  makeCard = service: ''
    <a href="/${service.path}/" class="card">
      <h3>${service.emoji} ${service.name}</h3>
      <p>${service.description}</p>
    </a>
  '';

  registeredServices = config.services.campground.hub;
in
{
  services.nginx.enable = true;

  services.nginx.virtualHosts."campground.asuscomm.com" = {
    enableACME = true;
    forceSSL = true;

    # Dynamically map the location paths and proxy settings
    locations = (builtins.listToAttrs (map (service: {
      name = "/${service.path}/";
      value = mkSubpath service.path service.port;
    }) registeredServices)) 
    
    // # Dynamically map the helper trailing-slash redirects
    (builtins.listToAttrs (map (service: {
      name = "/${service.path}";
      value = { return = "301 https://campground.asuscomm.com/${service.path}/"; };
    }) registeredServices))
    
    // # Core dashboard landing page at "/"
    {
      "/" = {
        extraConfig = "charset utf-8;";
        root = pkgs.writeTextDir "index.html" ''
          <!DOCTYPE html>
          <html>
          <head>
            <meta charset="utf-8">
            <title>Campground Home Lab</title>
            <style>
              body { font-family: sans-serif; background: #1a1a1a; color: #fff; text-align: center; padding-top: 50px; }
              .card { background: #2a2a2a; padding: 20px; border-radius: 8px; display: inline-block; margin: 15px; width: 200px; text-decoration: none; color: #00bcd4; border: 1px solid #444; text-align: left; }
              .card:hover { background: #333; border-color: #00bcd4; }
              .grid { display: flex; justify-content: center; flex-wrap: wrap; max-width: 900px; margin: 0 auto; }
            </style>
          </head>
            <body>
            <div style="max-width: 900px; margin: 0 auto; text-align: center; padding: 0 15px;">
              <h1 style="font-size: 2.5rem; margin-bottom: 5px;">⛺ Campground Server</h1>
              <p style="color: #aaa; margin-top: 0; margin-bottom: 40px;">Select an automated service:</p>
            </div>

            <div class="grid">
              ${lib.strings.concatStringsSep "\n" (map makeCard registeredServices)}
            </div>
          </body>
          </html>
        '';
      };
    };
  };

  systemd.services.nginx.preStart = "
    mkdir -p /run/nginx
    echo 'joe:$6$ejalmdDoznQXS6Mh$AATCMicDKyMghwja.SFfMA5bBz80M9qnLW3oWceDiaAuXMgxmlYr4WczgqSLermCqOzOe8jIodUVsKznsmATV.' > /run/nginx/.htpasswd
    chmod 600 /run/nginx/.htpasswd
  ";

  security.acme = { acceptTerms = true; defaults.email = "josephscampo@gmail.com"; };
  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
