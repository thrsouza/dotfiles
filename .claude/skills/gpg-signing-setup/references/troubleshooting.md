# Troubleshooting — GPG commit signing on macOS

Jump to the symptom:

- [`error: gpg failed to sign the data`](#gpg-failed-to-sign-the-data)
- [`No secret key` / wrong key used](#no-secret-key--wrong-key)
- [`Inappropriate ioctl for device` / no dialog appears](#inappropriate-ioctl--no-dialog)
- [`WARNING: unsafe permissions on homedir`](#unsafe-permissions)
- [Conflicting `gpg` binaries](#conflicting-gpg-binaries)
- [Keychain doesn't persist after reboot](#keychain-not-persisting)
- [Commit shows "Unverified" on GitHub](#unverified-on-github)
- [SSH signing is configured instead of GPG](#ssh-vs-gpg)
- [Key expired](#key-expired)

First, always confirm whether the problem is Git or gpg itself by signing
directly — this isolates the agent/pinentry layer from Git:

```bash
echo test | gpg --clearsign -u <KEYID>
```

If that fails, the issue is in gpg/gpg-agent/pinentry, not Git.

---

## gpg failed to sign the data

`error: gpg failed to sign the data` / `fatal: failed to write commit object`.

Common causes and fixes:

- **`user.signingkey` is wrong or unset** — `git config --global user.signingkey
  <KEYID>` with an id from `gpg --list-secret-keys --keyid-format=long`.
- **Git is calling a different gpg** than the one holding your key — see
  [conflicting binaries](#conflicting-gpg-binaries).
- **The agent can't show a prompt** — reload it and retry:
  `gpg-connect-agent reloadagent /bye`.

## No secret key / wrong key

- List what you actually have: `gpg --list-secret-keys --keyid-format=long`.
- The id Git needs is the token after the algorithm on the `sec` line (e.g.
  `ed25519/ABCD1234EF567890` → `ABCD1234EF567890`); the full fingerprint works
  too.
- If there's no `sec` line at all, there's no private key on this machine —
  generate (`gpg --quick-generate-key ...`) or `gpg --import` an existing one.

## Inappropriate ioctl / no dialog

`gpg: signing failed: Inappropriate ioctl for device`, or no passphrase dialog
ever appears.

This means a **terminal** pinentry is being used without a usable TTY. On macOS
the fix is to use the GUI pinentry instead:

- Ensure `pinentry-mac` is installed (`brew install pinentry-mac`) and referenced
  in `~/.gnupg/gpg-agent.conf`:
  `pinentry-program /opt/homebrew/bin/pinentry-mac` (use `$(brew --prefix)`).
- Reload: `gpg-connect-agent reloadagent /bye`.
- Only if you deliberately want a terminal pinentry: `export GPG_TTY=$(tty)` in
  your shell profile.

## Unsafe permissions

`WARNING: unsafe permissions on homedir '~/.gnupg'`.

```bash
chmod 700 ~/.gnupg
chmod 600 ~/.gnupg/*.conf 2>/dev/null
```

## Conflicting gpg binaries

A system/GPGTools gpg and a Homebrew gpg can coexist and disagree about where
keys live.

```bash
which -a gpg                 # see all of them
git config --global gpg.program "$(brew --prefix)/bin/gpg"   # pin Git to Homebrew's
```

Make sure the gpg that lists your key (`gpg --list-secret-keys`) is the same one
Git is pointed at.

## Keychain not persisting

You still get prompted after a reboot.

- The **"Save in Keychain"** checkbox wasn't ticked. Trigger a sign again and
  tick it: `echo test | gpg --clearsign -u <KEYID>`.
- Confirm the configured pinentry really is `pinentry-mac` (only it integrates
  with the Keychain) — check `pinentry-program` in `~/.gnupg/gpg-agent.conf`.
- gpg-agent's own cache (the TTLs) is memory-only and always clears on reboot;
  durability comes solely from the Keychain entry.

## Unverified on GitHub

A correctly signed commit still needs three things to line up for the Verified
badge:

1. The **public key** is added to GitHub (Settings → SSH and GPG keys):
   `gpg --armor --export <KEYID>`.
2. The commit's `git config user.email` matches a **UID email on the key**.
3. That same email is a **verified email** on the GitHub account.

A mismatch on any of the three yields "Unverified".

## SSH vs GPG

If `git config --global gpg.format` returns `ssh`, Git is doing **SSH** commit
signing, not GPG — this skill's GPG setup won't take effect. To switch to GPG:

```bash
git config --global --unset gpg.format     # back to openpgp (GPG)
git config --global user.signingkey <GPG_KEYID>
```

## Key expired

`gpg --list-keys` shows `[expired]`. Extend rather than regenerate:

```bash
gpg --quick-set-expire <FINGERPRINT> 2y
```

Then re-export the public key and update it on GitHub.
