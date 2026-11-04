# hypr.dots Waybar

Source: [notdanna/hypr.dots](https://github.com/notdanna/hypr.dots), pinned at
`111a2840ea3caeb1bd1b3a850b4bf8253af0f738` by the `hypr-dots` flake input.

The horizontal `dots/waybar/purple` layout, CSS and committed Matugen palette
are imported directly. `configure.py` applies our overrides at build time.
Wallpaper changes do not regenerate the palette.

## Layout and interaction

- Both bars are top-anchored: `DP-3` uses the primary layout (500px side margins,
  2px top margin), `HDMI-A-1` the secondary layout (270px sides, 4px top).
- The left label always shows the shortened active-window title (upstream rewrite
  rules, at most 35 characters), with a Nix logo only when no window is active.
  Untitled windows use their application class. The label refreshes every second
  and has no click-to-toggle alternative format.
- Browser media uses MPRIS, updated every two seconds. Firefox, Zen, Chromium,
  Chrome, Brave, LibreWolf, Floorp, Vivaldi, Opera and Edge names are recognized.
  Only media exposed by the browser can be displayed. Playing media takes
  precedence over paused media; equal-priority players retain the current choice.
  Alongside the title, separate `` / `` (or `` while playing) / `` buttons
  send previous / play-pause / next on left click to the exact displayed player.
  All three buttons hide when there is no browser media. The title also retains
  its left / middle / right click shortcuts. If the player exits, clicks do not
  control another player.
- The update counter and its script are removed.
- Audio: left click opens an output-device chooser below the bar on the pointer's
  monitor; right click toggles mute; middle click opens Pavucontrol; scrolling
  adjusts volume by 5%. Choosing a device changes the default sink and moves
  existing playback streams. Canceling the chooser makes no changes.
- SwayNC is notification-only: title/clear-all, DND and notification history.
  Its palette matches Waybar. Clicking the notification icon opens the panel
  below/right of the click, on that icon's monitor. The outer panel width includes
  its padding/border; placement respects monitor scaling/rotation and clamps at
  screen edges. The helper changes only the in-memory right margin over D-Bus
  (`write_to_file=false`), then selects the output before opening. Clicking again
  closes it. Layer-shell excludes the bar's reserved zone; an 8px gap is added.
  Toast notifications retain their separate top offset. Media and volume controls
  are not included in SwayNC.
- SwayNC transitions, Waybar drawers, and Hyprland layer/popup animations use
  300ms. The compositor settings target only `layers`, `fadeLayers`, `fadePopups`;
  ordinary window/workspace animations and notification dismissal timeouts are
  unchanged. `transition-time` in SwayNC alone does not control panel opening.
- Drawers expand horizontally within the bar. Calendar tooltips, tray menus and
  the Rofi network/device menus appear below it.

## Host compatibility

- The original network Python script and Rofi theme are used with their missing
  font/palette imports supplied. Password entry is obscured.
- Recording uses `wf-recorder` with audio, `slurp` for region selection, and
  software H.264 for NVIDIA compatibility. Full-screen recording targets the
  clicked monitor. Files go to `$XDG_VIDEOS_DIR/record`. A user systemd service
  enforces a single recording and stops it with SIGINT.
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
