{ config, pkgs, ... }:

{
  networking.hostName = "campground-server"; 

  # Enable networking
  networking.networkmanager.enable = true;

  services.openssh = {
    enable = true;
    ports = [ 22 ];
    settings = {
      # Disable passwords entirely for the main OS over the internet
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no"; 
    };
  };

  networking.firewall.allowedTCPPorts = [ 22 ];

}