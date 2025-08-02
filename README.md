# Dotfiles

Personal dotfiles and configuration files for macOS development environment.

## Overview

This repository contains my personal configuration files for:
- Shell configuration (zsh)
- Git configuration
- Cursor editor settings
- iTerm2 terminal configuration
- Homebrew packages
- GPG key configuration

## Files and Directories

### Core Configuration
- `zshrc` - Zsh shell configuration
- `gitconfig` - Git global configuration
- `config.fish` - Fish shell configuration (alternative)

### Editor Settings
- `cursor/settings.json` - Cursor editor settings

### Terminal Configuration
- `iterm2/thrsouza.json` - iTerm2 profile configuration
- `assets/iterm2-appearence-*.png` - iTerm2 appearance screenshots

### Package Management
- `brew.sh` - Homebrew packages installation script

### Templates
- `gitignore/` - Git ignore templates for different languages
  - `clojure.gitignore` - Clojure-specific gitignore
  - `go.gitignore` - Go-specific gitignore

## Documentation

- [GPG.md](docs/GPG.md) - GPG key setup and configuration guide
- [iTerm2.md](docs/iTerm2.md) - iTerm2 terminal configuration guide

## Installation

### Quick Setup

1. Clone this repository:
   ```bash
   git clone <repository-url>
   cd dotfiles
   ```

2. Install Homebrew packages:
   ```bash
   ./brew.sh
   ```

3. Follow the specific configuration guides:
   - [GPG Setup](docs/GPG.md) - For GPG key configuration
   - [iTerm2 Setup](docs/iTerm2.md) - For terminal configuration

### Manual Configuration

#### Shell Configuration
```bash
# Link zsh configuration
ln -sf ~/path/to/dotfiles/zshrc ~/.zshrc

# Or for fish shell
ln -sf ~/path/to/dotfiles/config.fish ~/.config/fish/config.fish
```

#### Git Configuration
```bash
# Link git configuration
ln -sf ~/path/to/dotfiles/gitconfig ~/.gitconfig
```

#### iTerm2 Configuration
1. Open iTerm2
2. Go to Preferences → Profiles
3. Import the `iterm2/thrsouza.json` profile
4. Set as default (optional)

## Features

### Terminal (iTerm2)
- Custom color scheme with light/dark mode support
- JetBrains Mono font with ligatures
- Transparency and blur effects
- Optimized for development workflow

### Shell (Zsh)
- Enhanced prompt with git integration
- Aliases for common commands
- Environment variables setup
- Plugin management

### Git
- Global configuration
- User information setup
- Common aliases and shortcuts
- Editor integration

### Editor (Cursor)
- Optimized settings for development
- Theme and appearance configuration
- Extension recommendations

## Contributing

Feel free to fork this repository and adapt it to your needs. The configurations are designed to be modular, so you can pick and choose what works for you.

## License

This project is open source and available under the [MIT License](LICENSE).
