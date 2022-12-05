#!/usr/bin/env bash

# see man zscroll for documentation of the following parameters
zscroll -l 60 \
        --delay 0.1 \
        --scrollpadding "  " \
        "`dirname $0`/get_spotify_status.sh" &
wait
