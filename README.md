# emacs-build

Automated builds of stable GNU Emacs (pgtk variant) for Linux amd64, published
to this repo's [Releases](../../releases).

A daily GitHub Actions workflow checks `ftp.gnu.org` for a new stable Emacs
tarball and, if one exists, builds it on three distros and uploads the results
as a release.

## What is built

**pgtk** — GTK 3, Wayland / X11, Cairo, HarfBuzz, librsvg, ALSA,
png/jpeg/gif/tiff/webp. Includes: native-comp (JIT), tree-sitter, dynamic
modules, GnuTLS, JSON, zlib.

Each distro produces two assets:
- a relocatable `.tar.zst` tarball
- a native `.deb` or `.rpm` package (`emacs-typas`, conflicts with / provides `emacs`)

## Install

### Tarball (any distro)

Pick the tarball that matches your distro:

| Distro | Asset |
|--------|-------|
| Ubuntu 24.04+ | `emacs-<version>-ubuntu-amd64-pgtk.tar.zst` |
| Debian bookworm | `emacs-<version>-debian-amd64-pgtk.tar.zst` |
| Fedora 43+ | `emacs-<version>-fedora-43-amd64-pgtk.tar.zst` |

```sh
curl -LO https://github.com/<you>/emacs-build/releases/latest/download/emacs-30.2-ubuntu-amd64-pgtk.tar.zst
tar -xf emacs-30.2-ubuntu-amd64-pgtk.tar.zst -C ~/.local/share/
~/.local/share/emacs-30.2/bin/emacs
```

The archive unpacks to `emacs-<version>/` with the standard
`bin/ lib/ libexec/ share/ include/` layout. Relocatable — put it anywhere and
run `<extracted>/bin/emacs`.

Add to PATH:
```sh
export PATH="$HOME/.local/share/emacs-30.2/bin:$PATH"
```

### Native package (.deb / .rpm)

**Ubuntu / Debian:**
```sh
sudo apt install ./emacs-typas_30.2_ubuntu_amd64.deb   # or _debian_
```

**Fedora:**
```sh
sudo dnf install ./emacs-typas-30.2-1.x86_64.rpm
```

The native package pulls in all runtime dependencies automatically.

## Runtime dependencies (tarball only)

Native-comp calls out to `gcc` and needs `libgccjit.so.0`:

| Distro | package |
|--------|---------|
| Ubuntu 24.04+ | `libgccjit0 gcc` |
| Debian bookworm | `libgccjit0 gcc` |
| Fedora | `libgccjit gcc` |

pgtk additionally needs:

| Distro | packages |
|--------|----------|
| Ubuntu 24.04+ | `libgtk-3-0t64 libcairo2 libharfbuzz0b librsvg2-2 libasound2t64 libpng16-16t64 libjpeg-turbo8 libgif7 libtiff6 libwebp7 libwebpdecoder3 libwebpdemux2` |
| Debian bookworm | `libgtk-3-0t64 libcairo2 libharfbuzz0b librsvg2-2 libasound2t64 libpng16-16t64 libjpeg62-turbo libgif7 libtiff6 libwebp7 libwebpdecoder3 libwebpdemux2` |
| Fedora | `gtk3 cairo harfbuzz librsvg2 alsa-lib libpng libjpeg-turbo giflib libtiff libwebp` |

## First launch

Native-compiled `.eln` files are NOT shipped (AOT paths don't survive
relocation). Emacs JIT-compiles on demand and caches under
`~/.cache/emacs/eln-cache/`. First launches are slower as packages compile;
subsequent launches are fast.

## Build targets

| Distro | Runner | glibc |
|--------|--------|-------|
| Ubuntu 24.04 | `ubuntu-24.04` | 2.39 |
| Debian bookworm | `ubuntu-24.04` + container | 2.36 |
| Fedora 43 | `ubuntu-24.04` + container | — |

All builds: GCC (distro default), `-O2 -flto=auto -march=x86-64`.

## Manual trigger

- `check` workflow: runs daily at 07:23 UTC; can be dispatched to rebuild the
  current upstream version.
- `build` workflow: can be dispatched directly with a `version` input to
  rebuild any specific version.
