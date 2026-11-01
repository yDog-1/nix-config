{pkgs, ...}: {
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  # Use the official preset bundled with the flake's pinned Starship version.
  # https://starship.rs/presets/catppuccin-powerline
  xdg.configFile."starship.toml".source = pkgs.runCommand "starship-catppuccin-powerline.toml" {} ''
    ${pkgs.starship}/bin/starship preset catppuccin-powerline --output "$out"
    substituteInPlace "$out" \
      --replace-fail '$os' "" \
      --replace-fail '$time\' "" \
      --replace-fail '[](fg:sapphire bg:lavender)' "" \
      --replace-fail '[ ](fg:lavender)' '[ ](fg:sapphire)' \
      --replace-fail '❯' '\$' \
      --replace-fail '❮' '\$'
  '';
}
