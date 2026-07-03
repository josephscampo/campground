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
      PermitRootLogin = "prohibit-password"; 
    };
  };

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKxyMr1ZpmJoarQI2bIgsa75Ch2mLQh13LP1xzAgorcp"
  ];

  networking.firewall.allowedTCPPorts = [ 22 ];

}