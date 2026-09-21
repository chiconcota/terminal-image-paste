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

# Chuyển đổi định dạng hotkey sang cú pháp Openbox XML (ví dụ: <Ctrl><Super>v -> C-W-v, <Super><Shift>v -> W-S-v)
tip_shortcut_to_openbox() {
    local raw="$1"
    raw=$(tip_decode_csi_u "$raw")

    local formatted
    formatted=$(echo "$raw" | sed -e 's/<//g' -e 's/>/+/g' -e 's/++*/+/g' -e 's/+$//' -e 's/^+//')

    local key_char
    key_char=$(echo "$formatted" | grep -o '[^+]*$')
    local mods
    mods=$(echo "$formatted" | sed -E 's/\+[^+]*$//')

    local ob_mods=""
    for m in $(echo "$mods" | tr '+' ' '); do
        case "$m" in
            [Ss]uper|[Ww]in) ob_mods="${ob_mods}W-" ;;
            [Cc]trl|[Cc]ontrol) ob_mods="${ob_mods}C-" ;;
            [Ss]hift) ob_mods="${ob_mods}S-" ;;
            [Aa]lt) ob_mods="${ob_mods}A-" ;;
        esac
    done

    local lower_key
    lower_key=$(echo "$key_char" | tr '[:upper:]' '[:lower:]')
    echo "${ob_mods}${lower_key}"
}

# Cài đặt phím tắt tự động vào Openbox / LXDE (~/.config/openbox/lxde-rc.xml hoặc rc.xml)
tip_shortcut_install_lxde() {
    local raw_hotkey="$1"
    local ob_hotkey
    ob_hotkey=$(tip_shortcut_to_openbox "$raw_hotkey")
    if [[ -z "$ob_hotkey" ]]; then
        echo "Error: Invalid or empty hotkey combination." >&2
        return 1
    fi

    local bin_path
    bin_path="$(which tip 2>/dev/null || echo "$HOME/.local/bin/tip")"

    local ob_dir="${XDG_CONFIG_HOME:-$HOME/.config}/openbox"
    mkdir -p "$ob_dir"
    local ob_config="${ob_dir}/lxde-rc.xml"
    if [[ ! -f "$ob_config" ]]; then
        if [[ -f "${ob_dir}/rc.xml" ]]; then
            ob_config="${ob_dir}/rc.xml"
        elif [[ -f "/etc/xdg/openbox/lxde-rc.xml" ]]; then
            cp "/etc/xdg/openbox/lxde-rc.xml" "$ob_config" 2>/dev/null || true
        elif [[ -f "/etc/xdg/openbox/rc.xml" ]]; then
            cp "/etc/xdg/openbox/rc.xml" "$ob_config" 2>/dev/null || true
        else
            cat > "$ob_config" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<openbox_config xmlns="http://openbox.org/3.4/rc">
  <keyboard>
  </keyboard>
</openbox_config>
EOF
        fi
    fi

    cp "$ob_config" "${ob_config}.bak_tip" 2>/dev/null || true

    if grep -q "<!-- \[tip-shortcut\] -->" "$ob_config" 2>/dev/null; then
        awk -v hotkey="$ob_hotkey" -v bin_path="$bin_path" '
            BEGIN { in_tip=0 }
            /<!-- \[tip-shortcut\] -->/ {
                in_tip=1
                print
                print "    <keybind key=\"" hotkey "\">"
                print "      <action name=\"Execute\">"
                print "        <command>" bin_path " paste</command>"
                print "      </action>"
                print "    </keybind>"
                next
            }
            in_tip && /<\/keybind>/ { in_tip=0; next }
            in_tip { next }
            { print }
        ' "$ob_config" > "${ob_config}.tmp" && mv "${ob_config}.tmp" "$ob_config"
    else
        awk -v hotkey="$ob_hotkey" -v bin_path="$bin_path" '
            BEGIN { inserted=0 }
            !inserted && /<keyboard[ >]/ {
                print
                print "    <!-- [tip-shortcut] -->"
                print "    <keybind key=\"" hotkey "\">"
                print "      <action name=\"Execute\">"
                print "        <command>" bin_path " paste</command>"
                print "      </action>"
                print "    </keybind>"
                inserted=1
                next
            }
            { print }
        ' "$ob_config" > "${ob_config}.tmp" && mv "${ob_config}.tmp" "$ob_config"
    fi

    openbox --reconfigure 2>/dev/null || true
    echo "Configured shortcut for LXDE (Openbox): ${ob_hotkey}"
    return 0
}

# Hiển thị hướng dẫn cấu hình phím tắt thủ công cho các Window Manager / Desktop ngoài Niri
tip_shortcut_show_manual_guide() {
    local raw_hotkey="$1"
    local compositor="${XDG_CURRENT_DESKTOP:-$DESKTOP_SESSION}"

    echo -e "\n\033[1m📋 Hướng dẫn cài đặt phím tắt thủ công:\033[0m"
    echo -e "Lệnh cần kích hoạt khi nhấn phím tắt: \033[32m\033[1mtip paste\033[0m\n"

    if pgrep -x "Hyprland" &>/dev/null || [[ "$compositor" =~ [Hh]yprland ]]; then
        echo -e "\033[36m▶ Dành cho Hyprland:\033[0m"
        echo -e "  • \033[1mCấu hình chuẩn (~/.config/hypr/hyprland.conf):\033[0m"
        echo -e "    bind = SUPER, V, exec, tip paste\n"
        echo -e "  • \033[1mCachyOS Noctalia Lua (~/.config/hypr/config/binds.lua):\033[0m"
        echo -e "    hl.bind(\"SUPER\", \"V\", \"exec\", \"tip paste\")"
    elif pgrep -x "sway" &>/dev/null || [[ "$compositor" =~ [Ss]way ]]; then
        echo -e "\033[36m▶ Dành cho Sway (~/.config/sway/config):\033[0m"
        echo -e "    bindsym \$mod+v exec tip paste"
    elif pgrep -x "i3" &>/dev/null || [[ "$compositor" =~ [iI]3 ]]; then
        echo -e "\033[36m▶ Dành cho i3 (~/.config/i3/config):\033[0m"
        echo -e "    bindsym \$mod+v exec tip paste"
    elif pgrep -x "kwin_wayland" &>/dev/null || pgrep -x "kwin_x11" &>/dev/null || [[ "$compositor" =~ (KDE|Plasma|KWin) ]]; then
        echo -e "\033[36m▶ Dành cho KDE Plasma:\033[0m"
        echo -e "    Vào System Settings -> Shortcuts -> Custom Shortcuts -> Add Command:"
        echo -e "    Tên: Terminal Image Paste"
        echo -e "    Lệnh thực thi: tip paste"
    elif pgrep -x "gnome-shell" &>/dev/null || [[ "$compositor" =~ (GNOME|Mutter) ]]; then
        echo -e "\033[36m▶ Dành cho GNOME:\033[0m"
        echo -e "    Vào Settings -> Keyboard -> Keyboard Shortcuts -> Custom Shortcuts (+):"
        echo -e "    Tên: Terminal Image Paste"
        echo -e "    Lệnh thực thi: tip paste"
    else
        echo -e "\033[36m▶ Cấu hình chung cho Window Manager / Desktop:\033[0m"
        echo -e "    Tạo một phím tắt gọi lệnh: \033[32mtip paste\033[0m"
    fi
    echo ""
}

# Coordinate shortcut installation: ONLY Niri is automated, others display manual setup guide
tip_shortcut_install() {
    local hotkey="${1:-$HOTKEY}"
    local compositor="${XDG_CURRENT_DESKTOP:-$DESKTOP_SESSION}"

    # Check Niri: duy nhất Niri được tích hợp tự động vào file cấu hình config.kdl
    if pgrep -x "niri" >/dev/null 2>&1 || [[ "$compositor" =~ [Nn]iri ]] || [[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/niri/config.kdl" ]]; then
        tip_shortcut_install_niri "$hotkey"
        return $?
    fi

    # Các compositor / desktop khác: in hướng dẫn tự gán phím tắt
    tip_shortcut_show_manual_guide "$hotkey"
    return 0
}
