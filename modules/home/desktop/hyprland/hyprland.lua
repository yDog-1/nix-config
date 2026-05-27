local browser = "vivaldi --ozone-platform=wayland"
local monitors = {
  primary = {
    mode = "2560x1440@144.0",
    output = "DP-3",
    position = "0x0",
    scale = 1.0
  },
  secondary = {
    mode = "1920x1080@75.0",
    output = "HDMI-A-1",
    position = "2560x360",
    scale = 1.0
  }
}
local mod = "SUPER"
local terminal = "wezterm"

-- settings.bind
hl.bind((mod .. " + T"), (hl.dsp.exec_cmd(terminal)))
hl.bind((mod .. " + B"), (hl.dsp.exec_cmd(browser)))
-- to enable IME, only able to launch via `-x11` option
hl.bind((mod .. " + Space"), (hl.dsp.exec_cmd("rofi -x11 -show drun")))
hl.bind((mod .. " + E"), (hl.dsp.exec_cmd("nemo")))
hl.bind((mod .. " + Q"), (hl.dsp.window.close()))
hl.bind((mod .. " + SHIFT + M"), (hl.dsp.exit()))
hl.bind((mod .. " + G"), (hl.dsp.window.float({ action = "toggle" })))
hl.bind((mod .. " + I"), (hl.dsp.exec_cmd("vim-anywhere-wayland")))
hl.bind((mod .. " + F"), (hl.dsp.window.fullscreen()))
hl.bind((mod .. " + N"), (hl.dsp.exec_cmd("night-mode-toggle")))
hl.bind((mod .. " + left"), (hl.dsp.focus({ direction = "left" })))
hl.bind((mod .. " + right"), (hl.dsp.focus({ direction = "right" })))
hl.bind((mod .. " + up"), (hl.dsp.focus({ direction = "up" })))
hl.bind((mod .. " + down"), (hl.dsp.focus({ direction = "down" })))
hl.bind((mod .. " + H"), (hl.dsp.focus({ direction = "left" })))
hl.bind((mod .. " + L"), (hl.dsp.focus({ direction = "right" })))
hl.bind((mod .. " + K"), (hl.dsp.focus({ direction = "up" })))
hl.bind((mod .. " + J"), (hl.dsp.focus({ direction = "down" })))
hl.bind((mod .. " + SHIFT + left"), (hl.dsp.window.move({ direction = "left" })))
hl.bind((mod .. " + SHIFT + right"), (hl.dsp.window.move({ direction = "right" })))
hl.bind((mod .. " + SHIFT + up"), (hl.dsp.window.move({ direction = "up" })))
hl.bind((mod .. " + SHIFT + down"), (hl.dsp.window.move({ direction = "down" })))
hl.bind((mod .. " + SHIFT + H"), (hl.dsp.window.move({ direction = "left" })))
hl.bind((mod .. " + SHIFT + L"), (hl.dsp.window.move({ direction = "right" })))
hl.bind((mod .. " + SHIFT + K"), (hl.dsp.window.move({ direction = "up" })))
hl.bind((mod .. " + SHIFT + J"), (hl.dsp.window.move({ direction = "down" })))
hl.bind((mod .. " + CTRL + H"), (hl.dsp.focus({ workspace = "-1" })))
hl.bind((mod .. " + CTRL + L"), (hl.dsp.focus({ workspace = "+1" })))
hl.bind("Print", (hl.dsp.exec_cmd("hyprshot -m window -o ~/Pictures/Screenshots")))
hl.bind((mod .. " + mouse:272"), (hl.dsp.window.drag()), {
  ["mouse"] = true
})
hl.bind((mod .. " + mouse:273"), (hl.dsp.window.resize()), {
  ["mouse"] = true
})
hl.bind((mod .. " + 1"), (hl.dsp.focus({ workspace = 1 })))
hl.bind((mod .. " + SHIFT + 1"), (hl.dsp.window.move({ workspace = 1 })))
hl.bind((mod .. " + 2"), (hl.dsp.focus({ workspace = 2 })))
hl.bind((mod .. " + SHIFT + 2"), (hl.dsp.window.move({ workspace = 2 })))
hl.bind((mod .. " + 3"), (hl.dsp.focus({ workspace = 3 })))
hl.bind((mod .. " + SHIFT + 3"), (hl.dsp.window.move({ workspace = 3 })))
hl.bind((mod .. " + 4"), (hl.dsp.focus({ workspace = 4 })))
hl.bind((mod .. " + SHIFT + 4"), (hl.dsp.window.move({ workspace = 4 })))
hl.bind((mod .. " + 5"), (hl.dsp.focus({ workspace = 5 })))
hl.bind((mod .. " + SHIFT + 5"), (hl.dsp.window.move({ workspace = 5 })))
hl.bind((mod .. " + 6"), (hl.dsp.focus({ workspace = 6 })))
hl.bind((mod .. " + SHIFT + 6"), (hl.dsp.window.move({ workspace = 6 })))
hl.bind((mod .. " + 7"), (hl.dsp.focus({ workspace = 7 })))
hl.bind((mod .. " + SHIFT + 7"), (hl.dsp.window.move({ workspace = 7 })))
hl.bind((mod .. " + 8"), (hl.dsp.focus({ workspace = 8 })))
hl.bind((mod .. " + SHIFT + 8"), (hl.dsp.window.move({ workspace = 8 })))
hl.bind((mod .. " + 9"), (hl.dsp.focus({ workspace = 9 })))
hl.bind((mod .. " + SHIFT + 9"), (hl.dsp.window.move({ workspace = 9 })))
hl.bind((mod .. " + 0"), (hl.dsp.focus({ workspace = 10 })))
hl.bind((mod .. " + SHIFT + 0"), (hl.dsp.window.move({ workspace = 10 })))

-- settings.config
hl.config({
  ["animations"] = {
    ["enabled"] = true
  },
  ["cursor"] = {
    ["default_monitor"] = monitors.primary.output
  },
  ["decoration"] = {
    ["blur"] = {
      ["enabled"] = true,
      ["passes"] = 2,
      ["size"] = 4
    },
    ["rounding"] = 6
  },
  ["general"] = {
    ["border_size"] = 2,
    ["gaps_in"] = 4,
    ["gaps_out"] = 8,
    ["layout"] = "dwindle"
  },
  ["input"] = {
    ["accel_profile"] = "flat",
    ["follow_mouse"] = 1,
    ["kb_layout"] = "jp",
    ["touchpad"] = {
      ["natural_scroll"] = true
    }
  },
  ["misc"] = {
    ["disable_hyprland_logo"] = true,
    ["disable_splash_rendering"] = true,
    ["force_default_wallpaper"] = 0
  }
})

-- settings.device
hl.device({
  ["accel_profile"] = "adaptive",
  ["name"] = "getech-huge-trackball-1"
})
hl.device({
  ["name"] = "logitech-g603-1",
  ["sensitivity"] = 0.4
})

-- settings.env
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("GBM_BACKEND", "nvidia-drm")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")

-- settings.monitor
hl.monitor(monitors.primary)
hl.monitor(monitors.secondary)

-- settings.workspace_rule
hl.workspace_rule({
  ["default"] = true,
  ["monitor"] = monitors.primary.output,
  ["workspace"] = "1"
})
hl.workspace_rule({
  ["monitor"] = monitors.primary.output,
  ["workspace"] = "2"
})
hl.workspace_rule({
  ["monitor"] = monitors.primary.output,
  ["workspace"] = "3"
})
hl.workspace_rule({
  ["monitor"] = monitors.primary.output,
  ["workspace"] = "4"
})
hl.workspace_rule({
  ["monitor"] = monitors.primary.output,
  ["workspace"] = "5"
})
hl.workspace_rule({
  ["default"] = true,
  ["monitor"] = monitors.secondary.output,
  ["workspace"] = "6"
})
hl.workspace_rule({
  ["monitor"] = monitors.secondary.output,
  ["workspace"] = "7"
})
hl.workspace_rule({
  ["monitor"] = monitors.secondary.output,
  ["workspace"] = "8"
})
hl.workspace_rule({
  ["monitor"] = monitors.secondary.output,
  ["workspace"] = "9"
})
hl.workspace_rule({
  ["monitor"] = monitors.secondary.output,
  ["workspace"] = "10"
})

-- extraConfig
hl.on("hyprland.start", function()
  -- Make Xwayland games see the DP monitor as the primary display.
  hl.exec_cmd("xrandr --output " .. monitors.primary.output .. " --primary")
  hl.exec_cmd("ironbar")
  hl.exec_cmd("polkit-gnome-authentication-agent-1")
  hl.exec_cmd("pypr")
  hl.exec_cmd("waypaper --random")
  hl.exec_cmd("while true; do sleep 600; waypaper --random; done")
  hl.exec_cmd("fcitx5-remote -r")
  hl.exec_cmd("fcitx5 -d --replace")
end)
