{ ... }:

{
  imports = [
    ./vscode.nix
  ];

  home.username = "joe";
  home.homeDirectory = "/home/joe";
  home.stateVersion = "26.05";
}
