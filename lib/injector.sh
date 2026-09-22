#!/usr/bin/env bash
# lib/injector.sh - Terminal input simulator (wtype / xdotool)
# Injects formatted text directly into the active terminal window

_tip_inject_wayland() {
    local text="$1"
    local auto_enter="$2"

    # Always ensure text is copied to Wayland clipboard (for instant paste and manual Ctrl+Shift+V)
    if command -v wl-copy &>/dev/null; then
        printf "%s" "$text" | wl-copy 2>/dev/null || true
        printf "%s" "$text" | wl-copy --primary 2>/dev/null || true
    fi

    local de="${XDG_CURRENT_DESKTOP:-$DESKTOP_SESSION}"
    local is_hyprland=false
    if { pgrep -x Hyprland &>/dev/null || [[ "$de" =~ [Hh]yprland ]]; } && command -v hyprctl &>/dev/null; then
        is_hyprland=true
    fi

    # 1. Hyprland: Native sendshortcut dispatcher (zero virtual-keyboard bug, zero scancode collision)
    if $is_hyprland; then
        sleep 0.1
        # Try Hyprland Lua dispatcher (CachyOS / Hyprland 0.56+), then standard C++ sendshortcut dispatchers
        if hyprctl dispatch 'hl.dsp.send_shortcut({ mods = "CTRL SHIFT", key = "v" })' &>/dev/null || \
           hyprctl dispatch sendshortcut "CTRL SHIFT, V, active" &>/dev/null || \
           hyprctl dispatch sendshortcut "CTRL_SHIFT, V, active" &>/dev/null || \
           hyprctl dispatch sendshortcut "SHIFT, Insert, active" &>/dev/null || \
           hyprctl dispatch sendshortcut "CTRL, V, active" &>/dev/null || \
           hyprctl dispatch sendshortcut "CTRL SHIFT, V" &>/dev/null; then
            if [[ "$auto_enter" == "true" ]]; then
                sleep 0.05
                hyprctl dispatch 'hl.dsp.send_shortcut({ mods = "", key = "Return" })' &>/dev/null || \
                hyprctl dispatch sendshortcut ", Return, active" &>/dev/null || \
                hyprctl dispatch sendshortcut ", Return" &>/dev/null || true
            fi
            return 0
        fi
        tip_log_warn "hyprctl sendshortcut failed on Hyprland. Bypassing wtype to avoid btop keybind collision."
        # STRICT ISOLATION: Never fall through to wtype on Hyprland (wtype -k v emits scancode 1 KEY_ESC, triggering Ctrl+Shift+Escape -> btop)
        return 1
    fi

    # 2. Preferred (General Wayland - Niri / Sway): Clipboard Paste via wtype (Instant 0ms, zero scancode collision)
    if command -v wl-copy &>/dev/null && command -v wtype &>/dev/null; then
        sleep 0.1
        if wtype -M ctrl -M shift -k v -m shift -m ctrl 2>/dev/null; then
            if [[ "$auto_enter" == "true" ]]; then
                sleep 0.05
                wtype -k Return 2>/dev/null || true
            fi
            return 0
        fi
        tip_log_warn "wtype keypress failed (compositor might not support zwp_virtual_keyboard_v1, e.g. KWin/Mutter)."
    fi

    # 3. Fallback: Direct typing via wtype
    if command -v wtype &>/dev/null; then
        if wtype -d 1 "$text" 2>/dev/null; then
            if [[ "$auto_enter" == "true" ]]; then
                wtype -k Return 2>/dev/null || true
            fi
            return 0
        fi
    fi

    # 4. Fallback: ydotool (works globally on Wayland/KDE/GNOME via /dev/uinput)
    if command -v ydotool &>/dev/null; then
        sleep 0.2
        # Preferred: Fast Clipboard Paste via Ctrl+Shift+V (instant, clean, zero double-output)
        if ydotool key 29:1 42:1 47:1 47:0 42:0 29:0 2>/dev/null; then
            if [[ "$auto_enter" == "true" ]]; then
                sleep 0.05
                ydotool key 28:1 28:0 2>/dev/null || true
            fi
            return 0
        fi
        # Secondary fallback: Direct typing via ydotool
        if ydotool type -- "$text" 2>/dev/null; then
            if [[ "$auto_enter" == "true" ]]; then
                ydotool key 28:1 28:0 2>/dev/null || true
            fi
            return 0
        fi
        tip_log_warn "ydotool command failed (ydotool service might not be running or lacks /dev/uinput permissions)."
    fi

    return 1
}

_tip_inject_x11() {
    local text="$1"
    local auto_enter="$2"

    # Always copy text to both X11 clipboard and primary selection
    if command -v xclip &>/dev/null; then
        printf "%s" "$text" | xclip -selection clipboard 2>/dev/null || true
        printf "%s" "$text" | xclip -selection primary 2>/dev/null || true
    fi

    # 1. Preferred: Clipboard Paste via xdotool
    # Sleep 0.25s ensures Window Managers (Openbox, XFCE, i3) release physical key grab (XUngrabKeyboard)
    if command -v xclip &>/dev/null && command -v xdotool &>/dev/null; then
        sleep 0.25
        if xdotool key --clearmodifiers ctrl+shift+v 2>/dev/null; then
            if [[ "$auto_enter" == "true" ]]; then
                sleep 0.05
                xdotool key --clearmodifiers Return 2>/dev/null || true
            fi
            return 0
        fi
    fi

    # 2. Fallback: Direct typing via xdotool
    if command -v xdotool &>/dev/null; then
        sleep 0.1
        if xdotool type --clearmodifiers --delay 0 "$text" 2>/dev/null; then
            if [[ "$auto_enter" == "true" ]]; then
                xdotool key --clearmodifiers Return 2>/dev/null || true
            fi
            return 0
        fi
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
        tip_log_warn "Virtual keyboard injection failed or unsupported on Wayland. Falling back to stdout."
    elif [[ "$display_server" == "x11" ]]; then
        if _tip_inject_x11 "$text" "$auto_enter"; then
            tip_log_info "Injected text into active terminal (X11)."
            return 0
        fi
        tip_log_warn "xdotool injection failed or unavailable on X11. Falling back to stdout."
    fi

    # Fallback khi công cụ gõ phím ảo thất bại hoặc không được compositor hỗ trợ
    echo "$text"
    return 0
}
