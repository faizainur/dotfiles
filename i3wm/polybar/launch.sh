#!/usr/bin/env sh

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Single bar on the primary monitor (DP-2); secondary stays clean
MONITOR=DP-2 polybar --reload example & disown
