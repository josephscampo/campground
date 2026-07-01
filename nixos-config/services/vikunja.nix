{ config, pkgs, ... }:

{
  # 1. Enable Vikunja (handles both frontend and backend automatically)
  services.vikunja = {
    enable = true;
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
