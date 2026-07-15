# ~/src/nixos-config/modules/default.nix
{ config, pkgs, ... }:

{
  imports = [
    ./accounts.nix
    ./basic.nix
    ./core-packages.nix
    ./network.nix
    ./nginx.nix
    ./power.nix
  ];
}
