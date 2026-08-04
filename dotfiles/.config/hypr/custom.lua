hl.on("hyprland.start", function()
    -- Start widget update_tasks
    hl.exec_cmd("~/.config/eww/scripts/update_tasks.sh")

    -- Start eww widgets
    hl.exec_cmd("eww open todo-tasks")
    hl.exec_cmd("eww open todo-cours")
end)
