#!/bin/bash
#
# Copyright © 2025 Devin B. Royal.
# All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0

#!/bin/bash
set -Eeuo pipefail

echo "Swift adapter executing..."

if [[ -f "Package.swift" ]]; then
    swift build
    echo "Swift build complete"
else
    echo "No Package.swift – skipping swift build"
fi
