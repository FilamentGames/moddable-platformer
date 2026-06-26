#!/bin/bash

# cd to repo root
cd $( git rev-parse --show-toplevel )

# run GUT
godot --headless -s --path "$PWD" addons/gut/gut_cmdln.gd -gdir test -gdir addons/quests/test -gdir addons/quests_devtools/test -ginclude_subdirs -gexit