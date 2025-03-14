#!/bin/bash

# Find the flutter_plugin_android_lifecycle directory
PLUGIN_DIR="$(find ~/.pub-cache -name flutter_plugin_android_lifecycle -type d | grep -v example)/android"

# If found, modify its build.gradle
if [ -d "$PLUGIN_DIR" ]; then
  echo "Found plugin at $PLUGIN_DIR"
  sed -i 's/compileSdk 35/compileSdk 34/g' "$PLUGIN_DIR/build.gradle"
  echo "Updated plugin to use compileSdk 34"
else
  echo "Could not find flutter_plugin_android_lifecycle plugin directory"
fi
