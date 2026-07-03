{ config, pkgs, ... }:

{
  # 1. Enable File Browser
  services.filebrowser = {
    enable = true;
    settings = {
      address = "127.0.0.1";
      port = 8081;
      # The directory you want to be able to browse via the web interface
      root = "/home/joe/Documents";
    };
  };

  # 2. Register to your automated dashboard matrix
  services.campgroundlabs.hub = [
    {
      name = "File Explorer";
      path = "files";
      port = 8081;
      emoji = "📂";
      description = "Web interface for managing server files.";
    }
  ];
}
