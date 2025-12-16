# Copyright © 2025 Devin B. Royal. All rights reserved.

import time
import json
from pathlib import Path
from datetime import datetime, timezone

ROOT = Path(__file__).resolve().parents[1]
LOG = ROOT / "logs" / "predictive.log"
PROVENANCE = ROOT / "provenance.log.jsonl"

def ts():
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")

def log(event, severity="INFO"):
    entry = {
        "ts": ts(),
        "component": "predictive_engine",
        "severity": severity,
        "event": event
    }
    LOG.parent.mkdir(exist_ok=True)
    with LOG.open("a") as f:
        f.write(json.dumps(entry) + "\n")

def analyze():
    # Simple baseline: heartbeat cadence monitoring
    if not PROVENANCE.exists():
        return

    lines = PROVENANCE.read_text().strip().splitlines()
    heartbeats = [json.loads(l) for l in lines if "heartbeat" in l.get("event", "")]

    if len(heartbeats) < 3:
        return

    last = heartbeats[-1]
    prev = heartbeats[-2]

    # If heartbeat delay exceeds threshold, flag risk
    t1 = datetime.fromisoformat(prev["ts"].replace("Z", "+00:00"))
    t2 = datetime.fromisoformat(last["ts"].replace("Z", "+00:00"))
    delta = (t2 - t1).total_seconds()

    if delta > 8:
        log(f"Heartbeat delay anomaly detected: {delta}s", severity="WARN")

def run():
    log("Predictive engine activated")
    while True:
        analyze()
        time.sleep(5)

if __name__ == "__main__":
    run()