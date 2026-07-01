{ config, pkgs, lib, ... }:

{
  # Dynamically appends this package to the global list, preventing conflicts
  nixpkgs.config.permittedInsecurePackages = lib.mkAfter [
    "pnpm-10.29.2"
  ];
  
  # 1. Enable Vikunja (handles both frontend and backend automatically)
  services.vikunja = {
    enable = true; 

    # MANDATORY options required by the NixOS module schema
    frontendScheme = "https";
    frontendHostname = "campground.asuscomm.com";
    port = 3456;

    settings = {
      service = {
        # Bind the unified application server to localhost
        interface = "127.0.0.1:3456";
      };
    };
  };

  # 2. Register to your automated dashboard matrix
  services.campground.hub = [
    {
      name = "Tasks & Projects";
      path = "tasks";
      port = 3456;
      emoji = "✅";
      description = "Kanban boards, lists, and project tracking.";
    }
  ];
}
