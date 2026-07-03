{ config, pkgs, lib, ... }:

{
  # 1. Prometheus Metrics Harvester
  services.prometheus = {
    enable = true;
    port = 9090;
    exporters.node = {
      enable = true;
      port = 9100;
    };
    scrapeConfigs = [{
      job_name = "campground-server";
      static_configs = [{ targets = [ "127.0.0.1:9100" ]; }];
    }];
  };

  # 2. Fully Provisioned Grafana Service
  services.grafana = {
    enable = true;

    settings = {
      server = {
        http_addr = "0.0.0.0";
        http_port = 3000;
        root_url = "https://campground.asuscomm.com/metrics";
        serve_from_sub_path = true;
      };
      
      # 1. ALLOW ANONYMOUS PASS-THROUGH (No Login Required)
      "auth.anonymous" = {
        enabled = true;
        org_name = "Main Org."; # Must match your default organization name
        org_role = "Viewer";    # Safe default: lets them see but not break dashboards
      };

      # 2. FORCE HOMEPAGE REDIRECT
      # Points directly to the UID of the automatically downloaded node-exporter dashboard
      dashboards = {
        default_home_dashboard_path = "/var/lib/grafana/dashboards/node-exporter.json";
      };
      
      # THE APPLIED FIX: Satisfies the module's strict assertion constraint directly
      security.secret_key = "SW2YcwTIb9zpOOhoPsMm";
    };

    provision = {
      enable = true;
      datasources.settings.datasources = [
        {
          name = "Prometheus";
          type = "prometheus";
          access = "proxy";
          url = "http://127.0.0.1:9090";
          isDefault = true;
        }
      ];
      dashboards.settings.providers = [
        {
          name = "Automated Dashboards";
          options.path = "/var/lib/grafana/dashboards";
          inputs = [
            {
              name = "DS_PROMETHEUS";
              type = "datasource";
              pluginId = "prometheus";
              value = "Prometheus";
            }
          ];
        }
      ];
    };
  };

  networking.firewall.allowedTCPPorts = [3000];


  # 3. Clean, raw download of the dashboard layout file
  systemd.services.grafana-import-dashboards = {
    description = "Pre-download community dashboard 1860 for Grafana";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    
    script = ''
      mkdir -p /var/lib/grafana/dashboards
      
      if [ ! -f /var/lib/grafana/dashboards/node-exporter.json ]; then
        ${pkgs.curl}/bin/curl -s https://grafana.com/api/dashboards/1860/revisions/37/download > /var/lib/grafana/dashboards/node-exporter.json
        chown -R grafana:grafana /var/lib/grafana/dashboards
      fi
    '';
    
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };

  # 4. Register to your automated dashboard matrix
  services.campground.hub = [
    {
      name = "Server Metrics";
      path = "metrics";
      port = 3000;
      emoji = "📊";
      description = "Production-grade performance analytics.";
      useNativeSubpath = true;
    }
  ];
}
