#!/bin/bash

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "Homebrew is not installed. Installing now..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    exit 1
fi

# Install tools
brew install git
brew install gh
brew install gpg
brew install gpg-agent

# Install GO
brew install go

# Install OpenJDK
brew install openjdk

# Install Maven
brew install maven

# Install UV
brew install uv

# Install iTerm2
brew install --cask iterm2

# Install Fonts
brew install --cask font-jetbrains-mono-nerd-font
brew install --cask font-jetbrains-mono

# Update and clean up Homebrew
brew update;
brew upgrade;
brew upgrade --cask;
brew cleanup --prune=all

# Install Claude Code
curl -fsSL https://claude.ai/install.sh | bash

# Link OpenJDK to the correct location
sudo ln -sfn /opt/homebrew/opt/openjdk/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk.jdk
