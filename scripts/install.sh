#!/bin/sh

# That is the file that should be run when you want to set up your shiny new Arch Linux install.
# NOTICE: At this point you should be booted into Arch Linux directly, and have sudo set up and working.
# It takes care of installing python, setting up some repos and calls python installer in the end.
# It is best to have installed at least base and base-devel.

# !!! This file should be run from scripts folder directly (relative paths).


# Enable multilib pacman.
echo '[multilib]' | sudo tee --append /etc/pacman.conf
echo 'Include = /etc/pacman.d/mirrorlist' | sudo tee --append /etc/pacman.conf

# Add sublime repository.
curl -O https://download.sublimetext.com/sublimehq-pub.gpg && sudo pacman-key --add sublimehq-pub.gpg && sudo pacman-key --lsign-key 8A8F901A && rm sublimehq-pub.gpg

# Find fastest servers and use them with pacman.
sudo pacman -Sy pacman-contrib
rankmirrors -n 15 /etc/pacman.d/mirrorlist > mirrorlist
sudo mv /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist_backup
sudo mv mirrorlist /etc/pacman.d/mirrorlist

# Run system upgrade.
sudo pacman -Syu

# Install python3 and git so we can run setup.py (isn't python3 already installed?)
sudo pacman -S python3 git

# Let the python do the hard work.

# Install yay.
python3 setup.py install --install-aur-helper yay
# Install official repo packages. (We run it with sudo to get necessary privileges for pacman.)
sudo python3 setup.py install --install-from-file ../setup/apps_list/arch_repo_apps --install-command S --do-not-reinstall
# Install AUR packages.
python3 setup.py install --install-from-file ../setup/apps_list/arch_aur_apps --install-command S --package-manager yay --do-not-reinstall
# Set up npm.
python3 setup.py setup --set-up-npm-dir ~/npm_global
# Symlink dotfiles.
python3 setup.py setup --symlink-dotfiles ../setup/dotfiles/ ~/backup_dotfiles

# Change shell to ZSH.
chsh -s /usr/bin/zsh

# Install plugins for VIM
sh ./setup/configure_vim.sh
# Install plugins for tmux.
sh ./setup/configure_tmux.sh

# Install stuff for Go, Python, js.
sh ./setup/go_packages.sh
sh ./setup/js_packages.sh
sh ./setup/python_packages.sh

# Initial setup for ZSH.
echo "typeset -U path" > ~/.zprofile

python3 setup.py setup --source-shell-files ../setup/shell/ ~/.zprofile

# Add this scripts folder to PATH.
python3 setup.py setup --add-to-path . ~/.zprofile

# Configure thefuck.
fuck
fuck

# Enable net usage.
sudo systemctl start vnstat
sudo systemctl enable vnstat

echo "Now add absolute path to resolution.py to your .xinitrc in home folder."
