#!/bin/sh
zip --recurse-paths \
    -X \
    LoveTest.love . \
    --include '*.lua' \
    --include '*.png' \
    --include '*.ogg'
