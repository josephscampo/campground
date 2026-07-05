{ pkgs, ... }:

{
  programs.firefox.enable = true;

  environment.systemPackages = with pkgs; [
    git
    tmux
    vim
    htop
    openssl
    tcpdump
  ];
  
  # Enable running unpatched dynamic binaries, needed for vscode integration
  programs.nix-ld.enable = true;

  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc
    zlib
    glib
    # Add any other libraries if complex language extensions throw errors later
  ];

  virtualisation.podman = {
    enable = true;
    
    # Create a system-wide alias for 'docker' to 'podman' 
    # so standard docker commands still work if you type them out of habit
    dockerCompat = true;

    # Required for containers that need to bind to low/privileged ports (like 53 or 51820)
    defaultNetwork.settings.dns_enabled = true;
  };

}
