#!/bin/bash

while true; do
    ~/.config/eww/scripts/nextcloud_tasks.py \
    > ~/.cache/eww_tasks.json

    sleep 60
done
