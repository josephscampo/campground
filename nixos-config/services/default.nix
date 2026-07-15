{ config, pkgs, ... }:

{
  imports = [
    ./service-hub.nix
    # ./netdata.nix
    # ./filebrowser.nix
    ./audiobookshelf.nix
    ./telemetry
    ./vpn.nix
    ./hooks.nix
    ./jupyter.nix
  ];
}
