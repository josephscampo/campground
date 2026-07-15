{ config, pkgs, lib, ... }:

{
    # InfluxDB Time-Series Database
    services.influxdb2 = {
      enable = true;
    };
}