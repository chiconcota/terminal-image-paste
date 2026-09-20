#!/usr/bin/env bash
# lib/injector.sh - Terminal input simulator (wtype / xdotool)
# Injects formatted text directly into the active terminal window

_tip_inject_wayland() {
    local text="$1"
    local auto_enter="$2"

    # Preferred: Clipboard Paste (Instant 0ms, zero scancode collision, immune to IME/Fcitx)
    if command -v wl-copy &>/dev/null && command -v wtype &>/dev/null; then
        printf "%s" "$text" | wl-copy
        printf "%s" "$text" | wl-copy --primary 2>/dev/null || true
        sleep 0.1
        wtype -M ctrl -M shift -k v -m shift -m ctrl 2>/dev/null
        if [[ "$auto_enter" == "true" ]]; then
            sleep 0.05
            wtype -k Return 2>/dev/null
        fi
        return 0
    elif command -v wtype &>/dev/null; then
        # Fallback to key typing if wl-copy is not installed
        wtype -p Escape -d 1 "$text" 2>/dev/null
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

    # Preferred: Clipboard Paste
    if command -v xclip &>/dev/null && command -v xdotool &>/dev/null; then
        printf "%s" "$text" | xclip -selection clipboard 2>/dev/null
        sleep 0.05
        xdotool key --clearmodifiers ctrl+shift+v 2>/dev/null
        if [[ "$auto_enter" == "true" ]]; then
            sleep 0.05
            xdotool key --clearmodifiers Return 2>/dev/null
        fi
        return 0
    elif command -v xdotool &>/dev/null; then
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
            tip_log_info "Injected text into active terminal (Wayland)."
            return 0
        fi
        tip_log_warn "Neither wtype nor ydotool found on Wayland. Falling back to stdout."
    elif [[ "$display_server" == "x11" ]]; then
        if _tip_inject_x11 "$text" "$auto_enter"; then
            tip_log_info "Injected text into active terminal (X11)."
            return 0
        fi
        tip_log_warn "xdotool not found on X11. Falling back to stdout."
    fi

    # Fallback khi thiếu công cụ gõ phím
    printf "%s" "$text"
    [[ "$auto_enter" == "true" ]] && echo ""
    return 0
}
