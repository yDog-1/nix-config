{pkgs, ...}: {
  users.users.ydog-1 = {
    isNormalUser = true;
    description = "yDog";
    extraGroups = ["networkmanager" "wheel"];
    packages = with pkgs; [
      vivaldi
    ];
    shell = pkgs.zsh;
  };
}
