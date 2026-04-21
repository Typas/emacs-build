# emacs-build

Automated builds of stable GNU Emacs for Linux amd64, published to this repo's
[Releases](../../releases).

A daily GitHub Actions workflow checks `ftp.gnu.org` for a new stable Emacs
tarball and, if one exists, builds two variants and uploads them as a release.

## Variants

| Variant | Use case | UI | Extras |
|---------|----------|----|--------|
| `nox`   | Servers, TTY, `emacs -nw` on remote shells | terminal only | no image libs, no sound, no GUI |
| `pgtk`  | Desktop (Wayland / X11 via GTK) | GTK 3 | Cairo, HarfBuzz, librsvg, ALSA, png/jpeg/gif/tiff/webp |

Both variants include: native-comp (JIT), tree-sitter, dynamic modules, GnuTLS,
JSON, zlib.

## Install

Download the asset for your variant from the latest release, e.g.:

```sh
curl -LO https://github.com/<you>/emacs-build/releases/latest/download/emacs-30.2-linux-amd64-pgtk.tar.zst
tar -xf emacs-30.2-linux-amd64-pgtk.tar.zst -C ~/.local/share/
~/.local/share/emacs-30.2/bin/emacs
```

The archive contains one top-level directory `emacs-<version>/` with the
standard `bin/ lib/ libexec/ share/ include/` layout. It is relocatable — put
it anywhere and run `<extracted>/bin/emacs`.

Add to PATH:
```sh
export PATH="$HOME/.local/share/emacs-30.2/bin:$PATH"
```

## Runtime dependencies

Native-comp (both variants) calls out to `gcc` and needs `libgccjit.so.0` at
runtime:

| Distro        | package |
|---------------|---------|
| Ubuntu/Debian | `libgccjit0 gcc` |
| Fedora        | `libgccjit gcc` |
| Arch/CachyOS  | `gcc` (includes libgccjit) |

`pgtk` additionally needs:

| Distro        | packages |
|---------------|----------|
| Ubuntu/Debian | `libgtk-3-0 libcairo2 libharfbuzz0b librsvg2-2 libasound2 libpng16-16 libjpeg-turbo8 libgif7 libtiff6 libwebp7` |
| Fedora        | `gtk3 cairo harfbuzz librsvg2 alsa-lib libpng libjpeg-turbo giflib libtiff libwebp` |
| Arch/CachyOS  | `gtk3 cairo harfbuzz librsvg alsa-lib libpng libjpeg-turbo giflib libtiff libwebp` |

## First launch

Native-compiled `.eln` files are NOT shipped (AOT paths don't survive
relocation). Emacs JIT-compiles on demand and caches under
`~/.cache/emacs/eln-cache/`. The first launches will be slower as packages get
compiled; subsequent launches are fast.

## Build target

Built on Ubuntu 24.04 (glibc 2.39) with GCC 14, `-O2 -flto=auto -march=x86-64`.
Portable to modern Linux distros with glibc ≥ 2.39 (Ubuntu 24.04+, Debian 13+,
Fedora 43+, Arch/CachyOS).

## Manual trigger

- `check` workflow: runs daily at 06:00 UTC; can be dispatched with
  `force: true` to rebuild the current upstream version even if it was already
  released.
- `build` workflow: can be dispatched directly with a `version` input to
  rebuild any specific version.
