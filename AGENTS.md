# Repository Guidelines

## Project Structure & Module Organization

This repository contains personal macOS dotfiles and setup helpers. Root-level dotfiles such as `.zshrc`, `.gitconfig`, and `.tmux.conf` are the primary configuration sources. `.config/starship.toml` holds the Starship prompt configuration. `.claude/` contains Claude Code settings and statusline tooling. `install.sh` installs Homebrew packages and applications; `apply.sh` applies selected configs into `$HOME`. Documentation lives in `docs/`, images in `assets/`, iTerm2 profiles in `iterm2/`, and language-specific ignore templates in `gitignore/`.

## Build, Test, and Development Commands

There is no compile step. Use these commands for local validation:

```bash
bash -n install.sh apply.sh .claude/statusline-command.sh
```

Checks shell scripts for syntax errors.

```bash
./install.sh
```

Bootstraps Homebrew tools and applications on macOS. Review changes before running because it installs packages and may require `sudo`.

```bash
./apply.sh
```

Copies or symlinks repository configs into `$HOME`. This script is intended to be safe to re-run, but verify target behavior before changing copy versus symlink semantics.

## Coding Style & Naming Conventions

Use Bash for executable scripts and Zsh syntax only in `.zshrc`. Keep scripts readable with uppercase constants such as `DOTFILES_DIR`, quoted variable expansions, and `set -e` for apply-style scripts. Prefer explicit comments for user-impacting setup steps, not line-by-line narration. Keep Markdown concise and link local docs with relative paths, for example `[docs/GPG.md](docs/GPG.md)`.

## Testing Guidelines

No automated test suite is configured. For script changes, run `bash -n` and, when safe, execute the changed script on a disposable or already-backed-up environment. For shell config changes, open a fresh terminal or run `zsh -n .zshrc` to catch syntax errors. For iTerm2 or visual documentation updates, keep screenshots in `assets/` and update `docs/iTerm2.md` if the workflow changes.

## Commit & Pull Request Guidelines

History uses Conventional Commit-style prefixes such as `feat:`, `chore:`, and `refactor:`. Keep using short imperative summaries, for example `feat: add Android SDK path exports`. Pull requests should describe the affected configs, list validation commands run, mention any manual macOS steps, and include screenshots when changing iTerm2 appearance or visual docs.

## Security & Configuration Tips

Do not commit private keys, machine-specific secrets, or generated credentials. `.gitconfig` includes GPG signing configuration, so keep signing keys machine-specific and document setup changes in `docs/GPG.md`.
