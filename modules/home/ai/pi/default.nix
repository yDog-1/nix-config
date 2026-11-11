{pkgs, ...}: {
  programs.pi-coding-agent = {
    enable = true;
    package = pkgs.llm-agents.pi;
  };
}
