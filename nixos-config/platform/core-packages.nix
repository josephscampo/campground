{ pkgs, ... }:

{
  programs.firefox.enable = true;

  environment.systemPackages = with pkgs; [
    git
    tmux
    vim
    htop
    openssl
  ];
  
  # Enable running unpatched dynamic binaries, needed for vscode integration
  programs.nix-ld.enable = true;

  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc
    zlib
    glib
    # Add any other libraries if complex language extensions throw errors later
  ];
}
