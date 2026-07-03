{ config, pkgs, ... }: {

  # Completely disable system-wide sleep, suspend, and hibernation targets
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  # If you are using logind (default), prevent it from suspending the machine on idle
  services.logind.settings = {
    Login = {
      IdleAction="ignore";
      HandleLidSwitch="ignore";
    };
  };
}
