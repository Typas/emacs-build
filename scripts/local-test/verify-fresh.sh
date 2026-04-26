#!/usr/bin/env bash
# Verify the package installs and runs on a clean system.
#
# Usage: verify-fresh.sh <distro>

set -euo pipefail

if [[ $# -ne 1 ]]; then
    echo "usage: $0 <distro>" >&2
    exit 2
fi

DISTRO="$1"
DIR="$(cd "$(dirname "$0")" && pwd)"
PKGDIR="/tmp/${DISTRO}"

# shellcheck source=distro-config.sh
source "${DIR}/distro-config.sh"
resolve_distro "$DISTRO"

case "$PKG_TYPE" in
    deb) INSTALL="apt-get update -qq && apt-get install -y" ;;
    rpm) INSTALL="dnf install -y" ;;
esac

PKG="$(ls "${PKGDIR}"/emacs-typas* 2>/dev/null | head -1)"
[[ -n "$PKG" ]] || { echo "no package found in ${PKGDIR}" >&2; exit 1; }

echo "==> [fresh] $(basename "$PKG") on ${VERIFY_IMAGE}"
podman run --rm \
    -e DEBIAN_FRONTEND=noninteractive \
    -v "${PKGDIR}:/pkg:ro,z" \
    "${VERIFY_IMAGE}" bash -c "
        set -euo pipefail
        ${INSTALL} /pkg/$(basename "$PKG")
        emacs --version
    "
echo "==> [fresh] PASS"
