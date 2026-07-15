{ config, pkgs, lib, ... }:

{
  environment.systemPackages = [ pkgs.speedtest-cli ];
  
}
