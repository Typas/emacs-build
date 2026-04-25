#!/usr/bin/env bash
# Upload a built tarball to an existing GitHub release.
#
# Usage: upload-release.sh <version> <distro> <arch> <variant>

set -euo pipefail

if [[ $# -ne 4 ]]; then
    echo "usage: $0 <version> <distro> <arch> <variant>" >&2
    exit 2
fi

VERSION="$1"
DISTRO="$2"
ARCH="$3"
VARIANT="$4"

gh release upload "emacs-$VERSION" \
    "./emacs-${VERSION}-${DISTRO}-${ARCH}-${VARIANT}.tar.zst"
