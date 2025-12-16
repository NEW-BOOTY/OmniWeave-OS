#!/usr/bin/env bash
# Copyright © 2025, Devin B. Royal. All rights reserved.

set -Eeuo pipefail
IFS=$'\n\t'

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VENV="${ROOT}/.omniweave/venv"

python3 -m venv "${VENV}"
# shellcheck disable=SC1090
source "${VENV}/bin/activate"

python -m pip install --upgrade pip >/dev/null
if [[ -f "${ROOT}/requirements.txt" ]]; then
  python -m pip install -r "${ROOT}/requirements.txt" >/dev/null
fi

echo "[venv] ready: ${VENV}"

# Copyright © 2025, Devin B. Royal. All rights reserved.