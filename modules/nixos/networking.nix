{
  networking.hostName = "nixos";
  networking.networkmanager = {
    enable = true;
    connectionConfig."ethernet.wake-on-lan" = 64; # Magic Packet
  };

  services.tailscale = {
    enable = true;
    openFirewall = true;
  };
}
