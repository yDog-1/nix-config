{
  pkgs,
  inputs,
  ...
}: {
  home.packages = [pkgs.ast-grep];

  programs.agent-skills = {
    enable = true;
    sources = {
      local.path = ./skills;
      ast-grep = {
        path = inputs.ast-grep-skill;
        subdir = "ast-grep/skills";
      };
    };

    skills.explicit = {
      comma = {
        from = "local";
        path = "comma";
      };
      worktrunk = {
        from = "local";
        path = "worktrunk";
      };
      ast-grep = {
        from = "ast-grep";
        path = "ast-grep";
        packages = [pkgs.ast-grep];
        rewriteCommands = false;
        transform = {
          original,
          dependencies,
        }: let
          patched =
            builtins.replaceStrings
            [
              ''rule: {pattern: 'console.log(\$ARG)'}''
              ''rule: {pattern: "console.log($ARG)"}''
            ]
            [
              ''{id: console-log, language: javascript, rule: {pattern: 'console.log(\$ARG)'}}''
              ''{id: console-log, language: javascript, rule: {pattern: "console.log($ARG)"}}''
            ]
            original;
        in ''
          ${patched}

          For AST inspection, use `ast-grep run --pattern '<code>' --lang <language> --debug-query=cst`.
          The `dump_syntax_tree` name in the rule reference is not a CLI command.

          ${dependencies}
        '';
      };
    };

    targets = {
      agents = {
        enable = true;
        dest = "$HOME/.agents/skills";
        structure = "symlink-tree";
      };
    };
  };
}
