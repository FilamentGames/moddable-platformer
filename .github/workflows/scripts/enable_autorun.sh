#!/usr/bin/env bash

# Enable autorun in editor
sed -i -E 's/auto_play_on_start=(.+?)/auto_play_on_start=true/' project.godot