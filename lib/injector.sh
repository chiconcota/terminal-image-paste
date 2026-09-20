#!/usr/bin/env bash
# lib/injector.sh - Terminal input simulator (wtype / xdotool)
# Injects formatted text directly into the active terminal window

_tip_inject_wayland() {
    local text="$1"
    local auto_enter="$2"

    if command -v wtype &>/dev/null; then
        wtype -d 1 "$text" 2>/dev/null
        if [[ "$auto_enter" == "true" ]]; then
            wtype -k Return 2>/dev/null
        fi
        return 0
    elif command -v ydotool &>/dev/null; then
        ydotool type "$text" 2>/dev/null
        if [[ "$auto_enter" == "true" ]]; then
            ydotool key 28:1 28:0 2>/dev/null
        fi
        return 0
    fi
    return 1
}

_tip_inject_x11() {
    local text="$1"
    local auto_enter="$2"

    if command -v xdotool &>/dev/null; then
        xdotool type --clearmodifiers --delay 0 "$text" 2>/dev/null
        if [[ "$auto_enter" == "true" ]]; then
            xdotool key --clearmodifiers Return 2>/dev/null
        fi
        return 0
    fi
    return 1
}

tip_inject_text() {
    local text="$1"
    local auto_enter="$2"
    local display_server
    display_server=$(tip_detect_display_server)

    if [[ -z "$text" ]]; then
        return 1
    fi

    if [[ "$display_server" == "wayland" ]]; then
        if _tip_inject_wayland "$text" "$auto_enter"; then
            tip_log_info "Đã inject text vào terminal active (Wayland)."
            return 0
        fi
        tip_log_warn "Không tìm thấy wtype hoặc ydotool trên Wayland. Fallback xuất stdout."
    elif [[ "$display_server" == "x11" ]]; then
        if _tip_inject_x11 "$text" "$auto_enter"; then
            tip_log_info "Đã inject text vào terminal active (X11)."
            return 0
        fi
        tip_log_warn "Không tìm thấy xdotool trên X11. Fallback xuất stdout."
    fi

    # Fallback khi thiếu công cụ gõ phím
    printf "%s" "$text"
    [[ "$auto_enter" == "true" ]] && echo ""
    return 0
}
