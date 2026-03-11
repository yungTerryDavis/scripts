#!/bin/bash

LOGS_PATH="/tmp/monitor-debug.log"
MAIN_EXT_MONITOR_MODEL="LEN P27q-10"
EXT_MONITOR="HDMI-A-1"
INT_MONITOR="eDP-1"

printf "\nMonitor event\n" >> $LOGS_PATH

# Look out for hyprland session

HYPR_PROCESSES=$(ps aux | grep Hyprland)

if [ "$(echo "$HYPR_PROCESSES" | wc -l)" -gt 1 ]; then
    echo "Ssn: Hypr session found" >> $LOGS_PATH
    HYPR_USER=$(echo "$HYPR_PROCESSES" | awk 'NR==1 {split($0, a); print a[1]}')
    echo "Ssn: User ${HYPR_USER}" >> $LOGS_PATH
    HYPR_SIG=$(systemctl --machine=${HYPR_USER}@.host --user show-environment | grep '^HYPRLAND_INSTANCE_SIGNATURE=' | cut -d= -f2)
    echo "Ssn: Hypr signature ${HYPR_SIG}" >> $LOGS_PATH
else
    echo "Ssn: No hypr session found" >> $LOGS_PATH
    exit 0
fi

# Recognize the monitor

MONINFO=$(cat /sys/class/drm/card1-HDMI-A-1/edid | edid-decode)

if echo "$MONINFO" | grep -q "$MAIN_EXT_MONITOR_MODEL"; then
    echo "Mon: Main ext monitor connected" >> $LOGS_PATH
    MONITOR_ACTION="disable"
elif [ "$(echo "$MONINFO" | wc -l)" -le 1 ]; then
    echo "Mon: Ext monitor disconnected" >> $LOGS_PATH
    MONITOR_ACTION="enable"
else
    echo "Mon: Unknown ext monitor connected" >> $LOGS_PATH
    exit 0
fi

# Action
# All actions under sudo and with sig

hyprctl_as_user() {
    sudo -u "$HYPR_USER" \
        XDG_RUNTIME_DIR="/run/user/$(id -u "$HYPR_USER")" \
        HYPRLAND_INSTANCE_SIGNATURE="$HYPR_SIG" \
        hyprctl "$@"
}

sleep 1
for ws in {1..10}; do
    hyprctl_as_user dispatch moveworkspacetomonitor $ws ${EXT_MONITOR} 2>/dev/null || true
done

printf "Act: hyprctl ${MONITOR_ACTION} laptop monitor response " >> $LOGS_PATH
hyprctl_as_user keyword monitor "${INT_MONITOR}, ${MONITOR_ACTION}" >> $LOGS_PATH
