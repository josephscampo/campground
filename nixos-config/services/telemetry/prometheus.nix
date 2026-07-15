{ config, pkgs, lib, ... }:

{
  # Prometheus Metrics Harvester
  services.prometheus = {
    enable = true;
    port = 9090;
    exporters.node = {
      enable = true;
      port = 9100;
    };
    scrapeConfigs = [{
      job_name = "yurt";
      static_configs = [{ targets = [ "127.0.0.1:9100" ]; }];
    }];
  };
}