#!/bin/bash
#
# Copyright © 2025 Devin B. Royal.
# All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0

# =============================================================================
# scripts/init.sh
# =============================================================================
# Version: 1.0.1 (Fixed trap syntax for macOS Bash 3.2 compatibility)
# Description: Production-grade, idempotent initialization ritual for OmniWeave OS.
#              Detects platform and toolchains, bootstraps developer environments,
#              creates virtual environments, installs git hooks, validates configs,
#              and applies secure defaults. Fully self-documenting with provenance.
# Author: Engineered for Devin B. Royal, Chief Technology Officer
# Date: December 15, 2025
# =============================================================================

set -Eeuo pipefail

# ----------------------------- Error Handling (macOS-compatible) -------------

handle_error() {
    local exit_code=$?
    local line_no=${1:-UNKNOWN}
    echo "[ERROR] $(date '+%Y-%m-%d %H:%M:%S') | Initialization failed at line $line_no (code $exit_code)" >&2
    exit "$exit_code"
}

handle_exit() {
    echo "[INFO] $(date '+%Y-%m-%d %H:%M:%S') | Initialization ritual complete."
    echo "GOT UM."
}

trap 'handle_error $LINENO' ERR
trap handle_exit EXIT

# ----------------------------- Configuration ----------------------------------

SCRIPT_VERSION="1.0.1"
SCRIPT_NAME="$(basename "$0")"
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOGS_DIR="${PROJECT_ROOT}/logs"
SETUP_LOG="${LOGS_DIR}/setup.log"
PROVENANCE_LOG="${PROJECT_ROOT}/provenance.log.jsonl"
ENHANCE_MARKER="# INITIALIZED by $SCRIPT_NAME v$SCRIPT_VERSION at $(date -u +"%Y-%m-%dT%H:%M:%SZ")"

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
    mkdir -p "$(dirname "$PROVENANCE_LOG")"
    echo "{\"script\":\"$SCRIPT_NAME\",\"version\":\"$SCRIPT_VERSION\",\"event\":\"$1\",\"ts\":\"$(date -u +"%Y-%m-%dT%H:%M:%SZ")\"}" >> "$PROVENANCE_LOG"
}

# ----------------------------- Platform & Tool Detection ---------------------

log_info "Detecting platform and essential toolchains..."

case "$(uname -s)" in
    Darwin)  PLATFORM="macOS" ;;
    Linux)   PLATFORM="Linux" ;;
    *)       PLATFORM="Unknown" ; log_warn "Unsupported platform $(uname -s)" ;;
esac
log_info "Platform: $PLATFORM"

command -v git     >/dev/null && HAS_GIT=true     || { HAS_GIT=false;     log_warn "git not found"; }
command -v make    >/dev/null && HAS_MAKE=true    || { HAS_MAKE=false;    log_warn "make not found"; }
command -v python3 >/dev/null && HAS_PYTHON=true  || { HAS_PYTHON=false;  log_warn "python3 not found"; }
command -v go      >/dev/null && HAS_GO=true      || { HAS_GO=false;      log_warn "go not found"; }
command -v cargo   >/dev/null && HAS_CARGO=true   || { HAS_CARGO=false;   log_warn "cargo not found"; }
command -v node    >/dev/null && HAS_NODE=true    || { HAS_NODE=false;    log_warn "node not found"; }
command -v npm     >/dev/null && HAS_NPM=true     || { HAS_NPM=false;     log_warn "npm not found"; }

# ----------------------------- Virtual Environment Setup --------------------

if $HAS_PYTHON; then
    log_info "Bootstrapping Python virtual environment..."
    VENV_DIR="${PROJECT_ROOT}/.venv"
    if [[ ! -d "$VENV_DIR" ]]; then
        python3 -m venv "$VENV_DIR"
        log_info "Created Python venv at $VENV_DIR"
    else
        log_info "Python venv already exists"
    fi

    # Activate and install dependencies
    # shellcheck source=/dev/null
    source "${VENV_DIR}/bin/activate"
    if [[ -f "requirements.txt" ]]; then
        pip install --upgrade pip >/dev/null 2>&1
        pip install -r requirements.txt >/dev/null 2>&1
        log_info "Python dependencies installed from requirements.txt"
    else
        log_warn "No requirements.txt found – skipping dependency installation"
    fi
    deactivate 2>/dev/null || true
else
    log_warn "Skipping Python venv setup (python3 missing)"
fi

# ----------------------------- Environment Variables -------------------------

if [[ -f ".env.example" ]] && [[ ! -f ".env" ]]; then
    log_info "Creating .env from .env.example"
    cp ".env.example" ".env"
fi

# ----------------------------- Git Hooks Installation -----------------------

if $HAS_GIT && [[ -d "${PROJECT_ROOT}/.git" ]]; then
    log_info "Installing git hooks for provenance and SPDX validation..."
    HOOKS_DIR="${PROJECT_ROOT}/.git/hooks"
    mkdir -p "$HOOKS_DIR"

    cat > "$HOOKS_DIR/pre-commit" <<'EOF'
#!/bin/bash
# Pre-commit hook: validate SPDX headers and provenance
if [[ -x "./scripts/validate.sh" ]]; then
    ./scripts/validate.sh || exit 1
else
    echo "validate.sh missing or not executable – skipping"
fi
EOF
    chmod +x "$HOOKS_DIR/pre-commit"

    cat > "$HOOKS_DIR/commit-msg" <<'EOF'
#!/bin/bash
# Commit-msg hook: placeholder for Conventional Commits enforcement
# Extend with actual validation logic as needed
EOF
    chmod +x "$HOOKS_DIR/commit-msg"

    log_info "Git hooks installed"
else
    log_warn "Skipping git hooks (no .git directory or git missing)"
fi

# ----------------------------- Pre-commit Framework -------------------------

if [[ -f ".pre-commit-config.yaml" ]] && command -v pre-commit >/dev/null 2>&1; then
    log_info "Installing pre-commit hooks..."
    pre-commit install
elif [[ -f ".pre-commit-config.yaml" ]]; then
    log_warn "pre-commit config exists but pre-commit tool missing – install via 'pip install pre-commit'"
fi

# ----------------------------- Final Validation ------------------------------

log_info "Running basic validation..."
if [[ -x "scripts/validate.sh" ]]; then
    ./scripts/validate.sh || { log_error "Validation failed"; exit 1; }
else
    log_warn "validate.sh not present or executable – skipping final validation"
fi

# ----------------------------- Provenance & Completion -----------------------

log_provenance "initialization_complete"
log_info "OmniWeave OS environment successfully initialized"

#
# Copyright © 2025 Devin B. Royal.
# All Rights Reserved.
#