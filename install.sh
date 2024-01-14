#!/bin/sh

if [ "$SETUP_COMPLETE" != "yes" ]; then
  echo "Please run setup.sh first before you run this script."
  exit 1
fi

CWD=$(pwd)

# WARN: Don't double quote this variable for yay and pacman
INSTALL_ARGS="-S --needed --noconfirm"

LOCAL_SRC="$HOME/.local/src"

DOTFILES_DIR="$HOME/.dotfiles"
DWM_DIR="$LOCAL_SRC/dwm"
SLOCK_DIR="$LOCAL_SRC/slock"

echo "Installing packages..."

# Read packages
PACKAGES="$(grep -v '#' packages | sed '/^$/d')"

# Install packages with yay
yay $INSTALL_ARGS $PACKAGES

# Change default shell to zsh
sudo chsh -s /usr/bin/zsh "$USER"

# Install fonts
sudo pacman $INSTALL_ARGS tty-fira-code tty-fira-mono tty-firacode-nerd wqy-zenhei

# Pull configs from Github
echo "Pulling dotfiles..."
git clone git@github.com:sunkit02/dotfiles.git "$DOTFILES_DIR"

echo "Pulling dwm..."
git clone git@github.com:sunkit02/dwm.git "$DWM_DIR"

echo "Pulling slock..."
git clone git@github.com:sunkit02/slock.git "$SLOCK_DIR"

# Configure dotfiles
cd "$DOTFILES_DIR" || exit 1
./install.sh

# Build DWM
cd "$DWM_DIR" || exit 1

# TODO: Move installing this dependency to DWM itself
sudo pacman $INSTALL_ARGS yajl

sudo make clean install

# Build slock
cd "$SLOCK_DIR" || exit 1

# Replace sunkit with the current user name in config.h in-place
# TODO: Make this more elegant
sed -i "s/sunkit/$USER/g" config.h

# Only install for current user due to location of screensaver image
make clean install

# Closing instructions
echo "Installation complete!"
echo "Run 'startx' to start the X11 server and DWM."
