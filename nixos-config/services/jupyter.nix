{config, pkgs, ...}:

{
  services.jupyterhub = {
    enable = true;
    port = 4444;
  };
}