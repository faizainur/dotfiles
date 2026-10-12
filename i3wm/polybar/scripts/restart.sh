#!/usr/bin/env bash
# Cleanly restart polybar (safe to call from i3 or terminal)
killall -q polybar
while pgrep -u "$UID" -x polybar >/dev/null; do sleep 0.5; done
setsid sh -c 'MONITOR=DP-2 exec polybar --reload example' >/dev/null 2>&1 &
