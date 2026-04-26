#!/usr/bin/env bash
# Build Emacs inside podman and place the package in /tmp/<distro>/.
#
# Usage: local-test/run.sh <version> <distro>

set -euo pipefail

if [[ $# -ne 2 ]]; then
    echo "usage: $0 <version> <distro>" >&2
    exit 2
fi

VERSION="$1"
DISTRO="$2"
ARCH="amd64"
DIR="$(cd "$(dirname "$0")" && pwd)"
SCRIPTS="$(cd "${DIR}/.." && pwd)"
OUTDIR="/tmp/${DISTRO}"

# shellcheck source=distro-config.sh
source "${DIR}/distro-config.sh"
resolve_distro "$DISTRO"

echo "==> Clearing ${OUTDIR}"
rm -rf "${OUTDIR}"
mkdir -p "${OUTDIR}"

echo "==> Building on ${BUILD_IMAGE} (distro label: ${BUILD_DISTRO})"
podman run --rm -it \
    -e DEBIAN_FRONTEND=noninteractive \
    -v "${SCRIPTS}:/repo/scripts:ro,z" \
    -v "${OUTDIR}:/out:z" \
    "${BUILD_IMAGE}" bash -c "
        set -euo pipefail
        bash /repo/scripts/build/install-deps.sh &&
        mkdir -p /tmp/build && cd /tmp/build &&
        bash /repo/scripts/build/build-emacs.sh ${VERSION} x86-64 &&
        bash /repo/scripts/build/make-native-package.sh ${VERSION} ${BUILD_DISTRO} ${ARCH} &&
        cp emacs-typas_* emacs-typas-* /out/ 2>/dev/null || true
    "
echo "==> Package in ${OUTDIR}:"
ls "${OUTDIR}/"
