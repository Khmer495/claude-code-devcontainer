#!/bin/bash
# Script to install Flutter via asdf
# This can be run inside the container after it's started

set -e

echo "Installing Flutter via asdf..."
echo "Note: This will download ~1.3GB and may take several minutes."

# Source asdf
source /home/linuxbrew/.linuxbrew/opt/asdf/libexec/asdf.sh

# Add Flutter plugin if not already added
if ! asdf plugin list | grep -q flutter; then
    asdf plugin add flutter https://github.com/oae/asdf-flutter.git
fi

# Install Flutter
echo "Downloading and installing Flutter 3.19.5..."
asdf install flutter 3.19.5

# Set as default
asdf set --home flutter 3.19.5

# Reshim
asdf reshim

# Verify installation
echo "Verifying Flutter installation..."
flutter --version

echo "Flutter installation complete!"