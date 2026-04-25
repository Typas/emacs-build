#!/usr/bin/env bash
# Install Emacs build dependencies for the current distro.

set -euo pipefail

SUDO=()
[ "$(id -u)" -ne 0 ] && SUDO=(sudo)

if command -v apt-get >/dev/null 2>&1; then
    [ "${APT_UPDATED:-}" != "1" ] && "${SUDO[@]}" apt-get update
    gcc_ver=$(apt-cache depends gcc | awk '/Depends: gcc-/{print $2}' | grep -oP '[0-9]+')
    "${SUDO[@]}" apt-get install -y --no-install-recommends \
        gcc g++ "libgccjit-${gcc_ver}-dev" \
        make autoconf pkg-config texinfo \
        libgnutls28-dev libjansson-dev libtree-sitter-dev \
        libncurses-dev zlib1g-dev zstd \
        libgtk-3-dev libcairo2-dev libharfbuzz-dev librsvg2-dev libasound2-dev \
        libpng-dev libjpeg-dev libgif-dev libtiff-dev libwebp-dev \
        libwebkit2gtk-4.1-dev
elif command -v dnf >/dev/null 2>&1; then
    "${SUDO[@]}" dnf install -y \
        gcc gcc-c++ libgccjit-devel \
        make autoconf pkgconf-pkg-config texinfo \
        gnutls-devel jansson-devel libtree-sitter-devel \
        ncurses-devel zlib-devel zstd \
        gtk3-devel cairo-devel harfbuzz-devel librsvg2-devel alsa-lib-devel \
        libpng-devel libjpeg-turbo-devel giflib-devel libtiff-devel libwebp-devel \
        webkit2gtk4.1-devel
else
    echo "no supported package manager found (apt-get/dnf)" >&2
    exit 1
fi
