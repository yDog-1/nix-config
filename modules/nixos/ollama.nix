{pkgs, ...}: {
  services.ollama = {
    enable = true;
    # Vulkan supports this host's Pascal GPU without a legacy CUDA toolchain.
    package = pkgs.ollama-vulkan;
    host = "127.0.0.1";
    openFirewall = false;
  };
}
