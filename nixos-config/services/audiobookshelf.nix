{ config, pkgs, ... }:

{
  # service setup
  services.audiobookshelf = {
    enable = true;
    port = 13378;
  };

  # Register to your automated dashboard matrix
  services.campground.hub = [
    {
      name = "Audiobooks";
      path = "audiobooks";
      port = 13378;
      emoji = "🎧";
      description = "Stream audiobooks and personal podcasts.";
      useNativeSubpath = true;
      nativeSubpathStyle = "strip";
    }
  ];
}
