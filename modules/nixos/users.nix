{pkgs, ...}: {
  users.users.ydog-1 = {
    isNormalUser = true;
    description = "yDog";
    extraGroups = ["networkmanager" "wheel" "lp" "scanner" "lpadmin" "dialout"];
    shell = pkgs.zsh;
  };
}
