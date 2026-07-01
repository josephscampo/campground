{ config, pkgs, ... }:

{
  # 1. Enable the Netdata service
  services.netdata = {
    enable = true;
    # Force Netdata to listen only on localhost for security
    config = {
      global = {
        "memory mode" = "ram";
        "debug log" = "none";
        "access log" = "none";
        "error log" = "syslog";
      };
    };
  };

  nixpkgs.config.allowUnfree = true;
  services.netdata.package = pkgs.netdata.override {
    withCloudUi = true;
  };
  networking.firewall.allowedTCPPorts = [19999];
  
  # 2. Register to your automated dashboard matrix
  services.campground.hub = [
    {
      name = "Server Metrics";
      path = "metrics";
      port = 19999;
      emoji = "📊";
      description = "Real-time visual performance charts.";
    }
  ];
}
