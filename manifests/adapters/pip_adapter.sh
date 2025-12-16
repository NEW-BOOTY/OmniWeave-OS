#!/bin/bash
#
# Copyright © 2025 Devin B. Royal.
# All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0

#!/bin/bash
set -Eeuo pipefail

echo "pip adapter executing..."

if [[ -f "requirements.txt" || -f "setup.py" ]]; then
    pip install -r requirements.txt 2>/dev/null || true
    echo "pip dependencies installed"
else
    echo "No Python project files – skipping"
fi
