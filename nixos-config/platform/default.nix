# ~/src/nixos-config/modules/default.nix
{ config, pkgs, ... }:

{
  imports = [
    ./core-packages.nix
    ./nginx.nix
    ./power.nix
  ];
}
