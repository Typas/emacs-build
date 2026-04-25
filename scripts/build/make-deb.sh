#!/usr/bin/env bash
# Build a .deb package from the staged Emacs install tree.
#
# Usage: make-deb.sh <version> <distro> <arch>

set -euo pipefail

if [[ $# -ne 3 ]]; then
    echo "usage: $0 <version> <distro> <arch>" >&2
    exit 2
fi

VERSION="$1"
DISTRO="$2"
ARCH="$3"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
STAGEDIR="emacs-${VERSION}"

mkdir -p "${STAGEDIR}/DEBIAN"
sed -e "s/@@VERSION@@/${VERSION}/" \
    -e "s/@@ARCH@@/${ARCH}/" \
    "${SCRIPT_DIR}/deb/control.${DISTRO}" > "${STAGEDIR}/DEBIAN/control"

OUT="emacs-typas_${VERSION}_${DISTRO}_${ARCH}.deb"
dpkg-deb --build --root-owner-group "${STAGEDIR}" "$OUT"
echo "wrote $OUT ($(stat -c %s "$OUT") bytes)"
