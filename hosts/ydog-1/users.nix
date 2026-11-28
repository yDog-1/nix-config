{pkgs, ...}: {
  users.users.ydog-1 = {
    isNormalUser = true;
    uid = 1001;
    description = "yDog";
    extraGroups = ["networkmanager" "wheel" "lp" "scanner" "lpadmin" "dialout" "i2c"];
    shell = pkgs.zsh;
  };
}
