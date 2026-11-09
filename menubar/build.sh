#!/bin/zsh
# Build BluetoothBar.app into ~/Applications and (re)start it. setup.sh runs
# this; run it again after editing BluetoothBar.swift or Info.plist.
# Needs only Apple's Command Line Tools (swiftc), which Homebrew installs.
set -euo pipefail

src=${0:A:h}
app=$HOME/Applications/BluetoothBar.app

mkdir -p "$app/Contents/MacOS"
cp "$src/Info.plist" "$app/Contents/Info.plist"
swiftc -O -swift-version 5 -o "$app/Contents/MacOS/BluetoothBar" "$src/BluetoothBar.swift"
codesign --force --sign - "$app"           # local signature; no Apple account needed

pkill -x BluetoothBar 2>/dev/null || true
open "$app"
print "Built and started $app"
