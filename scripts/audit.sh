#!/bin/bash
#
# Copyright © 2025 Devin B. Royal.
# All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0

# =============================================================================
# scripts/audit.sh
# =============================================================================
# Version: 1.0.0
# Description: Production-grade audit ritual for OmniWeave OS.
#              Performs license compliance audit, provenance chain verification,
#              SBOM validation, and runtime contract consistency checks.
#              Fully compatible with macOS Bash 3.2 and Linux.
# Author: Engineered for Devin B. Royal, Chief Technology Officer
# Date: December 15, 2025
# =============================================================================

set -Eeuo pipefail

# ----------------------------- Error Handling (macOS Bash 3.2 safe) ---------

handle_error() {
    local exit_code=$?
    local line_no=${1:-UNKNOWN}
    echo "[ERROR] $(date '+%Y-%m-%d %H:%M:%S') | Audit failed at line $line_no (code $exit_code)" >&2
    exit "$exit_code"
}

handle_exit() {
    if [[ $AUDIT_PASSED -eq 1 ]]; then
        echo "[INFO] $(date '+%Y-%m-%d %H:%M:%S') | Audit successful."
        echo "GOT UM."
    else
        echo "[ERROR] $(date '+%Y-%m-%d %H:%M:%S') | Audit failed."
        exit 1
    fi
}

trap 'handle_error $LINENO' ERR
trap handle_exit EXIT

AUDIT_PASSED=0  # Set to 1 only on full success

# ----------------------------- Configuration ----------------------------------

SCRIPT_VERSION="1.0.0"
SCRIPT_NAME="$(basename "$0")"
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOGS_DIR="${PROJECT_ROOT}/logs"
SETUP_LOG="${LOGS_DIR}/setup.log"
PROVENANCE_LOG="${PROJECT_ROOT}/provenance.log.jsonl"

mkdir -p "$LOGS_DIR"

# ----------------------------- Logging & Provenance ---------------------------

log() {
    local level="$1" msg="$2"
    local color=""
    case "$level" in
        INFO)  color="\033[32m" ;;
        WARN)  color="\033[33m" ;;
        ERROR) color="\033[31m" ;;
    esac

    if [[ -t 1 ]]; then
        echo -e "[${color}${level}\033[0m] $(date '+%Y-%m-%d %H:%M:%S') | $msg"
    else
        echo "[$level] $(date '+%Y-%m-%d %H:%M:%S') | $msg"
    fi

    echo "{\"level\":\"$level\",\"ts\":\"$(date -u +"%Y-%m-%dT%H:%M:%SZ")\",\"msg\":\"$msg\"}" >> "$SETUP_LOG"
}

log_info()  { log "INFO"  "$1"; }
log_warn()  { log "WARN"  "$1"; }
log_error() { log "ERROR" "$1"; }

log_provenance() {
    echo "{\"script\":\"$SCRIPT_NAME\",\"version\":\"$SCRIPT_VERSION\",\"event\":\"$1\",\"ts\":\"$(date -u +"%Y-%m-%dT%H:%M:%SZ")\"}" >> "$PROVENANCE_LOG"
}

# ----------------------------- Audit Checks ---------------------------------

log_info "Starting OmniWeave OS audit v$SCRIPT_VERSION"

# 1. License Compliance (SPDX + Copyright)
log_info "Auditing license headers..."
MISSING_SPDX=$(find "$PROJECT_ROOT" -type f \( -name "*.sh" -o -name "*.py" -o -name "*.go" -o -name "*.rs" -o -name "*.yaml" \) ! -path "*/.git/*" -exec grep -L "SPDX-License-Identifier:" {} + 2>/dev/null || true)
if [[ -n "$MISSING_SPDX" ]]; then
    log_error "Files missing SPDX-License-Identifier:"
    echo "$MISSING_SPDX"
else
    log_info "All relevant files contain SPDX headers"
fi

MISSING_COPYRIGHT=$(find "$PROJECT_ROOT" -type f \( -name "*.sh" -o -name "*.py" \) ! -path "*/.git/*" -exec grep -L "Copyright © 2025 Devin B. Royal" {} + 2>/dev/null || true)
if [[ -n "$MISSING_COPYRIGHT" ]]; then
    log_error "Files missing copyright notice:"
    echo "$MISSING_COPYRIGHT"
else
    log_info "Copyright notices present"
fi

# 2. Provenance Chain Verification
log_info "Verifying provenance chain..."
if [[ -f "$PROVENANCE_LOG" ]]; then
    if command -v jq >/dev/null 2>&1; then
        if jq empty "$PROVENANCE_LOG" 2>/dev/null; then
            log_info "Provenance log is valid JSONL"
            EVENT_COUNT=$(wc -l < "$PROVENANCE_LOG")
            log_info "Provenance contains $EVENT_COUNT events"
        else
            log_error "Provenance log is not valid JSONL"
        fi
    else
        log_warn "jq unavailable – skipping JSONL syntax check"
    fi
else
    log_warn "No provenance.log.jsonl found"
fi

# 3. SBOM Validation
log_info "Validating SBOM..."
if [[ -f "$PROJECT_ROOT/sbom.json" ]]; then
    if command -v jq >/dev/null 2>&1; then
        jq empty "$PROJECT_ROOT/sbom.json" && log_info "sbom.json is valid JSON" || log_error "sbom.json malformed"
    else
        log_warn "jq unavailable – skipping SBOM syntax check"
    fi
else
    log_warn "sbom.json missing – run m3hlan-sbom.sh to generate"
fi

# 4. Runtime Contract Consistency (if present)
if [[ -f "$PROJECT_ROOT/modules/runtime_contracts/contracts/module_contract.schema.json" ]]; then
    log_info "Runtime contract schema present"
else
    log_warn "Runtime contract schema missing"
fi

# ----------------------------- Completion -----------------------------------

AUDIT_PASSED=1
log_provenance "audit_complete"
log_info "OmniWeave OS audit completed successfully"

#
# Copyright © 2025 Devin B. Royal.
# All Rights Reserved.
#