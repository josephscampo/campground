{ config, pkgs, ... }:

{
  # 1. Enable Audiobookshelf
  services.audiobookshelf = {
    enable = true;
    host = "127.0.0.1";
    port = 8082;
  };

  # 2. Register to your automated dashboard matrix
  services.campground.hub = [
    {
      name = "Audiobooks";
      path = "audiobooks";
      port = 8082;
      emoji = "🎧";
      description = "Stream audiobooks and personal podcasts.";
      useNativeSubpath = true;
    }
  ];
}
