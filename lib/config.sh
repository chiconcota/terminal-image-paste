#!/usr/bin/env bash
# lib/config.sh - Configuration management module for Terminal Image Paste (tip)
# Follows XDG Base Directory specification

TIP_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/tip"
TIP_CONFIG_FILE="${TIP_CONFIG_DIR}/config.conf"

tip_config_defaults() {
    PASTE_FORMAT="timg"
    AUTO_ENTER="true"
    CUSTOM_PREFIX="timg"
    STORAGE_DIR="/tmp"
    HOTKEY="<Super><Shift>v"
    FILENAME_FORMAT="timestamp"
    LOG_LEVEL="INFO"
}

tip_config_init() {
    if [[ ! -d "$TIP_CONFIG_DIR" ]]; then
        mkdir -p "$TIP_CONFIG_DIR" 2>/dev/null || true
    fi

    if [[ ! -f "$TIP_CONFIG_FILE" ]]; then
        cat <<'EOF' > "$TIP_CONFIG_FILE"
# Terminal Image Paste Configuration (tip)
# Định dạng dán: path | timg | markdown | custom
PASTE_FORMAT="timg"

# Tự động gõ Enter sau khi dán lệnh (true | false)
AUTO_ENTER="true"

# Lệnh tùy chỉnh khi PASTE_FORMAT="custom" (ví dụ: chafa, viu, catimg)
CUSTOM_PREFIX="timg"

# Thư mục lưu ảnh tạm thời
STORAGE_DIR="/tmp"

# Tổ hợp phím toàn cục (tham khảo khi cài đặt shortcut)
HOTKEY="<Super><Shift>v"

# Quy tắc đặt tên file: timestamp | hash | static
FILENAME_FORMAT="timestamp"

# Mức độ ghi log: DEBUG | INFO | WARN | ERROR
LOG_LEVEL="INFO"
EOF
    fi
}

tip_config_load() {
    tip_config_defaults
    tip_config_init

    if [[ -f "$TIP_CONFIG_FILE" ]]; then
        # Nạp cấu hình an toàn bằng cách đọc từng cặp KEY="VALUE"
        while IFS='=' read -r key val || [[ -n "$key" ]]; do
            # Bỏ qua comment và dòng trống
            [[ "$key" =~ ^[[:space:]]*# ]] && continue
            [[ -z "${key// }" ]] && continue

            # Xóa khoảng trắng thừa và quotes
            key=$(echo "$key" | tr -d '[:space:]')
            val=$(echo "$val" | sed -e 's/^[[:space:]]*"//' -e 's/"[[:space:]]*$//' -e "s/^[[:space:]]*'//" -e "s/'[[:space:]]*$//")

            case "$key" in
                PASTE_FORMAT)    PASTE_FORMAT="$val" ;;
                AUTO_ENTER)      AUTO_ENTER="$val" ;;
                CUSTOM_PREFIX)   CUSTOM_PREFIX="$val" ;;
                STORAGE_DIR)     STORAGE_DIR="$val" ;;
                HOTKEY)          HOTKEY="$val" ;;
                FILENAME_FORMAT) FILENAME_FORMAT="$val" ;;
                LOG_LEVEL)       LOG_LEVEL="$val" ;;
            esac
        done < "$TIP_CONFIG_FILE"
    fi

    # Đảm bảo thư mục lưu trữ tồn tại
    if [[ ! -d "$STORAGE_DIR" ]]; then
        mkdir -p "$STORAGE_DIR" 2>/dev/null || STORAGE_DIR="/tmp"
    fi
}

tip_config_show() {
    echo "Đường dẫn file cấu hình: $TIP_CONFIG_FILE"
    echo "----------------------------------------"
    if [[ -f "$TIP_CONFIG_FILE" ]]; then
        cat "$TIP_CONFIG_FILE"
    else
        echo "Chưa có file cấu hình. Khởi tạo giá trị mặc định..."
        tip_config_init
        cat "$TIP_CONFIG_FILE"
    fi
}
