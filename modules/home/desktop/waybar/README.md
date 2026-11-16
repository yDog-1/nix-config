# hypr.dots Waybar

Source: [notdanna/hypr.dots](https://github.com/notdanna/hypr.dots), pinned at
`111a2840ea3caeb1bd1b3a850b4bf8253af0f738` by the `hypr-dots` flake input.

The horizontal `dots/waybar/purple` layout, CSS and committed Matugen palette
are imported directly. `configure.py` applies our overrides at build time.
Wallpaper changes do not regenerate the palette.

## Layout and interaction

- Both bars are top-anchored: `DP-3` uses the primary layout (500px side margins,
  2px top margin), `HDMI-A-1` the secondary layout (270px sides, 4px top).
- The left side displays the Nix logo and workspaces, without the active-window title.
- The media player, recording controls and network module are not displayed.
  The clock is centered; the weather appears immediately to its right. Weather
  tooltips use Japanese, with local translations for untranslated conditions.
- CPU, memory and root disk usage appear next to the workspaces. Their tooltips
  show CPU and GPU usage, RAM and VRAM usage, and real filesystem usage by mount
  point. GPU readings use the host NVIDIA driver’s `nvidia-smi`.
- The input-method indicator uses a compact source label like GNOME Shell.
  For SKK, it shows the character mode from the fcitx status menu.
- The tray is hidden in a hover drawer. Moving the pointer over its button
  reveals the icons; moving away closes it. Module backgrounds are transparent.
- The update counter and its script are removed.
- Audio: left click opens an output-device chooser below the bar on the pointer's
  monitor; right click toggles mute; middle click opens Pavucontrol; scrolling
  adjusts volume by 5%. The adjacent microphone control uses the same actions
  for input devices and recording streams. Choosing a device changes the default
  and moves existing streams. A single click selects a device. Escape closes the
  chooser without changes; clicking outside does not reliably close it on Wayland.
- SwayNC provides display brightness sliders, an MPRIS player, buttons for idle
  inhibition and region screenshots, per-application notification rules, and
  notifications with clear-all and DND controls. Its palette matches Waybar.
  Clicking the notification icon opens the panel
  below/right of the click, on that icon's monitor. The outer panel width includes
  its padding/border; placement respects monitor scaling/rotation and clamps at
  screen edges. The helper changes only the in-memory right margin over D-Bus
  (`write_to_file=false`), then selects the output before opening. Clicking again
  closes it. Layer-shell excludes the bar's reserved zone; an 8px gap is added.
  Toast notifications retain their separate top offset. Volume controls remain
  in Waybar. The App rules button closes the panel and opens Rofi with the
  applications that have sent notifications; choosing one cycles it through
  On, Silent, and Off. Rules live in `$XDG_STATE_HOME/swaync/rules.json` and are
  merged into the config the daemon was started with. SwayNC never watches the
  config file, so the helper reloads it with `swaync-client --reload-config`.
- The Waybar tray drawer opens and closes over 200ms. SwayNC transitions
  and Hyprland layer and popup animations are disabled. Ordinary window and
  workspace animations and notification dismissal timeouts are unchanged.
- Calendar tooltips, tray menus and the Rofi audio-device menu appear below the bar.

## Host compatibility

- The upstream undefined CSS `main-color` uses its `primary` accent. The misspelled
  `passtrough` property is omitted. Notification JSON uses `{text}` for Waybar 0.15.
- Battery and power-profile modules remain hardware/service dependent; they do
  not supply fabricated readings on this desktop.

Run helper regression tests with:

```sh
PYTHONDONTWRITEBYTECODE=1 python -m unittest discover -s modules/home/desktop/waybar -p 'test_*.py'
```

Set `WAYBAR_CONFIG` and `SWAYNC_CONFIG` to the built JSON files to include the
generated-configuration regression tests (otherwise these three tests skip).
