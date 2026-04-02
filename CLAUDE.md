# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

Personal macOS dotfiles for Thiago Souza. Contains shell, git, terminal, and tool configurations meant to be symlinked into `$HOME`.

## Setup

Run `./setup.sh` to install all Homebrew packages and Claude Code. It installs: `git`, `gh`, `gpg`, `gpg-agent`, `go`, `openjdk`, `maven`, `uv`, iTerm2, JetBrains Mono fonts, then links OpenJDK into `/Library/Java/JavaVirtualMachines/`.

After running setup, manually symlink configs:
```bash
ln -sf ~/dev/o2/dotfiles/zshrc ~/.zshrc
ln -sf ~/dev/o2/dotfiles/gitconfig ~/.gitconfig
```

Copy Claude settings:
```bash
cp claude/settings.json ~/.claude/settings.json
cp claude/statusline-command.sh ~/.claude/statusline-command.sh
```

## Structure

- `zshrc` — Zsh config: GPG agent init, PATH setup for Go and Java, shell aliases
- `gitconfig` — Git globals: GPG commit signing enabled (`commit.gpgsign = true`), pull fast-forward only, color UI
- `setup.sh` — Homebrew bootstrap script
- `claude/settings.json` — Claude Code settings (model: sonnet, custom statusline)
- `claude/statusline-command.sh` — Custom statusline script showing cwd, git branch, model, context bar, and cost
- `iterm2/thrsouza.json` — iTerm2 profile (JetBrains Mono, transparency/blur)
- `gitignore/` — Language-specific `.gitignore` templates
- `docs/GPG.md` — GPG key generation and Git signing setup guide
- `docs/iTerm2.md` — iTerm2 profile import guide

## Key Notes

- All commits must be GPG-signed (`commit.gpgsign = true` in gitconfig). The signing key placeholder is `0000000000000000` — replace with the actual key ID after generating one (see `docs/GPG.md`).
- The `bora` alias in `zshrc` runs a full Homebrew update/upgrade/cleanup cycle.
- The Claude statusline script (`claude/statusline-command.sh`) reads JSON from stdin (Claude Code's status event), requires `jq`, and outputs two lines: directory + branch, then model + context bar + estimated cost.
