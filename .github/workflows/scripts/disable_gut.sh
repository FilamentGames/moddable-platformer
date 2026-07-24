#!/usr/bin/env bash

# Remove GUT from enabled editor plugins
sed -i -E 's/(, )?"res:\/\/addons\/gut\/plugin.cfg"(, )?//g' project.godot

# Delete all /test folders
TEST_FOLDERS=$(find . -type d -name "test")

for folder in $TEST_FOLDERS; do
    rm -r $folder
done

# Delete GUT from project
rm -r addons/gut