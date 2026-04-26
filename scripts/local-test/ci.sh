#!/usr/bin/env bash
# Build + verify package dependencies (fresh and upgrade scenarios in parallel).
#
# Usage: ci.sh <version> <distro>
#   distro: ubuntu | debian | fedora-43

set -euo pipefail

if [[ $# -ne 2 ]]; then
    echo "usage: $0 <version> <distro>" >&2
    exit 2
fi

DIR="$(cd "$(dirname "$0")" && pwd)"

bash "${DIR}/run.sh" "$1" "$2"

bash "${DIR}/verify-fresh.sh"   "$2" &
bash "${DIR}/verify-upgrade.sh" "$2" &
wait
