# dotfiles

Personal macOS development environment configuration by [Thiago Souza](https://github.com/thrsouza).

## What's included

| File/Directory | Purpose |
|---|---|
| `.zshrc` | Zsh config — GPG agent, Go/Java paths, autosuggestions + syntax highlighting, Starship init, aliases |
| `.gitconfig` | Git globals — GPG signing, colors, pull fast-forward |
| `.tmux.conf` | tmux — prefix `C-a`, vim-style bindings, dark minimal status bar |
| `.config/starship.toml` | Starship prompt — dark minimal, two-line, git-aware |
| `install.sh` | Homebrew bootstrap + Claude Code installer |
| `apply.sh` | Symlink tmux + starship, copy `.gitconfig` and Claude settings into `$HOME` |
| `.claude/` | Claude Code settings and custom statusline script |
| `iterm2/thrsouza.json` | iTerm2 profile — JetBrains Mono, transparency/blur |
| `gitignore/` | Language-specific `.gitignore` templates |
| `docs/` | Setup guides for GPG and iTerm2 |

## Setup

### 1. Install packages

```bash
./install.sh
```

Installs: `git`, `gh`, `gpg`, `go`, `openjdk`, `maven`, `uv`, `nvm`, `tmux`, `neovim`, `starship`, `zsh-autosuggestions`, `zsh-syntax-highlighting`, iTerm2, JetBrains Mono fonts, and Claude Code.

### 2. Apply configs

```bash
./apply.sh
```

- Symlinks: `.tmux.conf`, `.config/starship.toml`
- Copies: `.gitconfig` (signingkey is machine-specific), `.claude/settings.json`, `.claude/statusline-command.sh`

Safe to re-run.

### 3. Symlink shell config

Kept separate to avoid clobbering an existing `.zshrc`:

```bash
ln -sf ~/path/to/dotfiles/.zshrc ~/.zshrc
```

### 4. GPG signing

Commits are signed by default. Follow [docs/GPG.md](docs/GPG.md) to generate a key, then update the `signingkey` in `.gitconfig`.

### 5. iTerm2

Import `iterm2/thrsouza.json` via **Preferences → Profiles → Other Actions → Import JSON Profiles**. See [docs/iTerm2.md](docs/iTerm2.md) for details.

The Claude Code statusline displays current directory, git branch, active model, context window usage, and estimated session cost.

## License

[MIT](LICENSE)
