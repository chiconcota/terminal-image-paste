#!/usr/bin/env bash
# lib/shortcut.sh - Global Shortcut Manager for Terminal Image Paste (tip)
# Supports Niri, Hyprland, Sway, GNOME, etc.

# Giải mã chuỗi phím bấm CSI u từ terminal (ví dụ Ghostty/Kitty: ^[[98;5u -> Ctrl+B)
tip_decode_csi_u() {
    local input="$1"
    local clean
    clean=$(echo "$input" | sed -E 's/^(\x1b\[|\^\[\[)//')
    local re='^([0-9]+);([0-9]+)u$'
    if [[ "$clean" =~ $re ]]; then
        local code="${BASH_REMATCH[1]}"
        local mod="${BASH_REMATCH[2]}"
        local char=""
        if (( code >= 32 && code <= 126 )); then
            char=$(printf "\\$(printf '%03o' "$code")")
            char=$(echo "$char" | tr '[:lower:]' '[:upper:]')
        fi
        local prefix=""
        case "$mod" in
            2) prefix="Shift+" ;;
            3) prefix="Alt+" ;;
            4) prefix="Alt+Shift+" ;;
            5) prefix="Ctrl+" ;;
            6) prefix="Ctrl+Shift+" ;;
            7) prefix="Ctrl+Alt+" ;;
            8) prefix="Ctrl+Alt+Shift+" ;;
            9) prefix="Super+" ;;
            10) prefix="Super+Shift+" ;;
            11) prefix="Super+Alt+" ;;
            13) prefix="Super+Ctrl+" ;;
            14) prefix="Super+Ctrl+Shift+" ;;
            *) prefix="Ctrl+" ;;
        esac
        echo "${prefix}${char}"
        return 0
    fi
    echo "$input"
}

# Chuyển đổi định dạng hotkey sang cú pháp Niri (ví dụ: <Ctrl><Super>v -> Ctrl+Super+V)
tip_shortcut_to_niri() {
    local raw="$1"
    raw=$(tip_decode_csi_u "$raw")

    # Xóa ký tự < và đổi > thành +
    local formatted
    formatted=$(echo "$raw" | sed -e 's/<//g' -e 's/>/+/g' -e 's/++*/+/g' -e 's/+$//' -e 's/^+//')

    # Chuẩn hóa tên phím sang dạng Niri: Ctrl, Super, Shift, Alt, Mod
    formatted=$(echo "$formatted" | sed -E \
        -e 's/\b(ctrl|control)\b/Ctrl/Ig' \
        -e 's/\b(super|win)\b/Super/Ig' \
        -e 's/\b(shift)\b/Shift/Ig' \
        -e 's/\b(alt)\b/Alt/Ig' \
        -e 's/\b(mod)\b/Mod/Ig')

    # Viết hoa ký tự cuối nếu là chữ cái đơn (ví dụ: +v -> +V)
    formatted=$(echo "$formatted" | sed -E 's/\+([a-z])$/+\U\1/')
    echo "$formatted"
}

# Cài đặt phím tắt tự động vào Niri (~/.config/niri/config.kdl)
tip_shortcut_install_niri() {
    local raw_hotkey="$1"
    local niri_config="${XDG_CONFIG_HOME:-$HOME/.config}/niri/config.kdl"
    local bin_path
    bin_path="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/bin/tip"

    if [[ ! -f "$niri_config" ]]; then
        echo "Niri configuration file not found at: $niri_config" >&2
        return 1
    fi

    local niri_hotkey
    niri_hotkey=$(tip_shortcut_to_niri "$raw_hotkey")
    if [[ -z "$niri_hotkey" ]]; then
        echo "Error: Invalid or empty hotkey combination." >&2
        return 1
    fi

    # Create safety backup
    cp "$niri_config" "${niri_config}.bak_tip" 2>/dev/null || true

    local bind_line="    ${niri_hotkey} { spawn \"${bin_path}\" \"paste\"; }"

    # Check if // [tip-shortcut] marker exists
    if grep -q "// \[tip-shortcut\]" "$niri_config" 2>/dev/null; then
        awk -v line="$bind_line" '
            /\/\/ \[tip-shortcut\]/ { print; getline; print line; next }
            { print }
        ' "$niri_config" > "${niri_config}.tmp" && mv "${niri_config}.tmp" "$niri_config"
    else
        # Insert after global root-level binds {
        if grep -q "^binds[[:space:]]*{" "$niri_config"; then
            awk -v line="$bind_line" '
                !inserted && /^binds[[:space:]]*\{/ {
                    print
                    print "    // [tip-shortcut]"
                    print line
                    inserted=1
                    next
                }
                { print }
            ' "$niri_config" > "${niri_config}.tmp" && mv "${niri_config}.tmp" "$niri_config"
        else
            echo "Global 'binds {' block not found in $niri_config" >&2
            return 1
        fi
    fi

    echo "Configured shortcut for Niri: ${niri_hotkey}"
    return 0
}

# Coordinate shortcut installation by Display Server & Compositor
tip_shortcut_install() {
    local hotkey="${1:-$HOTKEY}"
    local compositor="${XDG_CURRENT_DESKTOP:-unknown}"

    # Check Niri
    if [[ "$compositor" =~ [Nn]iri ]] || pgrep -x "niri" >/dev/null 2>&1 || [[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/niri/config.kdl" ]]; then
        tip_shortcut_install_niri "$hotkey"
        return $?
    fi

    echo "Automatic shortcut installation not yet supported for: $compositor" >&2
    echo "You can manually bind shortcut $hotkey to run: tip paste" >&2
    return 1
}
