# hypr.dots Waybar reproduction

Source: [notdanna/hypr.dots](https://github.com/notdanna/hypr.dots), pinned at
`111a2840ea3caeb1bd1b3a850b4bf8253af0f738` by the `hypr-dots` flake input.

The horizontal `dots/waybar/purple` configuration, every module/group definition,
the CSS, and the checked-in Matugen palette are consumed directly from upstream.
This preserves its square outer border, 13px JetBrains Mono font, colored rounded
modules, numbered workspaces, drawer directions/timings, calendar, media controls,
weather, tray, notifications, recording controls, and audio/network controls.
Upstream's commented-out modules remain disabled. The palette is the committed
snapshot; changing the desktop wallpaper does not regenerate it.

## Host adaptations

- Primary layout: `DP-3`, 500px horizontal margins. Secondary layout: `HDMI-A-1`,
  270px horizontal margins. These map upstream's external/laptop roles to this
  machine, rather than relying on the upstream monitor names.
- Both bars use `position: top` and `layer: top`. The original bottom margins are
  mirrored to the top (2px / 4px). GTK tooltips and tray menus open below the top
  bar. SwayNC is top-anchored below the bar; the upstream network Rofi theme is
  already northeast-anchored with a positive 54px vertical offset.
- The misspelled `passtrough` property is omitted. Interactive modules retain
  normal input handling. The undefined CSS `main-color` uses upstream's `primary`.
- Executables use Nix store paths. The missing `changevolume` command is replaced
  with `pactl`; left click mutes, middle click opens Pavucontrol, scrolling changes
  volume by 5%, exactly as in the source module.
- The notification format uses `{text}` instead of anonymous `{}` for current
  Waybar compatibility, without changing the displayed text/icon order.
- The network popup uses the original Python script and Rofi theme, with its
  missing font/palette imports supplied. Password input is obscured.
- Arch's Pacman/AUR update counter is replaced with a **Nix flake input** update
  counter. It checks direct, unpinned GitHub inputs every 12 hours without updating
  the lock file. The tooltip identifies this unit and reports offline/rate-limit
  failures instead of treating them as zero updates.
- Recording keeps full-screen / region / stop actions, saves under
  `$XDG_VIDEOS_DIR/record`, and uses the clicked monitor for full-screen recording.
  Software H.264 replaces AMD VAAPI for this NVIDIA host. A user systemd unit
  provides single-instance recording and a clean SIGINT stop.
- Battery and power-profile modules remain as upstream; their visibility depends
  on actual hardware and the presence of the power-profiles service. No fake
  battery or power-profile readings are supplied on this desktop.

`configure.py` parses JSONC at build time and applies only the above overrides.
It does not duplicate the upstream layout in a second hand-maintained config.
