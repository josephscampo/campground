{ config, pkgs, ... }:

{
  imports = [
    ./influx.nix
    ./speed-test.nix
    ./grafana.nix
    ./prometheus.nix
  ];
}
