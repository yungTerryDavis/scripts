#!/bin/bash

# Monitor script for hyprconfig exec-once (no hypr session part)

MAIN_EXT_MONITOR_MODEL="LEN P27q-10"
EXT_MONITOR="HDMI-A-1"
INT_MONITOR="eDP-1"

# Recognize the monitor

MONINFO=$(cat /sys/class/drm/card1-HDMI-A-1/edid | edid-decode)

if echo "$MONINFO" | grep -q "$MAIN_EXT_MONITOR_MODEL"; then
    MONITOR_ACTION="disable"
elif [ "$(echo "$MONINFO" | wc -l)" -le 1 ]; then
    MONITOR_ACTION="enable"
else
    exit 0
fi

# Action

for ws in {1..10}; do
    hyprctl dispatch moveworkspacetomonitor $ws ${EXT_MONITOR} 2>/dev/null || true
done

hyprctl keyword monitor "${INT_MONITOR}, ${MONITOR_ACTION}"
