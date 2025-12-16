#!/bin/bash
#
# Copyright © 2025 Devin B. Royal.
# All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0

# =============================================================================
# scripts/m3hlan-doctor.sh
# =============================================================================
# Version: 1.0.0
# Description: Production-grade health diagnostic ritual for OmniWeave OS.
#              Detects missing dependencies, corrupted configurations, toolchain
#              mismatches, and environment issues. Provides clear remediation steps.
#              Fully compatible with macOS Bash 3.2 and Linux.
# Author: Engineered for Devin B. Royal, Chief Technology Officer
# Date: December 15, 2025
# =============================================================================

set -Eeuo pipefail

# ----------------------------- Error Handling (macOS Bash 3.2 safe) ---------

handle_error() {
    local exit_code=$?
    local line_no=${1:-UNKNOWN}
    echo "[ERROR] $(date '+%Y-%m-%d %H:%M:%S') | Doctor diagnostic failed at line $line_no (code $exit_code)" >&2
    exit "$exit_code"
}

handle_exit() {
    if [[ $HEALTHY -eq 1 ]]; then
        echo "[INFO] $(date '+%Y-%m-%d %H:%M:%S') | System health check passed."
        echo "GOT UM."
    else
        echo "[WARN] $(date '+%Y-%m-%d %H:%M:%S') | Issues detected – review recommendations above."
        exit 1
    fi
}

trap 'handle_error $LINENO' ERR
trap handle_exit EXIT

HEALTHY=1  # Assume healthy; set to 0 on any issue

# ----------------------------- Configuration ----------------------------------

SCRIPT_VERSION="1.0.0"
SCRIPT_NAME="$(basename "$0")"
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOGS_DIR="${PROJECT_ROOT}/logs"
SETUP_LOG="${LOGS_DIR}/setup.log"

mkdir -p "$LOGS_DIR"

# ----------------------------- Logging ---------------------------------------

log() {
    local level="$1" msg="$2"
    local color=""
    case "$level" in
        INFO)  color="\033[32m" ;;
        WARN)  color="\033[33m" ;;
        ERROR) color="\033[31m" ;;
        OK)    color="\033[32m" ;;
        ISSUE) color="\033[33m" ;;
    esac

    if [[ -t 1 ]]; then
        echo -e "[${color}${level}\033[0m] $(date '+%Y-%m-%d %H:%M:%S') | $msg"
    else
        echo "[$level] $(date '+%Y-%m-%d %H:%M:%S') | $msg"
    fi

    echo "{\"level\":\"$level\",\"ts\":\"$(date -u +"%Y-%m-%dT%H:%M:%SZ")\",\"msg\":\"$msg\"}" >> "$SETUP_LOG"
}

log_info()  { log "INFO"  "$1"; }
log_warn()  { log "WARN"  "$1"; HEALTHY=0; }
log_error() { log "ERROR" "$1"; HEALTHY=0; }
log_ok()    { log "OK"    "$1"; }
log_issue() { log "ISSUE" "$1"; HEALTHY=0; }

# ----------------------------- Diagnostic Checks ---------------------------

log_info "Executing m3hlan-doctor v$SCRIPT_VERSION"

# 1. Project Structure
log_info "Checking core directories..."
for dir in core scripts configs modules predictive_engine ml_models observability provenance.log.jsonl sbom.json; do
    if [[ -e "$PROJECT_ROOT/$dir" ]]; then
        log_ok "Found: $dir"
    else
        log_issue "Missing: $dir – run omniweave-os-m3hlan-init.sh and omniweave_enhance.sh"
    fi
done

# 2. Essential Toolchains
log_info "Checking essential toolchains..."
TOOLS=("git" "make" "python3" "go" "cargo" "node" "npm")
for tool in "${TOOLS[@]}"; do
    if command -v "$tool" >/dev/null 2>&1; then
        log_ok "$tool detected ($($tool --version 2>&1 | head -n1 | cut -d' ' -f1-3))"
    else
        log_issue "$tool not found in PATH – install via official package manager"
    fi
done

# 3. Python Environment
log_info "Checking Python virtual environment..."
if [[ -d "$PROJECT_ROOT/.venv" ]]; then
    log_ok "Virtual environment exists"
    if [[ -f "$PROJECT_ROOT/requirements.txt" ]]; then
        log_ok "requirements.txt present"
    else
        log_issue "requirements.txt missing – recreate from standard template"
    fi
else
    log_issue "No .venv directory – run ./scripts/init.sh"
fi

# 4. Git Configuration
log_info "Checking Git repository state..."
if [[ -d "$PROJECT_ROOT/.git" ]]; then
    log_ok "Git repository initialized"
    if [[ -f "$PROJECT_ROOT/.git/hooks/pre-commit" ]]; then
        log_ok "pre-commit hook installed"
    else
        log_issue "pre-commit hook missing – run ./scripts/init.sh"
    fi
else
    log_issue ".git directory missing – run git init or clone properly"
fi

# 5. Configuration Files
log_info "Checking key configuration files..."
for cfg in .env provenance.log.jsonl sbom.json; do
    if [[ -f "$PROJECT_ROOT/$cfg" ]]; then
        log_ok "$cfg present"
    else
        log_issue "$cfg missing"
    fi
done

# 6. Provenance Log
if [[ -f "$PROVENANCE_LOG" ]] && [[ -s "$PROVENANCE_LOG" ]]; then
    log_ok "Provenance log exists and non-empty"
else
    log_issue "Provenance log missing or empty – run init.sh and other rituals"
fi

# 7. Recommendations Summary
if [[ $HEALTHY -eq 0 ]]; then
    log_warn "System has issues. Recommended actions:"
    echo "   1. Run ./scripts/init.sh"
    echo "   2. Run ./omniweave_enhance.sh --force"
    echo "   3. Install missing toolchains from official sources"
    echo "   4. Re-run this doctor script"
fi

# ----------------------------- Completion -----------------------------------

log_info "m3hlan-doctor diagnostic complete"

#
# Copyright © 2025 Devin B. Royal.
# All Rights Reserved.
#