#!/bin/bash
killall -q polybar
while pgrep -u $UID -x polybar >/dev/nul; do sleep 1; done
polybar --reload main -c $XDG_CONFIG_HOME/polybar/config &
polybar --reload bottomleft -c $XDG_CONFIG_HOME/polybar/config &
polybar --reload memory -c $XDG_CONFIG_HOME/polybar/config &
#polybar --reload right -c $XDG_CONFIG_HOME/polybar/config &
echo "Polybar Launched"
