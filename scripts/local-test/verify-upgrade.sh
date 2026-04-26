#!/usr/bin/env bash
# Verify the package installs correctly over a system emacs.
#
# Usage: verify-upgrade.sh <distro>

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
    deb) INSTALL="apt-get update -qq && apt-get install -y"
         INSTALL_LOCAL="$INSTALL" ;;
    rpm) INSTALL="dnf install -y"
         INSTALL_LOCAL="dnf install -y --allowerasing" ;;
esac

PKG="$(ls "${PKGDIR}"/emacs-typas* 2>/dev/null | head -1)"
[[ -n "$PKG" ]] || { echo "no package found in ${PKGDIR}" >&2; exit 1; }

echo "==> [upgrade] $(basename "$PKG") on ${VERIFY_IMAGE} (over system emacs)"
podman run --rm \
    -e DEBIAN_FRONTEND=noninteractive \
    -v "${PKGDIR}:/pkg:ro,z" \
    "${VERIFY_IMAGE}" bash -c "
        set -euo pipefail
        ${INSTALL} emacs
        ${INSTALL_LOCAL} /pkg/$(basename "$PKG")
        emacs --version
    "
echo "==> [upgrade] PASS"
