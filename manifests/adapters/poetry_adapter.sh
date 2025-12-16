#!/bin/bash
#
# Copyright © 2025 Devin B. Royal.
# All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0

#!/bin/bash
set -Eeuo pipefail

echo "Poetry adapter executing..."

if [[ -f "pyproject.toml" ]] && grep -q "\[tool.poetry\]" pyproject.toml 2>/dev/null; then
    poetry build
    echo "Poetry build complete"
else
    echo "No Poetry project – skipping"
fi
