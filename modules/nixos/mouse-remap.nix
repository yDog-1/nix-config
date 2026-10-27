{pkgs, ...}: {
  hardware.uinput.enable = true;

  # The GUI starts its privileged input reader through pkexec.
  security.polkit.enablePkexecWrapper = true;

  services.input-remapper = {
    enable = true;
    enableUdevRules = true;
    package = pkgs.input-remapper.overrideAttrs (old: {
      # 2.2.1 uses the home path instead of the username in the GUI's FIFO paths.
      postPatch =
        (old.postPatch or "")
        + ''
          substituteInPlace inputremapper/gui/reader_service.py \
            --replace-fail 'f"/tmp/input-remapper-{UserUtils.home}/reader-results"' \
              'f"/tmp/input-remapper-{UserUtils.user}/reader-results"' \
            --replace-fail 'f"/tmp/input-remapper-{UserUtils.home}/reader-commands"' \
              'f"/tmp/input-remapper-{UserUtils.user}/reader-commands"'
        '';
    });
  };
}
