#!/usr/bin/env bash
# Resolve the latest upstream Emacs version and set GitHub Actions outputs.
# Outputs: version, should_build

set -euo pipefail

version=$(bash scripts/check/latest-upstream.sh)
echo "Upstream latest: $version"
echo "version=$version" >> "$GITHUB_OUTPUT"

if [[ "${FORCE:-false}" == "true" ]]; then
    echo "force=true; building regardless"
    echo "should_build=true" >> "$GITHUB_OUTPUT"
    exit 0
fi

if draft=$(gh release view "emacs-$version" --repo "$GITHUB_REPOSITORY" --json isDraft --jq '.isDraft' 2>/dev/null); then
    if [[ "$draft" == "true" ]]; then
        echo "release emacs-$version is a draft; deleting and rebuilding"
        gh release delete "emacs-$version" --repo "$GITHUB_REPOSITORY" --yes
        echo "should_build=true" >> "$GITHUB_OUTPUT"
    else
        echo "release emacs-$version already published; skipping"
        echo "should_build=false" >> "$GITHUB_OUTPUT"
    fi
else
    echo "no release for emacs-$version yet; will build"
    echo "should_build=true" >> "$GITHUB_OUTPUT"
fi
