#!/usr/bin/env bash
# Print the latest stable Emacs version from ftp.gnu.org.
# Exits non-zero if nothing could be parsed.

set -euo pipefail

INDEX_URL="https://ftp.gnu.org/gnu/emacs/"

version=$(
    curl -sSLf "$INDEX_URL" \
        | grep -oE 'emacs-[0-9]+\.[0-9]+(\.[0-9]+)?\.tar\.xz"' \
        | grep -v -- '-rc' \
        | sed -E 's/^emacs-([0-9.]+)\.tar\.xz"$/\1/' \
        | sort -V -u \
        | tail -n1
)

if [[ -z "$version" ]]; then
    echo "failed to parse any Emacs version from $INDEX_URL" >&2
    exit 1
fi

echo "$version"
