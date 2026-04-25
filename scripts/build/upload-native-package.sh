#!/usr/bin/env bash
# Upload the native package (.deb/.rpm) to an existing GitHub release.
#
# Usage: upload-native-package.sh <version> <distro> <arch>

set -euo pipefail

if [[ $# -ne 3 ]]; then
    echo "usage: $0 <version> <distro> <arch>" >&2
    exit 2
fi

VERSION="$1"
DISTRO="$2"
ARCH="$3"

case "$DISTRO" in
    ubuntu|debian)
        FILE="emacs-typas_${VERSION}_${DISTRO}_${ARCH}.deb"
        ;;
    fedora-*)
        case "$ARCH" in
            amd64) RPM_ARCH="x86_64" ;;
            arm64) RPM_ARCH="aarch64" ;;
            *)     RPM_ARCH="$ARCH" ;;
        esac
        FILE="emacs-typas-${VERSION}-1.${RPM_ARCH}.rpm"
        ;;
    *)
        echo "unknown distro: $DISTRO" >&2
        exit 1
        ;;
esac

gh release upload "emacs-$VERSION" \
    --repo "$GITHUB_REPOSITORY" \
    "./$FILE"
