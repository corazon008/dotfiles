hl.bind("ALT + XF86AudioRaiseVolume", hl.dsp.exec_cmd("~/.config/hypr/scripts/brightness.sh 5"),
    { locked = true, repeating = true, description = "Increase brightness" })
hl.bind("ALT + XF86AudioLowerVolume", hl.dsp.exec_cmd("~/.config/hypr/scripts/brightness.sh -5"),
    { locked = true, repeating = true, description = "Decrease brightness" })
