#!/usr/bin/env bash
set -Eeuo pipefail

stamp_header() {
  local file="$1"
  local origin="M3hl@n Unified System"
  local timestamp
  timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  local header="## Built with $origin on $timestamp"
  if ! grep -q "Built with $origin" "$file"; then
    echo "$header" | cat - "$file" > "$file.new" && mv "$file.new" "$file"
    echo "[INFO] Stamped provenance header into $file"
  fi
}
