#!/usr/bin/env bash
set -euo pipefail

# Step 2: Remove apt version and install via nix

# Remove apt package and repo
sudo apt remove -y gh
sudo rm -f /etc/apt/sources.list.d/github-cli.list
sudo rm -f /etc/apt/keyrings/githubcli-archive-keyring.gpg
sudo apt autoremove -y

echo "Done. gh $(gh --version | head -1)"
