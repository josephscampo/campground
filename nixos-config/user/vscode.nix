{ pkgs, ... }:

{
  programs.vscode = {
    enable = true;
    profiles.default.extensions = with pkgs.vscode-extensions; [
      ms-vscode-remote.remote-ssh
    ];
    profiles.default.userSettings = {
      "remote.SSH.useLocalServer" = true;
      "editor.fontSize" = 14;
    };
  };
}
