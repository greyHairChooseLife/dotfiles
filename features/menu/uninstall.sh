#!/bin/bash
# Removes the links this feature created.
set -euo pipefail

DIR="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
# shellcheck source=../_lib.sh
. "$DIR/../_lib.sh"

unlink_bin "$DIR"
