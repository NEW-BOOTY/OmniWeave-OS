#!/bin/bash
#
# Copyright © 2025 Devin B. Royal.
# All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0

#!/bin/bash
set -Eeuo pipefail

echo "CMake adapter executing..."

if [[ -f "CMakeLists.txt" ]]; then
    mkdir -p build && cd build
    cmake .. && cmake --build .
    echo "CMake build complete"
else
    echo "No CMakeLists.txt – skipping cmake build"
fi
