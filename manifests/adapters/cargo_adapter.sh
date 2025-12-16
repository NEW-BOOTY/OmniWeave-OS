#!/bin/bash
#
# Copyright © 2025 Devin B. Royal.
# All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0

#!/bin/bash
set -Eeuo pipefail

echo "Cargo adapter executing..."

if [[ -f "Cargo.toml" ]]; then
    cargo build --verbose
    echo "Cargo build complete"
else
    echo "No Cargo.toml – skipping cargo build"
fi
