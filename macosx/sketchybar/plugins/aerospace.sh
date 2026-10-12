#!/usr/bin/env bash

# make sure it's executable with:
# chmod +x ~/.config/sketchybar/plugins/aerospace.sh

if [ "$1" = "$FOCUSED_WORKSPACE" ]; then
    sketchybar \
	    --animate circ 40 \
	    --set $NAME \
	    background.color=0x44ffffff
else
    #sketchybar --set $NAME background.drawing=off
    sketchybar \
	    --animate circ 40 \
	    --set $NAME \
	    background.color=0x00ffffff
fi
