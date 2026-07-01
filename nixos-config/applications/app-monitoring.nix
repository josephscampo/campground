# ~/src/nixos-config/modules/app-monitoring.nix
{ pkgs, ... }:

{
  # Turn on the built-in Glances system monitoring blueprint
  services.glances = {
    enable = true;
    openFirewall = true; # Automatically opens the default port (61208)
  };

  # Optional: Add extra command-line tools to make monitoring even better
  environment.systemPackages = with pkgs; [
    iotop       # Watch disk read/write speeds in real-time
    lm_sensors  # Check your Intel NUC's CPU temperatures
  ];
}
