#!/bin/bash
#
# Copyright © 2025 Devin B. Royal.
# All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0

#!/bin/bash
set -Eeuo pipefail

echo "Yarn adapter executing..."

if [[ -f "package.json" ]] && [[ -f "yarn.lock" ]]; then
    yarn install && (yarn build || true)
    echo "Yarn build complete"
else
    echo "No Yarn project – skipping"
fi
