{ pkgs, ... }:

{
  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      ms-vscode-remote.remote-ssh
    ];
    userSettings = {
      "remote.SSH.useLocalServer" = true;
      "editor.fontSize" = 14;
    };
  };
}
