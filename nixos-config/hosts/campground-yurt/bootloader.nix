{ config, pkgs, ... }:

{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # 1. Hardware network modules for early boot networking
  boot.initrd.availableKernelModules = [ "r8169" "e1000e" "igb" "igc" ];
  boot.initrd.kernelModules = [ "r8169" "e1000e" "igb" "igc" ];

  # Make the initramfs SSH host key available during early boot so remote unlock can work.
  boot.initrd.systemd.enable = true;
  boot.initrd.systemd.network.enable = true;
  boot.initrd.systemd.network.networks."10-dhcp" = {
    matchConfig = {
      Name = "en*";
    };
    networkConfig = {
      DHCP = "yes";
      IPv6AcceptRA = "yes";
    };
  };
  boot.initrd.secrets = {
    "/etc/secrets/initrd_ssh_host_ed25519_key" = "/etc/secrets/initrd_ssh_host_ed25519_key";
  };

  # 2. Key-Based Boot Stage SSH
  boot.initrd.network = {
    enable = true;
    ssh = {
      enable = true;
      port = 422;
      
      # Paste your laptop's public key here to allow it to bypass passwords on boot
      authorizedKeys = [ 
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKxyMr1ZpmJoarQI2bIgsa75Ch2mLQh13LP1xzAgorcp" 
      ];

      # Points to the host key file we generated earlier
      hostKeys = [ "/etc/secrets/initrd_ssh_host_ed25519_key" ];
    };
  };

  # Force asking for password
  boot.initrd.systemd.users.root.shell = "/bin/systemd-tty-ask-password-agent";
}
