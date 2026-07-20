{
  pkgs,
  inputs,
  homeDirectory,
  ...
}: let
  vdeTmuxConfig = import ./vde/tmux {inherit pkgs;};
  opencodeConfig = import ./opencode {inherit pkgs inputs homeDirectory;};
in {
  "opencode/opencode.json".src = opencodeConfig;
  "opencode/tui.json".src = ./opencode/tui.json;
  "zeno/config.yml".src = ./zeno/config.yml;
  "sheldon/plugins.toml".src = ./sheldon/plugins.toml;
  "vde/tmux/config.yml".src = vdeTmuxConfig;
}
