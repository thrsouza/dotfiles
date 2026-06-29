---
name: gpg-signing-setup
description: >-
  Set up verified GPG commit signing on macOS and stop Git from repeatedly
  asking for the GPG passphrase. Use this whenever the user wants signed or
  "Verified" Git commits, mentions GPG/PGP signing, is setting up a new Mac for
  development, complains that Git or gpg keeps prompting for their passphrase or
  key on every commit, wants their commits to show as Verified on GitHub, or
  needs pinentry-mac, gpg-agent passphrase caching, or Keychain integration for
  signing. macOS only.
---

# GPG commit signing setup (macOS)

End state: the user's Git commits are signed with a GPG key (and show as
**Verified** on GitHub), and the passphrase is entered **once** — then served
silently from the macOS Keychain — instead of on every commit.

This skill is **macOS-only**. The smooth, never-prompt-again experience relies on
`pinentry-mac`, which stores the passphrase in the macOS **Keychain** — there is
no equivalent on other platforms. If `uname -s` is not `Darwin`, stop and tell
the user this skill doesn't apply to their OS.

## How to work through this

Two things make this skill different from a normal scripted setup:

1. **Diagnose before you touch anything.** Most machines already have *some* of
   this in place — a key, signing enabled, a half-written `gpg-agent.conf`. Read
   the full picture first, then do only the missing parts. Re-running the skill
   on an already-configured machine should be a no-op, not a reset.
2. **One step needs a human.** Priming the Keychain requires the `pinentry-mac`
   GUI dialog, where the user ticks "Save in Keychain". You cannot click that for
   them. When you reach it, pause and ask them to interact, then continue.

Work through the phases in order. Skip any phase whose work the diagnosis shows
is already done.

---

## Phase 1 — Diagnose (read-only, never skip)

Run the bundled diagnosis script. It changes nothing and is safe to repeat:

```bash
bash <skill-dir>/scripts/diagnose.sh
```

It reports: platform + architecture, whether Homebrew / gpg / `pinentry-mac` are
installed (and the Homebrew prefix), the global Git signing config, any existing
secret keys, and the current `~/.gnupg/gpg-agent.conf` with its permissions.

Read the output and decide which of the following are **already true** so you can
skip them:

- A usable secret key exists (a `sec` line in the key list).
- `user.signingkey` is set and `commit.gpgsign = true`.
- `pinentry-mac` is installed and referenced by `gpg-agent.conf`.

Then **branch on these conditions before changing anything**:

- **Not macOS** → stop; this skill doesn't apply.
- **`gpg.format = ssh`** → Git is configured for **SSH** commit signing, not GPG.
  This skill configures GPG. Surface this and confirm the user actually wants
  GPG before proceeding. To switch: `git config --global --unset gpg.format`
  (reverts to openpgp), then continue.
- **Homebrew missing** → it's a prerequisite for installing `gnupg` /
  `pinentry-mac`. Point the user to <https://brew.sh> and stop until it's
  installed; don't try to install Homebrew for them.

Briefly tell the user the short plan — only the missing pieces — then proceed.

Throughout the rest of the skill, resolve the Homebrew bin directory at runtime
rather than hardcoding it (`/opt/homebrew` on Apple Silicon, `/usr/local` on
Intel):

```bash
BREW_BIN="$(brew --prefix)/bin"
```

---

## Phase 2 — Configure signing (only the missing parts)

Do each sub-step **only if** Phase 1 showed it's needed.

**gpg not installed:**

```bash
brew install gnupg
```

**No secret key — generate one.** Default the identity to the user's Git
name/email so signatures match their commits, and confirm with them first.
Prefer **ed25519** (modern, fast, small; GitHub-verified) — offer **rsa4096** if
they need maximum compatibility with older tooling. Set an expiry (renewable) as
good hygiene:

```bash
# ed25519 (recommended)
gpg --quick-generate-key "Full Name <email@example.com>" ed25519 sign 2y
# or rsa4096
gpg --quick-generate-key "Full Name <email@example.com>" rsa4096 sign 2y
```

If the user already has a key elsewhere, they can `gpg --import` it instead.

**Tell Git which key to sign with.** Get the key id (the token after the
algorithm on the `sec` line, e.g. `ed25519/ABCD1234...`) — or use the full
fingerprint, which Git also accepts. If there are multiple keys, ask which one:

```bash
gpg --list-secret-keys --keyid-format=long
git config --global user.signingkey <KEYID>
```

**Enable signing.** Commits always; offer tags too:

```bash
git config --global commit.gpgsign true
git config --global tag.gpgsign true   # optional, ask
```

**Get the "Verified" badge on GitHub.** A signed commit only shows as Verified
once GitHub knows the public key *and* the commit's email matches both a UID on
the key and a verified email on the account. Export the public key and have the
user paste it into GitHub → Settings → SSH and GPG keys → New GPG key:

```bash
gpg --armor --export <KEYID>
```

This step is the user's to complete in the browser — give them the block and the
link, don't try to upload it yourself.

---

## Phase 3 — Passphrase caching (the part that stops the prompts)

This is the core fix: configure `gpg-agent` to use `pinentry-mac`, which can
stash the passphrase in the Keychain.

**Install pinentry-mac if missing:**

```bash
brew install pinentry-mac
```

**Point gpg-agent at it and set cache lifetimes — idempotently.** Use the
bundled helper, which updates each option in place (or appends it), preserving
any other lines already in the file and never creating duplicates. Don't
hand-write the file with `>` if it already exists — you'd clobber settings the
user may rely on.

```bash
CONF="$HOME/.gnupg/gpg-agent.conf"
python3 <skill-dir>/scripts/set-conf-value.py "$CONF" pinentry-program "$(brew --prefix)/bin/pinentry-mac"
python3 <skill-dir>/scripts/set-conf-value.py "$CONF" default-cache-ttl 86400    # see note
python3 <skill-dir>/scripts/set-conf-value.py "$CONF" max-cache-ttl   604800     # see note
```

**Choosing the TTLs.** `default-cache-ttl` is the **inactivity** timeout (resets
on each use); `max-cache-ttl` is the **absolute** cap since the passphrase was
first entered. Both are in seconds. Once "Save in Keychain" is used these are
largely a safety net — the passphrase comes from the Keychain regardless — so
modest values are fine (the defaults above are 1 day / 7 days). If the user
wants longer, multiply days × 86400 (e.g. 30 days = `2592000`, 60 days =
`5184000`). Note that `0` **disables** the cache rather than making it eternal;
the only true "never again, even across reboots" is the Keychain.

**Fix permissions** — gpg refuses to use a world-readable home and warns on a
loose conf file:

```bash
chmod 700 "$HOME/.gnupg"
chmod 600 "$CONF"
```

**Reload the agent** so it reads the new config:

```bash
gpg-connect-agent reloadagent /bye
```

---

## Phase 4 — Verify and prime the Keychain (needs the human)

Trigger one signature to make the `pinentry-mac` dialog appear. **Tell the user
to type their passphrase and tick "Save in Keychain"** — that checkbox is what
makes it permanent:

```bash
echo test | gpg --clearsign -u <KEYID> >/dev/null && echo "OK: signed"
```

Then confirm it's now silent (this second one should not prompt at all):

```bash
echo test | gpg --clearsign -u <KEYID> >/dev/null && echo "OK: cached, no prompt"
```

If the first call hangs, the dialog is waiting on screen — the user just needs to
respond. If signing fails, see `references/troubleshooting.md`.

---

## Phase 5 — Summarize

Report back concisely:

- What was changed vs. already in place (key generated/selected, signing enabled,
  pinentry-mac installed, `gpg-agent.conf` keys set).
- The signing key id, and whether the public key still needs adding to GitHub.
- The cache TTLs, and the **Keychain caveat**: with "Save in Keychain" ticked the
  passphrase survives reboots and never gets asked again; the gpg-agent cache
  alone is cleared on reboot, so without the Keychain they'll be asked once per
  boot. The TTLs are just the in-memory fallback.

---

## Key facts (the bits people get wrong)

- **Keychain vs. gpg-agent cache.** The gpg-agent cache lives in memory and dies
  on reboot/agent restart. The Keychain entry (via `pinentry-mac` + "Save in
  Keychain") is persistent and is what delivers "never asked again". They work
  together; the Keychain is the durable layer.
- **TTL `0` ≠ forever.** `0` turns the in-memory cache off. Durability comes from
  the Keychain, not from large TTLs.
- **Verified needs three things to line up:** public key on GitHub, the key's UID
  email, and the commit's `user.email` — all matching a verified GitHub email.
- **Homebrew prefix differs by chip.** Always resolve `$(brew --prefix)` rather
  than assuming `/opt/homebrew`.

## Troubleshooting

For signing errors (`gpg failed to sign the data`, `No secret key`,
`Inappropriate ioctl for device`), unsafe-permission warnings, conflicting `gpg`
binaries, Keychain not persisting, or "Unverified" on GitHub, read
`references/troubleshooting.md`.
