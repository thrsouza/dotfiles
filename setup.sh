#!/bin/bash

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "Homebrew is not installed. Please install Homebrew first."
    exit 1
fi

# Install tools
brew install git
brew install gpg
brew install gpg-agent

# Install Fonts
brew install --cask font-jetbrains-mono-nerd-font
brew install --cask font-jetbrains-mono

# Install GO
brew install go

# Install OpenJDK
brew install openjdk

# Install Maven
brew install maven

# Install UV
brew install uv

# Update and clean up Homebrew
brew update;
brew upgrade;
brew upgrade --cask;
brew cleanup --prune=all

# Other commands

# Install Cursor CLI
curl https://cursor.com/install -fsS | bash

# Link OpenJDK to the correct location
sudo ln -sfn /opt/homebrew/opt/openjdk/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk.jdk
