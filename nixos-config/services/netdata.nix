{ config, pkgs, ... }:

{
  # 1. Enable the Netdata service
  services.netdata = {
    enable = true;
    # Force Netdata to listen only on localhost for security
    config = {
      web = {
        "bind to" = "127.0.0.1:19999";
      };
    };
  };

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
