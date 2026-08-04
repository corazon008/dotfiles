#!/bin/bash

while true; do
    ~/.config/eww/scripts/nextcloud_tasks.py\
    > ~/.cache/eww_tasks_todos.json

    ~/.config/eww/scripts/nextcloud_tasks.py --cours\
    > ~/.cache/eww_tasks_cours.json

    sleep 60
done
