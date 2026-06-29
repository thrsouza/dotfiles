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

# CocoaPods
brew install cocoapods

# Install GO
brew install go

# Install UV
brew install uv

# Install NVM
brew install nvm

# Install iTerm2
brew install --cask iterm2

# Install Tmux
# brew install tmux

# Install Starship prompt
brew install starship

# Install Zsh plugins
brew install zsh-autosuggestions
brew install zsh-syntax-highlighting

# Install Fonts
brew install --cask font-jetbrains-mono-nerd-font
brew install --cask font-jetbrains-mono

# Update and clean up Homebrew
brew update
brew upgrade
brew upgrade --cask
brew cleanup --prune=all

# Install Claude Code
curl -fsSL https://claude.ai/install.sh | bash

# Install SDKMAN
curl -s "https://get.sdkman.io" | bash
