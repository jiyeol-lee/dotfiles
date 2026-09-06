#!/usr/bin/env bash

FILE=~/.config/plasma-org.kde.plasma.desktop-appletsrc
SRC=plasma-org.kde.plasma.desktop-appletsrc

# find digital clock config unique number
GRP=$(grep -B5 '^plugin=org.kde.plasma.digitalclock$' "$FILE" | grep '^\[Containments' | tail -1)
C=$(echo "$GRP" | sed -E 's/.*\[Containments\]\[([0-9]+).*/\1/')
A=$(echo "$GRP" | sed -E 's/.*\[Applets\]\[([0-9]+).*/\1/')
# echo "digitalclock C=$C A=$A"

# [Configuration][Appearance]
kwriteconfig6 --file "$SRC" \
  --group Containments --group "$C" --group Applets --group "$A" \
  --group Configuration --group Appearance \
  --key autoFontAndSize "false"
kwriteconfig6 --file "$SRC" \
  --group Containments --group "$C" --group Applets --group "$A" \
  --group Configuration --group Appearance \
  --key showDate "false"
kwriteconfig6 --file "$SRC" \
  --group Containments --group "$C" --group Applets --group "$A" \
  --group Configuration --group Appearance \
  --key fontSize "6"
kwriteconfig6 --file "$SRC" \
  --group Containments --group "$C" --group Applets --group "$A" \
  --group Configuration --group Appearance \
  --key enabledCalendarPlugins "pimevents,holidaysevents"

# [Shortcuts]
kwriteconfig6 --file "$SRC" \
  --group Containments --group "$C" --group Applets --group "$A" \
  --group Shortcuts --key global "Meta+O"
