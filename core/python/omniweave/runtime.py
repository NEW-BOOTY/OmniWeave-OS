# Copyright © 2025, Devin B. Royal. All rights reserved.

import os
import sys
import json
import time
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]  # .../core/python/omniweave/runtime.py -> repo root
RUN_DIR = ROOT / ".omniweave" / "run"
LOG_DIR = ROOT / "logs"

def _ts() -> str:
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")

def _log(level: str, msg: str) -> None:
    line = f"[{_ts()}] [{level}] {msg}"
    print(line, flush=True)

def _write_jsonl(path: Path, obj: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("a", encoding="utf-8") as f:
        f.write(json.dumps(obj, sort_keys=True) + "\n")

def main() -> int:
    try:
        RUN_DIR.mkdir(parents=True, exist_ok=True)
        LOG_DIR.mkdir(parents=True, exist_ok=True)

        mode = sys.argv[1] if len(sys.argv) > 1 else "status"
        _log("INFO", f"OmniWeave Python runtime online (mode={mode})")

        audit = {
            "ts": _ts(),
            "event": "runtime_start",
            "mode": mode,
            "pid": os.getpid(),
        }
        _write_jsonl(ROOT / "provenance.log.jsonl", audit)

        if mode == "status":
            _log("INFO", "OK: runtime reachable")
            return 0

        if mode == "demo":
            _log("INFO", "Demo: sleeping 2s then exiting clean.")
            time.sleep(2)
            _write_jsonl(ROOT / "provenance.log.jsonl", {"ts": _ts(), "event": "runtime_demo_exit"})
            return 0

        if mode == "run":
            _log("INFO", "Run: entering supervised loop (Ctrl+C to stop).")
            while True:
                time.sleep(5)
                _write_jsonl(ROOT / "provenance.log.jsonl", {"ts": _ts(), "event": "heartbeat", "pid": os.getpid()})
                _log("INFO", "heartbeat")
        _log("WARN", "Unreachable")
        return 0

    except KeyboardInterrupt:
        _log("INFO", "Shutdown requested.")
        _write_jsonl(ROOT / "provenance.log.jsonl", {"ts": _ts(), "event": "runtime_stop"})
        return 0
    except Exception as e:
        _log("ERROR", f"Fatal: {e}")
        return 1

# Copyright © 2025, Devin B. Royal. All rights reserved.