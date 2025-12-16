/*
 * Copyright © 2025 Devin B. Royal.
 * All Rights Reserved.
 */


#!/bin/bash
set -Eeuo pipefail

# Real build orchestration
echo "Initiating core build..."

if command -v go >/dev/null; then
  go build -o target/core-go ./modules/acm/src/go || exit 1
  echo "Go components built"
else
  echo "Go not found - skipping Go build"
fi

if command -v cargo >/dev/null; then
  cargo build --manifest-path ./polyglot_runtime/Cargo.toml || exit 1
  echo "Rust components built"
else
  echo "Cargo not found - skipping Rust build"
fi

if command -v python3 >/dev/null; then
  python3 -m compileall ./predictive_engine/engine.py || exit 1
  echo "Python components compiled"
else
  echo "Python not found - skipping Python compilation"
fi

echo "Core build complete"

# # FULLY INJECTED by omniweave_full_inject.sh v1.0.0 at 2025-12-16T02:23:30Z
