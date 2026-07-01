{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    git
    tmux
    vim
    htop
    openssl
  ];
}
