#!/usr/bin/env bash
# lib/doctor.sh - System diagnostics and health check module
# Pure terminal output with zero GUI popups

_tip_doctor_check_cmd() {
    local cmd="$1"
    local desc="$2"
    local required="$3"

    if command -v "$cmd" &>/dev/null; then
        printf "  \033[0;32m✔\033[0m %-16s : \033[0;32mInstalled\033[0m (%s)\n" "$cmd" "$desc"
        return 0
    else
        if [[ "$required" == "true" ]]; then
            printf "  \033[0;31m✘\033[0m %-16s : \033[0;31mNot installed (Required)\033[0m (%s)\n" "$cmd" "$desc"
            return 1
        else
            printf "  \033[0;33m-\033[0m %-16s : \033[0;33mNot installed (Optional)\033[0m (%s)\n" "$cmd" "$desc"
            return 0
        fi
    fi
}

_tip_doctor_check_dir() {
    local path="$1"
    local desc="$2"

    if [[ -d "$path" && -w "$path" ]]; then
        printf "  \033[0;32m✔\033[0m %-16s : \033[0;32mValid & Writable\033[0m (%s)\n" "$path" "$desc"
    else
        printf "  \033[0;33m!\033[0m %-16s : \033[0;33mMissing or Not Writable\033[0m (%s)\n" "$path" "$desc"
    fi
}

_tip_doctor_detect_de() {
    local de="${XDG_CURRENT_DESKTOP:-$DESKTOP_SESSION}"
    if pgrep -x niri &>/dev/null; then
        echo "Niri (Scrollable-tiling Wayland Compositor)"
    elif pgrep -x Hyprland &>/dev/null; then
        echo "Hyprland"
    elif pgrep -x sway &>/dev/null; then
        echo "Sway"
    elif pgrep -x kwin_wayland &>/dev/null || [[ "$de" =~ [Kk][Dd][Ee]|PLASMA ]]; then
        echo "KDE Plasma (KWin)"
    elif pgrep -x gnome-shell &>/dev/null || [[ "$de" =~ [Gg][Nn][Oo][Mm][Ee] ]]; then
        echo "GNOME (Mutter)"
    elif pgrep -x openbox &>/dev/null || [[ "$de" =~ (LXDE|Openbox|OPENBOX) ]]; then
        echo "LXDE (Openbox)"
    elif [[ -n "$de" ]]; then
        echo "$de"
    else
        echo "Unknown (CLI / Custom WM)"
    fi
}

tip_run_doctor() {
    local os_name="Linux"
    [[ -f /etc/os-release ]] && os_name=$(grep -E '^PRETTY_NAME=' /etc/os-release | cut -d= -f2 | tr -d '"')

    local display_server
    display_server=$(tip_detect_display_server)
    local de_info
    de_info=$(_tip_doctor_detect_de)

    echo -e "\033[1;36m=== TERMINAL IMAGE PASTE (tip) - SYSTEM DIAGNOSTICS ===\033[0m"
    echo ""
    echo -e "\033[1m1. System Environment:\033[0m"
    printf "  %-18s : %s\n" "Operating System" "$os_name"
    printf "  %-18s : %s\n" "Display Server" "$display_server"
    printf "  %-18s : %s\n" "Desktop/Compositor" "$de_info"
    echo ""

    echo -e "\033[1m2. Clipboard Tools:\033[0m"
    if [[ "$display_server" == "wayland" ]]; then
        _tip_doctor_check_cmd "wl-paste" "Wayland clipboard reader" "true"
        _tip_doctor_check_cmd "wl-copy"  "Wayland clipboard writer" "false"
    elif [[ "$display_server" == "x11" ]]; then
        _tip_doctor_check_cmd "xclip" "X11 clipboard CLI" "true"
        _tip_doctor_check_cmd "xsel"  "X11 clipboard CLI (alternative)" "false"
    else
        _tip_doctor_check_cmd "wl-paste" "Wayland clipboard reader" "false"
        _tip_doctor_check_cmd "xclip" "X11 clipboard CLI" "false"
    fi
    echo ""

    echo -e "\033[1m3. Key Injector Tools (Input Simulation):\033[0m"
    if [[ "$display_server" == "wayland" ]]; then
        local is_kwin_or_mutter=false
        if [[ "$de_info" =~ (KDE|Plasma|KWin|GNOME|Mutter) ]]; then
            is_kwin_or_mutter=true
        fi

        if $is_kwin_or_mutter; then
            _tip_doctor_check_cmd "ydotool" "Wayland generic input simulator (Recommended for KDE/GNOME)" "false"
            if command -v ydotool &>/dev/null; then
                if pgrep -x ydotoold &>/dev/null; then
                    printf "  \033[0;32m✔\033[0m %-16s : \033[0;32mRunning\033[0m (Daemon is active)\n" "ydotoold"
                else
                    printf "  \033[0;33m!\033[0m %-16s : \033[0;33mNot running\033[0m (Run 'systemctl --user start ydotoold' or 'sudo ydotoold &')\n" "ydotoold"
                fi
            fi
            _tip_doctor_check_cmd "wtype"   "Wayland virtual keyboard (Unsupported on KWin/Mutter)" "false"
            if command -v wtype &>/dev/null; then
                printf "  \033[0;33m!\033[0m %-16s : \033[0;33mNotice\033[0m (KWin/Mutter lacks zwp_virtual_keyboard_v1 protocol)\n" "wtype note"
            fi
        else
            _tip_doctor_check_cmd "wtype"   "Wayland virtual keyboard (wlroots / Niri)" "true"
            _tip_doctor_check_cmd "ydotool" "Wayland generic input simulator" "false"
        fi
    else
        _tip_doctor_check_cmd "xdotool" "X11 automation tool" "true"
    fi
    echo ""

    echo -e "\033[1m4. Terminal Image Viewers:\033[0m"
    _tip_doctor_check_cmd "timg"   "Terminal Image Viewer (Recommended)" "false"
    _tip_doctor_check_cmd "chafa"  "Terminal Graphics / Sixel Viewer" "false"
    _tip_doctor_check_cmd "viu"    "Simple Terminal Image Viewer" "false"
    _tip_doctor_check_cmd "catimg" "Fast terminal image viewer" "false"
    echo ""

    echo -e "\033[1m5. Directories & Permissions (XDG):\033[0m"
    _tip_doctor_check_dir "${TIP_CONFIG_DIR:-$HOME/.config/tip}" "Configuration"
    _tip_doctor_check_dir "${TIP_STATE_DIR:-$HOME/.local/state/tip}" "Activity logs"
    _tip_doctor_check_dir "${STORAGE_DIR:-/tmp}" "Temporary image cache"
    echo ""
    echo -e "\033[1;32mDiagnostics complete.\033[0m"
}
