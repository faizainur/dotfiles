#!/usr/bin/env bash
# Omarchy-style bluetooth popup: power, scan+refresh, PAIR/CONNECT/Disconnect (rofi + bluetoothctl)
rofi_cmd=(rofi -dmenu -p "Bluetooth" -i)

power=$(bluetoothctl show 2>/dev/null | grep -m1 'PowerState' | awk '{print $2}')

menu=(); actions=(); macs=()
add() { menu+=("$1"); actions+=("$2"); macs+=("$3"); }

if [[ $power == on ]]; then
    add "Power: on — turn off"              off      ""
    add "Scan + refresh device list (8s)"   scan     ""
else
    add "Power: off — turn on"              on       ""
fi
add "Open blueman (pairing dialogs/full manager)" blueman ""

paired=$(bluetoothctl devices Paired 2>/dev/null)

# paired devices: connect / disconnect
while read -r _ mac name; do
    [[ -n $mac ]] || continue
    conn=$(bluetoothctl info "$mac" 2>/dev/null | grep 'Connected' | awk '{print $2}')
    if [[ $conn == yes ]]; then
        add "disconnect : $name"  disconnect "$mac"
    else
        add "connect    : $name"  connect    "$mac"
    fi
done <<< "$paired"

# discovered but not paired: offer pairing
while read -r _ mac name; do
    [[ -n $mac ]] || continue
    grep -q "$mac" <<< "$paired" && continue
    [[ $name == "$mac" ]] && name="(unnamed device)"
    add "PAIR NEW   : $name"  pair "$mac"
done <<< "$(bluetoothctl devices 2>/dev/null)"

choice=$(printf '%s\n' "${menu[@]}" | "${rofi_cmd[@]}") || exit 0
idx=$(printf '%s\n' "${menu[@]}" | grep -nxF "$choice" | head -1 | cut -d: -f1)
[[ -n $idx ]] || exit 0
action=${actions[idx-1]}; mac=${macs[idx-1]}

case "$action" in
    off) bluetoothctl power off ;;
    on)  bluetoothctl power on ;;
    scan)
        dunstify -u low "Bluetooth" "Scanning 8 s…"
        bluetoothctl --timeout 8 scan on >/dev/null 2>&1
        exec "$0"   # reopen menu with the refreshed list
        ;;
    blueman) blueman-manager & ;;
    connect)
        dunstify -u low "Bluetooth" "Connecting…"
        bluetoothctl --timeout 10 connect "$mac" >/dev/null 2>&1 \
            && dunstify "Bluetooth" "Connected" \
            || dunstify -u critical "Bluetooth" "Connect failed — try blueman"
        ;;
    disconnect) bluetoothctl disconnect "$mac" >/dev/null 2>&1 ;;
    pair)
        dunstify -u low "Bluetooth" "Pairing… make sure the device is in pairing mode"
        out=$(bluetoothctl --timeout 30 pair "$mac" 2>&1)
        if grep -qi 'successful' <<< "$out"; then
            bluetoothctl --timeout 10 connect "$mac" >/dev/null 2>&1
            dunstify "Bluetooth" "Paired"
            exec "$0"
        else
            dunstify -u critical "Bluetooth" "Pairing failed (auth?) — opening blueman for the pairing dialog"
            blueman-manager &
        fi
        ;;
esac
