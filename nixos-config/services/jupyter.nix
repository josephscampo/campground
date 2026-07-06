{config, pkgs, ...}:

{
  services.jupyterhub = {
    enable = true;
    port = 4444;
    extraConfig = ''
        # c.Authenticator.allow_all = true
        c.Authenticator.admin_users = {"joe"}
    '';
  };
}