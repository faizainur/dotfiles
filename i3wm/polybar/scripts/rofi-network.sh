#!/usr/bin/env bash
# Omarchy-style network popup: Wi-Fi picker + quick actions (rofi + nmcli)
rofi_cmd=(rofi -dmenu -p "Wi-Fi" -i)

build_menu() {
    wifi_hw=$(nmcli -t -f WIFI-HW radio | cut -d: -f1)
    wifi=$(nmcli -t -f WIFI radio | cut -d: -f1)
    echo "── toggle Wi-Fi radio [hw:$wifi_hw soft:$wifi] ──"
    echo "── rescan ──"
    echo "── advanced (nmtui) ──"
    nmcli -t -f SSID,SIGNAL,SECURITY dev wifi list 2>/dev/null \
        | awk -F: '{gsub(/^[ \t]+|[ \t]+$/,"",$1); if ($1!="") seen[$1]++; sig=$2; sec=$3; if (!( $1 in best ) || sig+0 > best[$1]+0) best[$1]=sig; if (!( $1 in secmap )) secmap[$1]=sec } END { for (s in best) printf "%s|%s|%s\n", s, best[s], secmap[s] }' \
        | sort -t'|' -k2 -rn | while IFS='|' read -r ssid sig sec; do
            active_tag=""
            nmcli -t -f active,ssid dev wifi 2>/dev/null | grep -qx "yes:${ssid}" && active_tag="✔ "
            if [[ $sec == "none" ]]; then lock="🔓"; else lock="🔒"; fi
            echo "${active_tag}${ssid} ${lock} (${sig}%)"
        done
}

choice=$(build_menu | "${rofi_cmd[@]}") || exit 0

case "$choice" in
    *"toggle Wi-Fi radio"*)
        nmcli radio wifi toggle
        exit 0 ;;
    *"rescan"*)
        nmcli dev wifi rescan 2>/dev/null; exit 0 ;;
    *"advanced (nmtui)"*)
        alacritty -e nmtui & exit 0 ;;
esac

# strip status decorations to recover the SSID
ssid=$(sed -e 's/^✔ //' -e 's/ 🔓.*//' -e 's/ 🔒.*//' <<< "$choice")

if grep -qx "yes:${ssid}" <<< "$(nmcli -t -f active,ssid dev wifi)"; then
    dunstify -u low "Already connected to ${ssid}"
    exit 0
fi

notify-send "Wi-Fi" "Connecting to ${ssid}…" 2>/dev/null
if nmcli device wifi connect "$ssid" 2>/dev/null; then
    dunstify -u normal "Wi-Fi" "Connected to ${ssid}"
else
    dunstify -u critical "Wi-Fi" "Needs a password/extra config — opening nmtui"
    alacritty -e nmtui &
fi
