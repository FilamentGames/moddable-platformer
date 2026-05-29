#!/bin/bash

# cd to repo root
cd $( git rev-parse --show-toplevel )

# run GUT
godot --headless -s --path "$PWD" addons/gut/gut_cmdln.gd -gdir test -ginclude_subdirs -gexit