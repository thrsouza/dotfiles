#!/usr/bin/env bash
# diagnose.sh — read-only snapshot of the macOS GPG commit-signing setup.
#
# Prints everything the gpg-signing-setup skill needs to decide what (if
# anything) to change. Mutates nothing; safe to run repeatedly.

echo "## platform"
echo "uname: $(uname -s) $(uname -m)"
echo "macos_version: $(sw_vers -productVersion 2>/dev/null || echo unknown)"

echo
echo "## homebrew"
if command -v brew >/dev/null 2>&1; then
  echo "brew: $(command -v brew)"
  echo "brew_prefix: $(brew --prefix)"
else
  echo "brew: NOT INSTALLED  (prerequisite — see https://brew.sh)"
fi

echo
echo "## gpg toolchain"
for bin in gpg gpg-agent gpg-connect-agent pinentry-mac; do
  if command -v "$bin" >/dev/null 2>&1; then
    echo "$bin: $(command -v "$bin")"
  else
    echo "$bin: NOT INSTALLED"
  fi
done
command -v gpg >/dev/null 2>&1 && gpg --version 2>/dev/null | head -1

echo
echo "## git signing config (global)"
for key in commit.gpgsign tag.gpgsign user.signingkey gpg.format gpg.program user.name user.email; do
  val="$(git config --global --get "$key" 2>/dev/null)"
  echo "$key = ${val:-<unset>}"
done

echo
echo "## git signing config (current repo overrides, if any)"
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  found=0
  for key in commit.gpgsign user.signingkey gpg.format gpg.program; do
    val="$(git config --local --get "$key" 2>/dev/null)"
    if [ -n "$val" ]; then echo "(local) $key = $val"; found=1; fi
  done
  [ "$found" -eq 0 ] && echo "(no local overrides)"
else
  echo "(not inside a git repo)"
fi

echo
echo "## secret keys"
if command -v gpg >/dev/null 2>&1; then
  gpg --list-secret-keys --keyid-format=long 2>/dev/null || echo "(none / gpg error)"
else
  echo "(gpg not installed)"
fi

echo
echo "## gpg-agent.conf"
conf="$HOME/.gnupg/gpg-agent.conf"
if [ -f "$conf" ]; then
  echo "path: $conf"
  echo "perms: $(stat -f '%Lp' "$conf" 2>/dev/null)"
  echo "--- contents ---"
  cat "$conf"
  echo "--- end ---"
else
  echo "$conf: DOES NOT EXIST"
fi

echo
echo "## ~/.gnupg directory"
if [ -d "$HOME/.gnupg" ]; then
  echo "perms: $(stat -f '%Lp' "$HOME/.gnupg" 2>/dev/null)  (want 700)"
else
  echo "DOES NOT EXIST (created on first gpg use)"
fi
