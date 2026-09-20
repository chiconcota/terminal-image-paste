#!/usr/bin/env bash
# lib/doctor.sh - System diagnostics and health check module
# Pure terminal output with zero GUI popups

_tip_doctor_check_cmd() {
    local cmd="$1"
    local desc="$2"
    local required="$3"

    if command -v "$cmd" &>/dev/null; then
        printf "  \033[0;32m✔\033[0m %-16s : \033[0;32mĐã cài đặt\033[0m (%s)\n" "$cmd" "$desc"
        return 0
    else
        if [[ "$required" == "true" ]]; then
            printf "  \033[0;31m✘\033[0m %-16s : \033[0;31mChưa cài đặt (Bắt buộc)\033[0m (%s)\n" "$cmd" "$desc"
            return 1
        else
            printf "  \033[0;33m-\033[0m %-16s : \033[0;33mChưa cài đặt (Tùy chọn)\033[0m (%s)\n" "$cmd" "$desc"
            return 0
        fi
    fi
}

_tip_doctor_check_dir() {
    local path="$1"
    local desc="$2"

    if [[ -d "$path" && -w "$path" ]]; then
        printf "  \033[0;32m✔\033[0m %-16s : \033[0;32mHợp lệ & Có quyền ghi\033[0m (%s)\n" "$path" "$desc"
    else
        printf "  \033[0;33m!\033[0m %-16s : \033[0;33mChưa tồn tại hoặc không thể ghi\033[0m (%s)\n" "$path" "$desc"
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
    elif [[ -n "$de" ]]; then
        echo "$de"
    else
        echo "Không xác định (CLI / Custom WM)"
    fi
}

tip_run_doctor() {
    local os_name="Linux"
    [[ -f /etc/os-release ]] && os_name=$(grep -E '^PRETTY_NAME=' /etc/os-release | cut -d= -f2 | tr -d '"')

    local display_server
    display_server=$(tip_detect_display_server)
    local de_info
    de_info=$(_tip_doctor_detect_de)

    echo -e "\033[1;36m=== TERMINAL IMAGE PASTE (tip) - CHẨN ĐOÁN HỆ THỐNG ===\033[0m"
    echo ""
    echo -e "\033[1m1. Môi trường hệ thống:\033[0m"
    printf "  %-18s : %s\n" "Hệ điều hành" "$os_name"
    printf "  %-18s : %s\n" "Display Server" "$display_server"
    printf "  %-18s : %s\n" "Desktop/Compositor" "$de_info"
    echo ""

    echo -e "\033[1m2. Công cụ Clipboard:\033[0m"
    if [[ "$display_server" == "wayland" ]]; then
        _tip_doctor_check_cmd "wl-paste" "Wayland clipboard reader" "true"
        _tip_doctor_check_cmd "wl-copy"  "Wayland clipboard writer" "false"
    elif [[ "$display_server" == "x11" ]]; then
        _tip_doctor_check_cmd "xclip" "X11 clipboard CLI" "true"
        _tip_doctor_check_cmd "xsel"  "X11 clipboard CLI (thay thế)" "false"
    else
        _tip_doctor_check_cmd "wl-paste" "Wayland clipboard reader" "false"
        _tip_doctor_check_cmd "xclip" "X11 clipboard CLI" "false"
    fi
    echo ""

    echo -e "\033[1m3. Công cụ Injector (Mô phỏng gõ phím):\033[0m"
    if [[ "$display_server" == "wayland" ]]; then
        _tip_doctor_check_cmd "wtype"   "Wayland xdotool alternative" "true"
        _tip_doctor_check_cmd "ydotool" "Wayland generic input simulator" "false"
    else
        _tip_doctor_check_cmd "xdotool" "X11 automation tool" "true"
    fi
    echo ""

    echo -e "\033[1m4. Trình xem ảnh Terminal:\033[0m"
    _tip_doctor_check_cmd "timg"   "Terminal Image Viewer (Khuyên dùng)" "false"
    _tip_doctor_check_cmd "chafa"  "Terminal Graphics / Sixel Viewer" "false"
    _tip_doctor_check_cmd "viu"    "Simple Terminal Image Viewer" "false"
    _tip_doctor_check_cmd "catimg" "Fast terminal image viewer" "false"
    echo ""

    echo -e "\033[1m5. Thư mục & Quyền hạn (XDG):\033[0m"
    _tip_doctor_check_dir "${TIP_CONFIG_DIR:-$HOME/.config/tip}" "Cấu hình"
    _tip_doctor_check_dir "${TIP_STATE_DIR:-$HOME/.local/state/tip}" "Nhật ký log"
    _tip_doctor_check_dir "${STORAGE_DIR:-/tmp}" "Lưu ảnh tạm"
    echo ""
    echo -e "\033[1;32mHoàn tất chẩn đoán.\033[0m"
}
