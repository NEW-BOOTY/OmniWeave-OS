#!/bin/bash
#
# Copyright © 2025 Devin B. Royal.
# All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0

#!/bin/bash
set -Eeuo pipefail

echo "npm adapter executing..."

if [[ -f "package.json" ]]; then
    npm install && (npm run build || true)
    echo "npm build complete"
else
    echo "No package.json – skipping npm build"
fi
