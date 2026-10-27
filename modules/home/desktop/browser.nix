{
  inputs,
  pkgs,
  ...
}: {
  home.packages = [
    pkgs.vivaldi
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.beta
  ];

  programs.firefox = {
    enable = true;
    configPath = ".mozilla/firefox";
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "zen-beta.desktop";
      "application/xhtml+xml" = "zen-beta.desktop";
      "x-scheme-handler/http" = "zen-beta.desktop";
      "x-scheme-handler/https" = "zen-beta.desktop";
      "x-scheme-handler/about" = "zen-beta.desktop";
      "x-scheme-handler/unknown" = "zen-beta.desktop";
    };
  };
}
