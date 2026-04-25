#!/usr/bin/env bash
# Download, verify, configure, build, and stage-install Emacs (pgtk variant).
#
# Usage: build-emacs.sh <version> <march>
#   march: e.g. x86-64
#
# On success, the install tree lives at $PWD/emacs-<version>/ (prefix=/),
# ready for packaging.

set -euo pipefail

if [[ $# -ne 2 ]]; then
    echo "usage: $0 <version> <march>" >&2
    exit 2
fi

VERSION="$1"
MARCH="$2"

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

FLAGS=(
    --prefix=/usr/local
    --disable-build-details
    --with-native-compilation=yes
    --with-tree-sitter
    --with-small-ja-dic
    --without-included-regex
    --with-pgtk
    --with-cairo
    --with-sound=alsa
)

export CC="${CC:-gcc}"
export CFLAGS="-O2 -flto=auto -fno-semantic-interposition -march=${MARCH} -pipe"

echo "::group::Configure"
cd "$SRC"
./configure "${FLAGS[@]}"
echo "::endgroup::"

echo "::group::Build"
make -j"$(nproc)"
echo "::endgroup::"

echo "::group::Install"
rm -rf "$OUTDIR"
make install DESTDIR="$OUTDIR"
echo "::endgroup::"

echo "::group::Smoke test"
EMACS="$OUTDIR/usr/local/bin/emacs"
export EMACSLOADPATH="$OUTDIR/usr/local/share/emacs/${VERSION}/lisp"
"$EMACS" --batch --eval '(princ (emacs-version))'
echo
"$EMACS" --batch --eval '(unless (featurep (quote native-compile)) (error "native-compile missing"))'
"$EMACS" --batch --eval '(unless (featurep (quote pgtk)) (error "pgtk missing"))'
echo "::endgroup::"
