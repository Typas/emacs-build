#!/usr/bin/env bash
# Dispatch to make-deb.sh or make-rpm.sh based on distro.
#
# Usage: make-native-package.sh <version> <distro> <arch>

set -euo pipefail

if [[ $# -ne 3 ]]; then
    echo "usage: $0 <version> <distro> <arch>" >&2
    exit 2
fi

VERSION="$1"
DISTRO="$2"
ARCH="$3"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

case "$DISTRO" in
    ubuntu|debian)
        bash "${SCRIPT_DIR}/make-deb.sh" "$VERSION" "$DISTRO" "$ARCH"
        ;;
    fedora-*)
        bash "${SCRIPT_DIR}/make-rpm.sh" "$VERSION" "$ARCH"
        ;;
    *)
        echo "unknown distro: $DISTRO" >&2
        exit 1
        ;;
esac
