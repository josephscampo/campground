{ config, pkgs, ... }:

{
  imports = [
    ./service-hub.nix
    # ./netdata.nix
    # ./filebrowser.nix
    ./audiobookshelf.nix
    ./grafana.nix
    #    ./vikunja.nix
    ./vpn.nix
    ./hooks.nix
  ];
}
