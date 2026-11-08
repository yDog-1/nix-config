{
  programs.zsh = {
    # Link system completion files, but let Home Manager initialize compinit once.
    enableCompletion = true;
    enableGlobalCompInit = false;
  };
}
