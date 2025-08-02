#!/bin/bash

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "Homebrew is not installed. Please install Homebrew first."
    exit 1
fi

# Install tools
brew install bat
brew install git
brew install gpg
brew install gpg-agent
brew install fish
brew install fzf
brew install starship

# Install Fonts
brew install --cask font-jetbrains-mono-nerd-font
brew install --cask font-jetbrains-mono

# Install GO
brew install go

# Install Clojure and Leiningen
brew install clojure
brew install leiningen

# Update and clean up Homebrew
brew update;
brew upgrade;
brew upgrade --cask;
brew cleanup --prune=all
