#!/usr/bin/env bash

delta="$1"

if [ -z "$delta" ]; then
    echo "Usage: $0 <variation>"
    echo "Exemple: $0 -5"
    exit 1
fi

for d in 1 2; do
    current=$(ddcutil --display "$d" getvcp 10 | grep -oP 'current value =\s*\K\d+')

    new=$((current + delta))

    [ "$new" -gt 100 ] && new=100
    [ "$new" -lt 0 ] && new=0

    ddcutil --display "$d" setvcp 10 "$new"
done
