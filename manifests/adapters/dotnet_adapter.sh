#!/bin/bash
#
# Copyright © 2025 Devin B. Royal.
# All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0

#!/bin/bash
set -Eeuo pipefail

echo ".NET adapter executing..."

if ls *.csproj >/dev/null 2>&1; then
    dotnet build --verbosity normal
    echo ".NET build complete"
else
    echo "No .csproj file – skipping dotnet build"
fi
