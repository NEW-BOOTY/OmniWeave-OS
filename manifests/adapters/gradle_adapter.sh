#!/bin/bash
#
# Copyright © 2025 Devin B. Royal.
# All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0

#!/bin/bash
set -Eeuo pipefail

echo "Gradle adapter executing..."

if [[ -f "build.gradle" || -f "build.gradle.kts" ]]; then
    if [[ -x "./gradlew" ]]; then
        ./gradlew build --info
    else
        gradle build --info
    fi
    echo "Gradle build complete"
else
    echo "No Gradle build file – skipping"
fi
