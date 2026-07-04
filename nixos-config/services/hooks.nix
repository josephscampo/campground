{ config, pkgs, ... }:

{
    networking.firewall.allowedTCPPorts = [ 9000 ];
    services.webhook = {
        enable = true;
        hooks = {
            echo = {
                execute-command = "echo";
                response-message = "Webhook is reachable!";
            };
        };
    };
}
