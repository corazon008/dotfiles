-- Blender file explorer (fenêtre flottante "Blender File View")
hl.window_rule({
    name = "blender-file-view",
    match = {
        class = "blender",
        initial_title = "File Browser"
    },
    float = true,
    center = true,
    size = { "monitor_w * 0.5", "monitor_h * 0.5" }
})
