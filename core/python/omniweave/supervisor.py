# Copyright © 2025 Devin B. Royal. All rights reserved.

import subprocess
import time
import signal
import sys

CHILDREN = {}

def spawn(name, cmd):
    p = subprocess.Popen(cmd)
    CHILDREN[name] = p
    return p

def health():
    return {
        name: ("running" if p.poll() is None else "stopped")
        for name, p in CHILDREN.items()
    }

def restart(name):
    p = CHILDREN.get(name)
    if p:
        p.terminate()
        p.wait()
    # Respawn logic handled by caller

def shutdown():
    for p in CHILDREN.values():
        p.terminate()
    sys.exit(0)

def supervise():
    while True:
        for name, p in list(CHILDREN.items()):
            if p.poll() is not None:
                spawn(name, p.args)
        time.sleep(2)
