#!/usr/bin/env bash
# Build an .rpm package from the staged Emacs install tree.
#
# Usage: make-rpm.sh <version> <arch>

set -euo pipefail

if [[ $# -ne 2 ]]; then
    echo "usage: $0 <version> <arch>" >&2
    exit 2
fi

VERSION="$1"
ARCH="$2"

case "$ARCH" in
    amd64) RPM_ARCH="x86_64" ;;
    arm64) RPM_ARCH="aarch64" ;;
    *)     RPM_ARCH="$ARCH" ;;
esac

STAGEDIR="$(pwd)/emacs-${VERSION}"
RPMROOT="$(pwd)/rpmbuild"

mkdir -p "${RPMROOT}"/{BUILD,RPMS,SOURCES,SPECS,SRPMS}

cat > "${RPMROOT}/SPECS/emacs-typas.spec" <<EOF
Name:           emacs-typas
Version:        ${VERSION}
Release:        1
Summary:        GNU Emacs pgtk build with native compilation
License:        GPL-3.0+
BuildArch:      ${RPM_ARCH}
Requires:       gtk3, cairo, gnutls, harfbuzz, librsvg2, alsa-lib, jansson, libtree-sitter, libgccjit
Conflicts:      emacs
Provides:       emacs
%define _binary_payload w19.zstdio
%define __brp_compress %{nil}

%description
Custom build by Typas Liao with pgtk, tree-sitter, and native compilation.

%install
cp -a %{stagedir}/. %{buildroot}/
find %{buildroot} -not -type d | sed "s|%{buildroot}||" | sort > %{_topdir}/BUILD/files.list

%files -f %{_topdir}/BUILD/files.list

%changelog
EOF

OUT="emacs-typas-${VERSION}-1.${RPM_ARCH}.rpm"
ZSTD_NBTHREADS=0 rpmbuild --define "_topdir ${RPMROOT}" \
         --define "_rpmdir $(pwd)" \
         --define "stagedir ${STAGEDIR}" \
         -bb "${RPMROOT}/SPECS/emacs-typas.spec"
mv "${RPM_ARCH}/emacs-typas-${VERSION}-1.${RPM_ARCH}.rpm" "$OUT" 2>/dev/null || \
    find "${RPMROOT}/RPMS" -name "*.rpm" -exec cp {} "$OUT" \;
echo "wrote $OUT ($(stat -c %s "$OUT") bytes)"
