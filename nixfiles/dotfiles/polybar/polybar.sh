#!/usr/bin/env sh

# Terminate already running bar instances
killall -q .polybar-wrapped

# Wait until the processes have been shut down
while pgrep -x .polybar-wrapped >/dev/null; do sleep 1; done

# Launch polybar
polybar mainbar-i3 &
