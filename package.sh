#!/bin/sh
zip --recurse-paths \
    -X \
    LittleTanks.love . \
    --include '*.lua' \
    --include '*.png' \
    --include '*.ogg'
