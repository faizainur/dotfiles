#!/usr/bin/env bash
# Polybar network status: wired icon / wifi icon + SSID / disconnected icon
if nmcli -t -f DEVICE connection show --active 2>/dev/null | grep -qx enp6s0; then
    echo "%{T3}%{T-}"
elif nmcli -t -f active,ssid dev wifi 2>/dev/null | grep -q '^yes:'; then
    ssid=$(nmcli -t -f active,ssid dev wifi | awk -F: '$1=="yes"{print $2; exit}')
    echo "%{T3}%{T-} $ssid"
else
    echo "%{T3}%{F#e60053}%{F-}%{T-}"
fi
