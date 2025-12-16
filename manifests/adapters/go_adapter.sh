#!/bin/bash
#
# Copyright © 2025 Devin B. Royal.
# All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0

#!/bin/bash
set -Eeuo pipefail

echo "Go adapter executing..."

if [[ -f "go.mod" ]]; then
    go build ./...
    echo "Go build complete"
else
    echo "No go.mod – skipping go build"
fi
