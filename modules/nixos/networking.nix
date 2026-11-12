{
  networking = {
    hostName = "nixos";
    networkmanager = {
      enable = true;
      connectionConfig."ethernet.wake-on-lan" = 64; # Magic Packet
    };
    firewall.interfaces.tailscale0.allowedTCPPorts = [3773];
  };

  services.tailscale = {
    enable = true;
    openFirewall = true;
  };
}
