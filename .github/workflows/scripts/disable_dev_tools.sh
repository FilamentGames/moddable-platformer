#!/usr/bin/env bash

# Remove Baby Godot Dev Tools from enabled editor plugins
sed -i -E 's/(, )?"res:\/\/addons\/quests_devtools\/plugin.cfg"(, )?//g' project.godot