# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

Personal macOS dotfiles for Thiago Souza. Shell, git, terminal, and tool configurations linked or copied into `$HOME`.

## Setup

Two scripts, in order:

1. `./install.sh` — installs Homebrew packages (`git`, `gh`, `gpg`, `go`, `openjdk`, `maven`, `uv`, `nvm`, `tmux`, `neovim`, `starship`, `zsh-autosuggestions`, `zsh-syntax-highlighting`, iTerm2, JetBrains Mono fonts) and Claude Code, then links OpenJDK into `/Library/Java/JavaVirtualMachines/`.
2. `./apply.sh` — symlinks `.tmux.conf` and `.config/starship.toml`, copies `.gitconfig` and `.claude/` files into `$HOME`. Safe to re-run.

`.zshrc` is linked manually to avoid clobbering an existing one:
```bash
ln -sf ~/dev/thrsouza/dotfiles/.zshrc ~/.zshrc
```

## Structure

- `.zshrc` — Zsh config: GPG agent, Go/Java paths, zsh-autosuggestions + zsh-syntax-highlighting, Starship init, aliases
- `.gitconfig` — Git globals: GPG commit signing enabled (`commit.gpgsign = true`), pull fast-forward only, color UI
- `.tmux.conf` — tmux config: prefix `C-a`, vim-style pane bindings, dark minimal status bar
- `.config/starship.toml` — Starship prompt: dark minimal, two-line, git-aware
- `install.sh` — Homebrew + Claude Code installer
- `apply.sh` — Symlinks configs and copies `.gitconfig` / `.claude/` into `$HOME`
- `.claude/settings.json` — Claude Code settings (model: sonnet, custom statusline)
- `.claude/statusline-command.sh` — Statusline script showing cwd, git branch, model, context bar, and cost
- `iterm2/thrsouza.json` — iTerm2 profile (JetBrains Mono, transparency/blur)
- `gitignore/` — Language-specific `.gitignore` templates
- `docs/GPG.md` — GPG key generation and Git signing setup
- `docs/iTerm2.md` — iTerm2 profile import guide

## Key Notes

- `.gitconfig` is **copied** (not symlinked) because the `signingkey` is machine-specific — edit `~/.gitconfig` freely without touching the repo. See `docs/GPG.md`.
- `.claude/` files are also copied because Claude Code writes to them.
- `.tmux.conf` and `starship.toml` are **symlinked** so edits in the repo apply immediately.
- The `bora` alias in `.zshrc` runs a full Homebrew update/upgrade/cleanup cycle.
- The Claude statusline script reads JSON from stdin, requires `jq`, outputs two lines: directory + branch, then model + context bar + estimated cost.
- tmux prefix is `C-a` (not the default `C-b`); `|` / `-` split panes, `hjkl` navigate, `C-a r` reloads config.
