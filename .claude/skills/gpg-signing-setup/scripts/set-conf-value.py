#!/usr/bin/env python3
"""Idempotently set a ``key value`` line in a gpg-style config file.

``gpg-agent.conf`` and ``gpg.conf`` use space-separated ``option value`` lines.
This updates the option in place if it's already present (preserving every other
line, including comments and ordering) or appends it otherwise, then enforces
safe permissions (dir 700, file 600).

Re-running with the same arguments is a no-op. Re-running with a new value
replaces just that option's line. Duplicate active lines for the same option are
collapsed to one. This is safer than ``sed``/``>>`` for editing config a user may
already have customized.

Usage:
    set-conf-value.py <conf_path> <key> <value>
"""
import os
import sys


def main() -> None:
    if len(sys.argv) != 4:
        sys.exit("usage: set-conf-value.py <conf_path> <key> <value>")

    path, key, value = sys.argv[1], sys.argv[2], sys.argv[3]
    new_line = f"{key} {value}"

    parent = os.path.dirname(os.path.abspath(path))
    os.makedirs(parent, mode=0o700, exist_ok=True)

    lines = []
    if os.path.exists(path):
        with open(path, "r", encoding="utf-8") as fh:
            lines = fh.read().splitlines()

    replaced = False
    out = []
    for line in lines:
        stripped = line.strip()
        # Only an active (non-comment) line whose first token is our key counts.
        if stripped and not stripped.startswith("#") and stripped.split(None, 1)[0] == key:
            if not replaced:
                out.append(new_line)
                replaced = True
            # Drop this and any later duplicates of the same option.
            continue
        out.append(line)

    if not replaced:
        out.append(new_line)

    content = "\n".join(out).rstrip("\n") + "\n"
    with open(path, "w", encoding="utf-8") as fh:
        fh.write(content)
    os.chmod(path, 0o600)

    print(f"{'updated' if replaced else 'added'}: {new_line}  ({path})")


if __name__ == "__main__":
    main()
