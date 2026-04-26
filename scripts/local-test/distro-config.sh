#!/usr/bin/env bash
# Resolve distro parameters.  Source this file, then call: resolve_distro "$DISTRO"
# Sets: BUILD_IMAGE, BUILD_DISTRO, VERIFY_IMAGE, PKG_TYPE

BUILD_UBUNTU_IMAGE="ubuntu:24.04"
BUILD_DEBIAN_IMAGE="debian:trixie"
BUILD_FEDORA_IMAGE="quay.io/fedora/fedora:43"

resolve_distro() {
    local distro="$1"
    case "$distro" in
        ubuntu|ubuntu-noble)
            BUILD_IMAGE="$BUILD_UBUNTU_IMAGE"
            BUILD_DISTRO="ubuntu"
            VERIFY_IMAGE="ubuntu:24.04"
            PKG_TYPE="deb" ;;
        ubuntu-resolute)
            BUILD_IMAGE="$BUILD_UBUNTU_IMAGE"
            BUILD_DISTRO="ubuntu"
            VERIFY_IMAGE="ubuntu:26.04"
            PKG_TYPE="deb" ;;
        debian|debian-trixie)
            BUILD_IMAGE="$BUILD_DEBIAN_IMAGE"
            BUILD_DISTRO="debian"
            VERIFY_IMAGE="debian:trixie"
            PKG_TYPE="deb" ;;
        fedora|fedora-43)
            BUILD_IMAGE="$BUILD_FEDORA_IMAGE"
            BUILD_DISTRO="fedora-43"
            VERIFY_IMAGE="quay.io/fedora/fedora:43"
            PKG_TYPE="rpm" ;;
        fedora-44)
            BUILD_IMAGE="$BUILD_FEDORA_IMAGE"
            BUILD_DISTRO="fedora-43"
            VERIFY_IMAGE="quay.io/fedora/fedora:44"
            PKG_TYPE="rpm" ;;
        *)
            echo "unknown distro: $distro" >&2
            return 1 ;;
    esac
}
