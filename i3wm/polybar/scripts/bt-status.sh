#!/usr/bin/env bash
# Polybar bluetooth status: on (+connected count) / off
state=$(bluetoothctl show 2>/dev/null | grep -m1 'PowerState' | awk '{print $2}')
if [[ $state != on ]]; then
    echo "%{T3}%{F#e60053}%{F-}%{T-}"
    exit 0
fi
connected=0
while read -r _ mac _; do
    [[ -n $mac ]] || continue
    if bluetoothctl info "$mac" 2>/dev/null | grep -q '^.*Connected:.*yes'; then
        connected=$((connected+1))
    fi
done < <(bluetoothctl list >/dev/null 2>&1; bluetoothctl devices 2>/dev/null)
if (( connected > 0 )); then
    echo "%{T3}%{T-} $connected"
else
    echo "%{T3}%{T-}"
fi
