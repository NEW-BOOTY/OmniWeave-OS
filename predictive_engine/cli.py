# Copyright © 2025, Devin B. Royal. All rights reserved.

import sys
from pathlib import Path

def main() -> int:
    root = Path(__file__).resolve().parents[1]
    cfg = root / "predictive_engine" / "predictive_config.yml"
    if not cfg.exists():
        print("[predictive] missing predictive_config.yml", file=sys.stderr)
        return 2
    print("[predictive] OK: config present:", cfg)
    # Future: load models in ml_models/ and run predictions
    return 0

if __name__ == "__main__":
    raise SystemExit(main())

# Copyright © 2025, Devin B. Royal. All rights reserved.