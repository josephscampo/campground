{ config, pkgs, ... }:

{
  # service setup
  services.audiobookshelf = {
    enable = true;
    port = 13378;
  };

}
