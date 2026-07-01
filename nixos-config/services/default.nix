{ config, pkgs, ... }:

{
  imports = [
    ./service-hub.nix
    ./netdata.nix
    ./filebrowser.nix
    ./audiobookshelf.nix
#    ./vikunja.nix
  ];
}
