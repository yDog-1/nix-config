{
  pkgs,
  inputs,
  homeDirectory,
}:
inputs.mcp-servers-nix.lib.mkConfig pkgs {
  flavor = "opencode";
  fileName = "opencode.json";

  programs.tavily = {
    enable = true;
    passwordCommand.TAVILY_API_KEY = [
      "cat"
      "${homeDirectory}/.config/sops-nix/secrets/tavily_api_key"
    ];
  };

  settings = builtins.fromJSON (builtins.readFile ./opencode.json);
}
