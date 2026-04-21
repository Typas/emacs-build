#!/usr/bin/env bash
# Download, verify, configure, build, and stage-install Emacs.
#
# Usage: build-emacs.sh <version> <variant> <march>
#   variant: nox | pgtk
#   march:   e.g. x86-64
#
# On success, the install tree lives at $PWD/emacs-<version>/ (prefix=/),
# ready for packaging.

set -euo pipefail

if [[ $# -ne 3 ]]; then
    echo "usage: $0 <version> <variant> <march>" >&2
    exit 2
fi

VERSION="$1"
VARIANT="$2"
MARCH="$3"

case "$VARIANT" in
    nox|pgtk) ;;
    *) echo "unknown variant: $VARIANT (want nox|pgtk)" >&2; exit 2 ;;
esac

TARBALL="emacs-${VERSION}.tar.xz"
MIRROR="https://ftp.gnu.org/gnu/emacs"
KEYRING_URL="https://ftp.gnu.org/gnu/gnu-keyring.gpg"

WORK="$(pwd)"
SRC="$WORK/src/emacs-${VERSION}"
OUTDIR="$WORK/emacs-${VERSION}"

echo "::group::Fetch sources"
curl -sSLfO "$MIRROR/$TARBALL"
curl -sSLfO "$MIRROR/$TARBALL.sig"
curl -sSLfO "$KEYRING_URL"
echo "::endgroup::"

echo "::group::Verify signature"
gpg --no-default-keyring --keyring ./gnu-keyring.gpg \
    --verify "$TARBALL.sig" "$TARBALL"
echo "::endgroup::"

echo "::group::Extract"
rm -rf "$SRC"
mkdir -p "$WORK/src"
tar -xf "$TARBALL" -C "$WORK/src"
echo "::endgroup::"

COMMON_FLAGS=(
    --prefix=/
    --with-native-compilation=yes
    --with-tree-sitter
    --with-modules
    --without-mailutils
    --with-gnutls
    --with-zlib
    --with-json
    --with-compress-install
)

NOX_FLAGS=(
    --without-x --without-pgtk --without-xwidgets
    --without-cairo --without-imagemagick --without-rsvg
    --without-sound --without-gpm
    --without-png --without-jpeg --without-gif --without-tiff --without-webp
)

PGTK_FLAGS=(
    --with-pgtk
    --with-cairo --with-harfbuzz --with-rsvg
    --with-sound=alsa
    --with-png --with-jpeg --with-gif --with-tiff --with-webp
    --without-xwidgets --without-imagemagick
)

if [[ "$VARIANT" == "nox" ]]; then
    VARIANT_FLAGS=("${NOX_FLAGS[@]}")
else
    VARIANT_FLAGS=("${PGTK_FLAGS[@]}")
fi

export CC=gcc-14
export CFLAGS="-O2 -flto=auto -march=${MARCH} -pipe"

echo "::group::Configure ($VARIANT)"
cd "$SRC"
./configure "${COMMON_FLAGS[@]}" "${VARIANT_FLAGS[@]}"
echo "::endgroup::"

echo "::group::Build"
make -j"$(nproc)"
echo "::endgroup::"

echo "::group::Install"
rm -rf "$OUTDIR"
make install DESTDIR="$OUTDIR"
echo "::endgroup::"

echo "::group::Smoke test"
EMACS="$OUTDIR/bin/emacs"
"$EMACS" --batch --eval '(princ (emacs-version))'
echo
"$EMACS" --batch --eval '(unless (featurep (quote native-compile)) (error "native-compile missing"))'
if [[ "$VARIANT" == "pgtk" ]]; then
    "$EMACS" --batch --eval '(unless (featurep (quote pgtk)) (error "pgtk missing"))'
fi
echo "::endgroup::"
