#!/usr/bin/env bash

# set display scale to 1.5
# you can check with `kscreen-doctor -o`
# `eDP-1` is the default display
kscreen-doctor output.eDP-1.scale.1.5

# set organizer view
kwriteconfig6 --file korganizerrc --group "Agenda View" --key "Hour Size" "20"

# set night color
kwriteconfig6 --file kwinrc --group NightColor --key Active "true"
kwriteconfig6 --file kwinrc --group NightColor --key Mode "Constant"
kwriteconfig6 --file kwinrc --group NightColor --key NightTemperature "4000"

# set default terminal to alacritty
kwriteconfig6 --file kdeglobals --group General --key TerminalApplication "alacritty"
kwriteconfig6 --file kdeglobals --group General --key TerminalService "Alacritty.desktop"

# krunner result order with setting favorites
kwriteconfig6 --file krunnerrc --group Plugins --group Favorites --key Plugins "krunner_sessions,krunner_services,krunner_systemsettings,krunner_webshortcuts"

# change the unit to metric
kwriteconfig6 --file plasma-localerc --group Formats --key LC_MEASUREMENT "C"

# change lock screen behavior
kwriteconfig6 --file kscreenlockerrc --group Daemon --key Autolock "false"
kwriteconfig6 --file kscreenlockerrc --group Daemon --key LockGrace "0"
kwriteconfig6 --file kscreenlockerrc --group Daemon --key Timeout "0"
