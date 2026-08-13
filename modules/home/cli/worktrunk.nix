{
  lib,
  pkgs,
  ...
}: {
  home.packages = [pkgs.worktrunk];

  xdg.configFile."worktrunk/config.toml".text = ''
    [commit.generation]
    command = "worktrunk-commit-message"
    template-append = """
    - Use a concise Conventional Commit subject matching recent repository history.
    - Describe the behavioral change, never merely the changed file names.
    - Add a body only when it provides material context.
    """
  '';

  # Must run after compinit so the dynamic wt completion can register itself.
  programs.zsh.initContent = lib.mkOrder 1500 ''
    eval "$(${pkgs.worktrunk}/bin/wt config shell init zsh)"
  '';
}
