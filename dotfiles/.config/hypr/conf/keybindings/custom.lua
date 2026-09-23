hl.bind("ALT + XF86AudioRaiseVolume", hl.dsp.exec_cmd("~/.config/hypr/scripts/brightness.sh set-percentage 5"),
    { locked = true, repeating = true, description = "Increase brightness" })
hl.bind("ALT + XF86AudioLowerVolume", hl.dsp.exec_cmd("~/.config/hypr/scripts/brightness.sh set-percentage -5"),
    { locked = true, repeating = true, description = "Decrease brightness" })

hl.bind("SUPER + ALT + D", hl.dsp.exec_cmd("/usr/lib/hyprwhspr/config/hyprland/hyprwhspr-tray.sh record"),
    { description = "Speech-to-text" })
