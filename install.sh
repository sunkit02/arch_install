#!/bin/sh

INSTALL_ARGS="-S --needed --noconfirm"

LOCAL_SRC="$HOME/.local/src"
DOTFILES_DIR="$HOME/.dotfiles"

DWM_DIR="$LOCAL_SRC/dwm"
SLOCK_DIR="$LOCAL_SRC/slock"
SCRIPTS_DIR="$LOCAL_SRC/scripts"

SSH_KEY="$HOME/.ssh/github"

mkdir -p "$LOCAL_SRC" && \
  yay --version > /dev/null && \
  cat "$SSH_KEY" > /dev/null && \
  SETUP_COMPLETE=yes

if [ "$SETUP_COMPLETE" != "yes" ]; then
  echo "Please run setup.sh first before you run this script."
  exit 1
fi

# WARN: Don't double quote this variable for yay and pacman

echo "Installing packages..."

# Read packages
PACKAGES="$(grep -v '#' packages | sed '/^$/d' | tr '\n' ' ')"

# Install packages with yay
yay $INSTALL_ARGS $PACKAGES

# Change default shell to zsh
sudo chsh -s /usr/bin/zsh "$USER"

# Install fonts
sudo pacman $INSTALL_ARGS tty-fira-code tty-fira-mono tty-firacode-nerd wqy-zenhei

# Install arc-gtk-theme
sudo pacman $INSTALL_ARGS arc-gtk-theme

# Pull configs from Github
eval "$(ssh-agent -s)" && ssh-add ~/.ssh/github

echo "Pulling dotfiles..."
git clone git@github.com:sunkit02/dotfiles.git "$DOTFILES_DIR"

echo "Pulling scripts..."
git clone git@github.com:sunkit02/my-local-shell-scripts.git "$SCRIPTS_DIR"

echo "Pulling dwm..."
git clone git@github.com:sunkit02/dwm.git "$DWM_DIR"

echo "Pulling slock..."
git clone git@github.com:sunkit02/slock.git "$SLOCK_DIR"

# Configure dotfiles
cd "$DOTFILES_DIR" || (echo "Failed to cd into $DOTFILES_DIR" && exit 1)
./install.sh

# Setup tmux  
cd "$DOTFILES_DIR/config/tmux" || (echo "Failed to cd into tmux" && exit 1)
sh setup.sh

# Deploy scripts
cd "$SCRIPTS_DIR" || (echo "Failed to cd into scripts" && exit 1)
./deploy_scripts.sh

# Build DWM
cd "$DWM_DIR" || (echo "Failed to cd into dwm" && exit 1)
sudo make clean install

# Build slock
cd "$SLOCK_DIR" || (echo "Failed to cd into slock" && exit 1)

# Replace sunkit with the current user name in config.h in-place
# TODO: Make this more elegant
sed -i "s/sunkit/$USER/g" config.h

# Only install for current user due to location of screensaver image
sudo make clean install

# Closing instructions
echo "Installation complete!"
echo "Run 'startx' to start the X11 server and DWM."
