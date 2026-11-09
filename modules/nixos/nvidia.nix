{config, ...}: {
  hardware.graphics.enable = true;
  services.xserver.videoDrivers = ["nvidia"];

  # Test NVIDIA's workaround for a black screen after resume.
  # https://forums.developer.nvidia.com/t/black-screen-with-cursor-after-sleep/319473/5
  boot.extraModprobeConfig = ''
    options nvidia_modeset vblank_sem_control=0
  '';

  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
    powerManagement.enable = true;
  };
}
