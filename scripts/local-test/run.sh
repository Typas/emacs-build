#!/usr/bin/env bash
# Run a full local build test inside podman.
#
# Usage: local-test/run.sh <version> <distro>
#   distro: ubuntu | debian | fedora-43

set -euo pipefail

if [[ $# -ne 2 ]]; then
    echo "usage: $0 <version> <distro>" >&2
    exit 2
fi

VERSION="$1"
DISTRO="$2"
SCRIPTS="$(cd "$(dirname "$0")/.." && pwd)"

case "$DISTRO" in
    ubuntu)   IMAGE="ubuntu:24.04" ;;
    debian)   IMAGE="debian:bookworm" ;;
    fedora-43) IMAGE="quay.io/fedora/fedora:43" ;;
    *)
        echo "unknown distro: $DISTRO (expected ubuntu|debian|fedora-43)" >&2
        exit 2
        ;;
esac

podman run --rm -it \
    -e DEBIAN_FRONTEND=noninteractive \
    -v "$SCRIPTS:/repo/scripts:ro,z" \
    "$IMAGE" bash -c "
        set -euo pipefail
        bash /repo/scripts/build/install-deps.sh &&
        mkdir -p /tmp/build && cd /tmp/build &&
        bash /repo/scripts/build/build-emacs.sh $VERSION x86-64 &&
        bash /repo/scripts/build/make-native-package.sh $VERSION $DISTRO amd64
    "
