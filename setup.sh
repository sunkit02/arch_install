#!/bin/sh

RED='\033[0;31m'
NC='\033[0m' # No Color

# WARN: Don't double quote these two variable for yay and pacman
UPDATE_ARGS="-Syu --noconfirm"
INSTALL_ARGS="-S --needed --noconfirm"

LOCAL_SRC="$HOME/.local/src"

# Update system
sudo pacman $UPDATE_ARGS

# Install git
echo "Installing Git..."

sudo pacman $INSTALL_ARGS base base-devel git

if [ ! $? ]; then
  printf "${RED}Failed to install Git.${NC}\n"
  exit 1
fi

# Install yay
echo "Installing Yay..."

mkdir -p "$LOCAL_SRC"
cd "$LOCAL_SRC" || exit 1

git clone https://aur.archlinux.org/yay.git

cd yay || exit 1
makepkg -si --noconfirm
yay --version || (printf "${RED}Failed to install Yay.${NC}\n" && exit 1)

# Generate Github SSH key
SSH_DIR="$HOME/.ssh"
mkdir -p "$SSH_DIR"

SSH_KEY="$SSH_DIR/github"
printf "\n\n" | ssh-keygen -t ed25519 -f "$SSH_KEY"

# Prompt user to add SSH key to Github
printf "Add the following SSH key at %s to your Github. Checkout: https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account for help.\n" "$SSH_KEY.pub"
echo "Copy the following:"
cat "$SSH_KEY.pub"
