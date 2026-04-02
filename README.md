# dotfiles

Personal macOS development environment configuration by [Thiago Souza](https://github.com/thrsouza).

## What's included

| File/Directory | Purpose |
|---|---|
| `zshrc` | Zsh config — GPG agent, Go/Java paths, aliases |
| `gitconfig` | Git globals — GPG signing, colors, pull fast-forward |
| `setup.sh` | Homebrew bootstrap + Claude Code installer |
| `claude/` | Claude Code settings and custom statusline script |
| `iterm2/thrsouza.json` | iTerm2 profile — JetBrains Mono, transparency/blur |
| `gitignore/` | Language-specific `.gitignore` templates |
| `docs/` | Setup guides for GPG and iTerm2 |

## Setup

### 1. Install packages

```bash
./setup.sh
```

Installs: `git`, `gh`, `gpg`, `go`, `openjdk`, `maven`, `uv`, iTerm2, JetBrains Mono fonts, and Claude Code.

### 2. Symlink configs

```bash
ln -sf ~/path/to/dotfiles/zshrc ~/.zshrc
ln -sf ~/path/to/dotfiles/gitconfig ~/.gitconfig
```

### 3. Claude Code

```bash
cp claude/settings.json ~/.claude/settings.json
cp claude/statusline-command.sh ~/.claude/statusline-command.sh
```

The statusline displays current directory, git branch, active model, context window usage, and estimated session cost.

### 4. GPG signing

Commits are signed by default. Follow [docs/GPG.md](docs/GPG.md) to generate a key, then update the `signingkey` in `gitconfig`.

### 5. iTerm2

Import `iterm2/thrsouza.json` via **Preferences → Profiles → Other Actions → Import JSON Profiles**. See [docs/iTerm2.md](docs/iTerm2.md) for details.

## License

[MIT](LICENSE)
