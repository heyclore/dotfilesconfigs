#!/bin/bash

DEVICE="amdgpu_bl1"

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <percent>"
    echo "Example: $0 20"
    exit 1
fi

PERCENT="${1%\%}"

if ! [[ "$PERCENT" =~ ^[0-9]+$ ]] || (( PERCENT < 0 || PERCENT > 100 )); then
    echo "Brightness must be a number between 0 and 100."
    exit 1
fi

MAX=$(<"/sys/class/backlight/$DEVICE/max_brightness")
VALUE=$(( MAX * PERCENT / 100 ))

echo "$VALUE" | sudo tee "/sys/class/backlight/$DEVICE/brightness" >/dev/null

echo "Brightness set to ${PERCENT}% (raw value: ${VALUE}/${MAX})"
