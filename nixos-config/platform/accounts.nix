{ config, pkgs, ... }:

{
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."joe" = {
    isNormalUser = true;
    description = "joe";
    extraGroups = [ "networkmanager" "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKxyMr1ZpmJoarQI2bIgsa75Ch2mLQh13LP1xzAgorcp"
    ];
    packages = with pkgs; [
      kdePackages.kate
    #  thunderbird
    ];
  };
}