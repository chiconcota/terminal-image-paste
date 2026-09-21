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

# Chuyển đổi định dạng hotkey sang cú pháp KDE Plasma (ví dụ: <Ctrl><Super>v -> Ctrl+Meta+V)
tip_shortcut_to_kde() {
    local raw="$1"
    raw=$(tip_decode_csi_u "$raw")

    # Xóa ký tự < và đổi > thành +
    local formatted
    formatted=$(echo "$raw" | sed -e 's/<//g' -e 's/>/+/g' -e 's/++*/+/g' -e 's/+$//' -e 's/^+//')

    # Chuẩn hóa tên phím sang dạng KDE: Meta (Super), Ctrl, Shift, Alt
    formatted=$(echo "$formatted" | sed -E \
        -e 's/\b(super|win)\b/Meta/Ig' \
        -e 's/\b(ctrl|control)\b/Ctrl/Ig' \
        -e 's/\b(shift)\b/Shift/Ig' \
        -e 's/\b(alt)\b/Alt/Ig')

    # Viết hoa ký tự cuối nếu là chữ cái đơn (ví dụ: +v -> +V)
    formatted=$(echo "$formatted" | sed -E 's/\+([a-z])$/+\U\1/')
    echo "$formatted"
}

# Cài đặt phím tắt tự động vào KDE Plasma (KDE 5 / 6 qua kglobalshortcutsrc)
tip_shortcut_install_kde() {
    local raw_hotkey="$1"
    local kde_hotkey
    kde_hotkey=$(tip_shortcut_to_kde "$raw_hotkey")
    if [[ -z "$kde_hotkey" ]]; then
        echo "Error: Invalid or empty hotkey combination." >&2
        return 1
    fi

    local bin_path
    bin_path="$(which tip 2>/dev/null || echo "$HOME/.local/bin/tip")"

    # 1. Tạo file desktop entry cho KDE Custom Shortcuts
    local apps_dir="${XDG_DATA_HOME:-$HOME/.local/share}/applications"
    mkdir -p "$apps_dir"
    local desktop_file="${apps_dir}/tip-paste.desktop"
    cat > "$desktop_file" <<EOF
[Desktop Entry]
Exec=${bin_path} paste
Name=Terminal Image Paste
Comment=Paste image from clipboard into terminal
NoDisplay=true
StartupNotify=false
Type=Application
X-KDE-GlobalAccel-CommandShortcut=true
EOF
    chmod +x "$desktop_file" 2>/dev/null || true

    # 2. Ghi cấu hình vào kglobalshortcutsrc
    local kwriter=""
    if command -v kwriteconfig6 &>/dev/null; then
        kwriter="kwriteconfig6"
    elif command -v kwriteconfig5 &>/dev/null; then
        kwriter="kwriteconfig5"
    fi

    if [[ -n "$kwriter" ]]; then
        "$kwriter" --file kglobalshortcutsrc --group "tip-paste.desktop" --key "_launch" "${kde_hotkey},none,Terminal Image Paste"
        "$kwriter" --file kglobalshortcutsrc --group "tip-paste.desktop" --key "_k_friendly_name" "Terminal Image Paste"
    else
        # Fallback cập nhật trực tiếp tệp cấu hình ~/.config/kglobalshortcutsrc
        local kconfig="${XDG_CONFIG_HOME:-$HOME/.config}/kglobalshortcutsrc"
        mkdir -p "$(dirname "$kconfig")"
        touch "$kconfig"
        if grep -q "^\[tip-paste\.desktop\]" "$kconfig" 2>/dev/null; then
            awk -v hotkey="${kde_hotkey}" '
                BEGIN { in_group=0 }
                /^\[tip-paste\.desktop\]/ { in_group=1; print; next }
                /^\[/ { in_group=0 }
                in_group && /^_launch=/ { print "_launch=" hotkey ",none,Terminal Image Paste"; next }
                { print }
            ' "$kconfig" > "${kconfig}.tmp" && mv "${kconfig}.tmp" "$kconfig"
        else
            cat >> "$kconfig" <<EOF

[tip-paste.desktop]
_k_friendly_name=Terminal Image Paste
_launch=${kde_hotkey},none,Terminal Image Paste
EOF
        fi
    fi

    # 3. Yêu cầu KWin / kglobalaccel tải lại phím tắt qua D-Bus
    qdbus6 org.kde.KWin /KWin reconfigure 2>/dev/null || \
    qdbus org.kde.KWin /KWin reconfigure 2>/dev/null || \
    qdbus org.kde.kglobalaccel /kglobalaccel org.kde.KGlobalAccel.reconfigure 2>/dev/null || true

    echo "Configured shortcut for KDE Plasma: ${kde_hotkey}"
    return 0
}

# Chuyển đổi định dạng hotkey sang cú pháp GNOME (ví dụ: <Ctrl><Super>v hoặc Super+Shift+V -> <Super><Shift>v)
tip_shortcut_to_gnome() {
    local raw="$1"
    raw=$(tip_decode_csi_u "$raw")

    # Xóa ký tự < và đổi > thành +
    local formatted
    formatted=$(echo "$raw" | sed -e 's/<//g' -e 's/>/+/g' -e 's/++*/+/g' -e 's/+$//' -e 's/^+//')

    local key_char
    key_char=$(echo "$formatted" | grep -o '[^+]*$')
    local mods
    mods=$(echo "$formatted" | sed -E 's/\+[^+]*$//')

    local gnome_mods=""
    for m in $(echo "$mods" | tr '+' ' '); do
        case "$m" in
            [Ss]uper|[Ww]in) gnome_mods="${gnome_mods}<Super>" ;;
            [Cc]trl|[Cc]ontrol) gnome_mods="${gnome_mods}<Ctrl>" ;;
            [Ss]hift) gnome_mods="${gnome_mods}<Shift>" ;;
            [Aa]lt) gnome_mods="${gnome_mods}<Alt>" ;;
        esac
    done

    local lower_key
    lower_key=$(echo "$key_char" | tr '[:upper:]' '[:lower:]')
    echo "${gnome_mods}${lower_key}"
}

# Cài đặt phím tắt tự động vào GNOME thông qua gsettings
tip_shortcut_install_gnome() {
    local raw_hotkey="$1"
    local gnome_hotkey
    gnome_hotkey=$(tip_shortcut_to_gnome "$raw_hotkey")
    if [[ -z "$gnome_hotkey" ]]; then
        echo "Error: Invalid or empty hotkey combination." >&2
        return 1
    fi

    if ! command -v gsettings &>/dev/null; then
        echo "Error: gsettings command not found." >&2
        return 1
    fi

    local bin_path
    bin_path="$(which tip 2>/dev/null || echo "$HOME/.local/bin/tip")"
    local base_path="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings"

    local current
    current=$(gsettings get org.gnome.settings-daemon.plugins.media-keys custom-keybindings 2>/dev/null || echo "@as []")

    local target_path=""
    if [[ "$current" =~ ($base_path/custom[0-9]+/|$base_path/tip-paste/) ]]; then
        for p in $(echo "$current" | grep -o "'$base_path/[^']*'"); do
            p=$(echo "$p" | tr -d "'")
            local p_name
            p_name=$(gsettings get "org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:${p}" name 2>/dev/null || true)
            if [[ "$p_name" == "'Terminal Image Paste'" ]]; then
                target_path="$p"
                break
            fi
        done
    fi

    if [[ -z "$target_path" ]]; then
        local max_idx=0
        for p in $(echo "$current" | grep -o "custom[0-9]\+"); do
            local num="${p#custom}"
            (( num >= max_idx )) && max_idx=$((num + 1))
        done
        target_path="${base_path}/custom${max_idx}/"

        if [[ "$current" == "@as []" || "$current" == "[]" ]]; then
            gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['$target_path']"
        else
            local new_list
            new_list=$(echo "$current" | sed "s|]|, '$target_path']|")
            gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "$new_list"
        fi
    fi

    gsettings set "org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:${target_path}" name 'Terminal Image Paste'
    gsettings set "org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:${target_path}" command "${bin_path} paste"
    gsettings set "org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:${target_path}" binding "$gnome_hotkey"

    echo "Configured shortcut for GNOME: ${gnome_hotkey}"
    return 0
}

# Coordinate shortcut installation by Display Server & Compositor
tip_shortcut_install() {
    local hotkey="${1:-$HOTKEY}"
    local compositor="${XDG_CURRENT_DESKTOP:-$DESKTOP_SESSION}"

    # Check GNOME
    if pgrep -x "gnome-shell" >/dev/null 2>&1 || [[ "$compositor" =~ (GNOME|Mutter) ]]; then
        tip_shortcut_install_gnome "$hotkey"
        return $?
    fi

    # Check KDE Plasma
    if pgrep -x "kwin_wayland" >/dev/null 2>&1 || pgrep -x "kwin_x11" >/dev/null 2>&1 || [[ "$compositor" =~ (KDE|Plasma|KWin) ]]; then
        tip_shortcut_install_kde "$hotkey"
        return $?
    fi

    # Check Niri
    if pgrep -x "niri" >/dev/null 2>&1 || [[ "$compositor" =~ [Nn]iri ]] || [[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/niri/config.kdl" ]]; then
        tip_shortcut_install_niri "$hotkey"
        return $?
    fi

    echo "Automatic shortcut installation not yet supported for: $compositor" >&2
    echo "You can manually bind shortcut $hotkey to run: tip paste" >&2
    return 1
}
