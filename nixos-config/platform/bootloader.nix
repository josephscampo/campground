{ config, pkgs, ... }:

{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # 1. Hardware network modules for the NUC
  boot.initrd.availableKernelModules = [ "r8169" "e1000e" "igb" ];

  # 2. Key-Based Boot Stage SSH
  boot.initrd.network = {
    enable = true;
    ssh = {
      enable = true;
      port = 22;
      
      # Paste your laptop's public key here to allow it to bypass passwords on boot
      authorizedKeys = [ 
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKxyMr1ZpmJoarQI2bIgsa75Ch2mLQh13LP1xzAgorcp" 
      ];

      # Points to the host key file we generated earlier
      hostKeys = [ "/etc/secrets/initrd_ssh_host_ed25519_key" ];
    };
  };
}
