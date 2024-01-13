#!/bin/sh

UPDATE_ARGS="-Syu --noconfirm"
INSTALL_ARGS="-S --noconfirm"

# Update system
sudo pacman "$UPDATE_ARGS"

# Install git

packages="$(grep -v '#' packages | sed '/^$/d')"
