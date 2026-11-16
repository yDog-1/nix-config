{pkgs, ...}: {
  users.users.ydog-1 = {
    isNormalUser = true;
    description = "yDog";
    extraGroups = ["networkmanager" "wheel" "lp" "scanner" "lpadmin" "dialout" "i2c"];
    shell = pkgs.zsh;
  };
}
