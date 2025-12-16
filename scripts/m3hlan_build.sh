#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_DIR="${1:-.}"
BUILD_SYSTEM="${M3HLAN_PATH:-/Users/cr/M3hl@n_Unified_System}"

echo "[INFO] Using M3hl@n Unified System at \$BUILD_SYSTEM to build \$PROJECT_DIR"

if [[ ! -x "\$BUILD_SYSTEM/m3hlan" ]]; then
  echo "[WARN] M3hl@n build binary not found at \$BUILD_SYSTEM/m3hlan"
  exit 1
fi

"\$BUILD_SYSTEM/m3hlan" build "\$PROJECT_DIR" || {
  echo "[ERROR] Build failed via M3hl@n Unified System"
  exit 1
}

echo "GOT UM."
