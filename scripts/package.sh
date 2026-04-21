#!/usr/bin/env bash
# Package the built Emacs tree as a zstd-compressed tarball.
#
# Usage: package.sh <version> <os> <arch> <variant>
# Input:  $PWD/emacs-<version>/ (produced by build-emacs.sh)
# Output: $PWD/emacs-<version>-<os>-<arch>-<variant>.tar.zst

set -euo pipefail

if [[ $# -ne 4 ]]; then
    echo "usage: $0 <version> <os> <arch> <variant>" >&2
    exit 2
fi

VERSION="$1"
OS="$2"
ARCH="$3"
VARIANT="$4"

TOPDIR="emacs-${VERSION}"
if [[ ! -d "$TOPDIR" ]]; then
    echo "input dir not found: $PWD/$TOPDIR" >&2
    exit 1
fi

OUT="emacs-${VERSION}-${OS}-${ARCH}-${VARIANT}.tar.zst"
tar -I 'zstd -3 -T0' -cf "$OUT" "$TOPDIR"
echo "wrote $OUT ($(stat -c %s "$OUT") bytes)"
