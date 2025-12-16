#!/bin/bash
#
# Copyright © 2025 Devin B. Royal.
# All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0

#!/bin/bash
set -Eeuo pipefail

echo "Maven adapter executing..."

if [[ -f "pom.xml" ]]; then
    mvn compile -q
    echo "Maven compile complete"
else
    echo "No pom.xml – skipping maven build"
fi
