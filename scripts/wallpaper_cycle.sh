#!/bin/bash

# Path to your wallpapers directory
WALLPAPER_DIR="$HOME/documents/wallpapers"

# Get a random wallpaper from the directory
WALLPAPER=$(find "$WALLPAPER_DIR" -type f | shuf -n 1)

# Set the wallpaper using swaymsh
swaymsg output "*" bg "$WALLPAPER" fill

