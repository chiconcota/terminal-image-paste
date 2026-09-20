#!/usr/bin/env bash
# lib/logger.sh - Logger module for Terminal Image Paste (tip)
# Pure terminal logging with automatic rotation (max 500 lines)

TIP_STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/tip"
TIP_LOG_FILE="${TIP_STATE_DIR}/tip.log"
TIP_MAX_LOG_LINES=500

tip_log_init() {
    if [[ ! -d "$TIP_STATE_DIR" ]]; then
        mkdir -p "$TIP_STATE_DIR" 2>/dev/null || true
    fi
    if [[ ! -f "$TIP_LOG_FILE" ]]; then
        touch "$TIP_LOG_FILE" 2>/dev/null || true
    fi
}

_tip_log_rotate() {
    if [[ -f "$TIP_LOG_FILE" ]]; then
        local line_count
        line_count=$(wc -l < "$TIP_LOG_FILE" 2>/dev/null || echo 0)
        if (( line_count > TIP_MAX_LOG_LINES )); then
            local temp_file="${TIP_LOG_FILE}.tmp.$$"
            tail -n "$TIP_MAX_LOG_LINES" "$TIP_LOG_FILE" > "$temp_file" 2>/dev/null && \
                mv -f "$temp_file" "$TIP_LOG_FILE" 2>/dev/null || rm -f "$temp_file"
        fi
    fi
}

_tip_level_to_int() {
    case "${1^^}" in
        DEBUG) echo 0 ;;
        INFO)  echo 1 ;;
        WARN)  echo 2 ;;
        ERROR) echo 3 ;;
        *)     echo 1 ;;
    esac
}

_tip_log_write() {
    local level="$1"
    shift
    local msg="$*"
    local current_level="${LOG_LEVEL:-INFO}"
    
    local lvl_int cur_int
    lvl_int=$(_tip_level_to_int "$level")
    cur_int=$(_tip_level_to_int "$current_level")

    if (( lvl_int < cur_int )); then
        return 0
    fi

    tip_log_init
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    printf "[%s] [%-5s] %s\n" "$timestamp" "$level" "$msg" >> "$TIP_LOG_FILE" 2>/dev/null
    _tip_log_rotate
}

tip_log_debug() { _tip_log_write "DEBUG" "$@"; }
tip_log_info()  { _tip_log_write "INFO"  "$@"; }
tip_log_warn()  { _tip_log_write "WARN"  "$@"; }
tip_log_error() { _tip_log_write "ERROR" "$@"; }

tip_show_logs() {
    local follow=false
    local lines=30

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -f|--follow)
                follow=true
                shift
                ;;
            -n|--lines)
                lines="${2:-30}"
                shift 2
                ;;
            *)
                shift
                ;;
        esac
    done

    if [[ ! -f "$TIP_LOG_FILE" ]]; then
        echo "Chưa có file nhật ký ($TIP_LOG_FILE)."
        return 0
    fi

    if [[ "$follow" == "true" ]]; then
        tail -n "$lines" -f "$TIP_LOG_FILE"
    else
        tail -n "$lines" "$TIP_LOG_FILE"
    fi
}
