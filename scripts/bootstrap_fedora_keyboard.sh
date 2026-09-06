#!/usr/bin/env bash

# ---
# kcminputrc
# ---
## update key repeat delay and rate
kwriteconfig6 --file kcminputrc --group Keyboard --key KeyRepeat "repeat"
kwriteconfig6 --file kcminputrc --group Keyboard --key RepeatDelay "200"
kwriteconfig6 --file kcminputrc --group Keyboard --key RepeatRate "25"

# ---
# krunnerrc
# ---
kwriteconfig6 --file krunnerrc --group Plugins --group Favorites --key Plugins "krunner_sessions,krunner_services,krunner_systemsettings,krunner_webshortcuts"

# ---
# kuriikwsfilterrc
# ---
kwriteconfig6 --file kuriikwsfilterrc --group General --key DefaultWebShortcut "google"
kwriteconfig6 --file kuriikwsfilterrc --group General --key EnableWebShortcuts "true"
kwriteconfig6 --file kuriikwsfilterrc --group General --key KeywordDelimiter ":"
kwriteconfig6 --file kuriikwsfilterrc --group General --key PreferredWebShortcuts "google,youtube"
kwriteconfig6 --file kuriikwsfilterrc --group General --key UsePreferredWebShortcutsOnly "true"

# ---
# kxkbrc
# ---
## use caps lock as ctrl key
kwriteconfig6 --file kxkbrc --group Layout --key Options "ctrl:nocaps"
kwriteconfig6 --file kxkbrc --group Layout --key ResetOldOptions "true"

# ---
# kglobalshortcutsrc
# ---
## [unused] remove because of duplication
kwriteconfig6 --file kglobalshortcutsrc --group kwin --key "Edit Tiles" "none,none,Edit Tiles Editor"
## remapping close window key map / some apps uses Ctrl+Q by default so both Ctrl+Q and Alt+Q will work
kwriteconfig6 --file kglobalshortcutsrc --group kwin --key "Window Close" "Alt+Q,none,Close Window"
## [unused] remove because of duplication
kwriteconfig6 --file kglobalshortcutsrc --group kwin --key "Overview" "none,none,Toggle Overview"
## [unused] remove because of duplication
kwriteconfig6 --file kglobalshortcutsrc --group kwin --key "Grid View" "none,none,Toggle Grid View"
## remapping switching windows key map
kwriteconfig6 --file kglobalshortcutsrc --group kwin --key "Walk Through Windows" "Alt+Tab,none,Walk Through Windows"
kwriteconfig6 --file kglobalshortcutsrc --group kwin --key "Walk Through Windows (Reverse)" "Alt+Shift+Tab,none,Walk Through Windows (Reverse)"

## remapping lock mode key map
kwriteconfig6 --file kglobalshortcutsrc --group ksmserver --key "Lock Session" "Meta+L,none,Lock Session"
## remove show desktop key map
kwriteconfig6 --file kglobalshortcutsrc --group ksmserver --key "Show Desktop" "none,none,Peek at Desktop"

## remove power profile switch key map
kwriteconfig6 --file kglobalshortcutsrc --group org_kde_powerdevil --key "powerProfile" "none,none,Switch Power Profile"

## remove all task manager related key map
kwriteconfig6 --file kglobalshortcutsrc --group plasmashell --key "activate task manager entry 1" "none,none,Activate Task Manager Entry 1"
kwriteconfig6 --file kglobalshortcutsrc --group plasmashell --key "activate task manager entry 2" "none,none,Activate Task Manager Entry 2"
kwriteconfig6 --file kglobalshortcutsrc --group plasmashell --key "activate task manager entry 3" "none,none,Activate Task Manager Entry 3"
kwriteconfig6 --file kglobalshortcutsrc --group plasmashell --key "activate task manager entry 4" "none,none,Activate Task Manager Entry 4"
kwriteconfig6 --file kglobalshortcutsrc --group plasmashell --key "activate task manager entry 5" "none,none,Activate Task Manager Entry 5"
kwriteconfig6 --file kglobalshortcutsrc --group plasmashell --key "activate task manager entry 6" "none,none,Activate Task Manager Entry 6"
kwriteconfig6 --file kglobalshortcutsrc --group plasmashell --key "activate task manager entry 7" "none,none,Activate Task Manager Entry 7"
kwriteconfig6 --file kglobalshortcutsrc --group plasmashell --key "activate task manager entry 8" "none,none,Activate Task Manager Entry 8"
kwriteconfig6 --file kglobalshortcutsrc --group plasmashell --key "activate task manager entry 9" "none,none,Activate Task Manager Entry 9"
kwriteconfig6 --file kglobalshortcutsrc --group plasmashell --key "manage activities" "none,none,Show Activity Switcher"

## no konsole launch key map
kwriteconfig6 --file kglobalshortcutsrc --group services --group org.kde.konsole.desktop --key _launch "none"
## remapping krunner launch key map
kwriteconfig6 --file kglobalshortcutsrc --group services --group org.kde.krunner.desktop --key _launch "Alt+Space"

# ---
# plasmakeyboardrc
# ---
## disable pop up on key press
kwriteconfig6 --file plasmakeyboardrc --group General --key diacriticsPopupEnabled false
## disable auto capitalization
kwriteconfig6 --file plasmakeyboardrc --group General --key autoCapitalizationEnabled false

# ---
# apply all of the changes
# ---
busctl --user call org.kde.KWin /KWin org.kde.KWin reconfigure

# ---
# some of the changes will be applied after log-out or restart
# ---
echo "Please restart your computer to apply the changes"
