#!/usr/bin/env bash
# lib/clipboard.sh - Clipboard inspection and image extraction engine
# Supports Wayland (wl-clipboard) and X11 (xclip/xsel)

tip_detect_display_server() {
    if [[ -n "$WAYLAND_DISPLAY" ]] || [[ "$XDG_SESSION_TYPE" == "wayland" ]]; then
        echo "wayland"
    elif [[ -n "$DISPLAY" ]] || [[ "$XDG_SESSION_TYPE" == "x11" ]]; then
        echo "x11"
    else
        echo "unknown"
    fi
}

_tip_generate_filename() {
    local format="${FILENAME_FORMAT:-timestamp}"
    case "$format" in
        hash)
            local rand_hash
            rand_hash=$(date +%s%N | sha256sum | cut -c1-12)
            echo "clip_${rand_hash}.png"
            ;;
        static)
            echo "clipboard.png"
            ;;
        timestamp|*)
            local ts
            ts=$(date '+%Y%m%d_%H%M%S')
            echo "clip_${ts}.png"
            ;;
    esac
}

_tip_get_image_mime_wayland() {
    if ! command -v wl-paste &>/dev/null; then
        return 1
    fi
    local types
    types=$(wl-paste --list-types 2>/dev/null)
    for mime in "image/png" "image/jpeg" "image/webp" "image/bmp"; do
        if echo "$types" | grep -qx "$mime"; then
            echo "$mime"
            return 0
        fi
    done
    return 1
}

_tip_get_image_mime_x11() {
    if ! command -v xclip &>/dev/null; then
        return 1
    fi
    local targets
    targets=$(xclip -selection clipboard -t TARGETS -o 2>/dev/null)
    for mime in "image/png" "image/jpeg" "image/bmp"; do
        if echo "$targets" | grep -qx "$mime"; then
            echo "$mime"
            return 0
        fi
    done
    return 1
}

tip_clipboard_extract() {
    local display_server
    display_server=$(tip_detect_display_server)
    local target_dir="${STORAGE_DIR:-/tmp}"
    local filename
    filename=$(_tip_generate_filename)
    local target_file="${target_dir}/${filename}"

    if [[ "$display_server" == "wayland" ]]; then
        local mime
        mime=$(_tip_get_image_mime_wayland)
        if [[ -z "$mime" ]]; then
            tip_log_warn "Không tìm thấy dữ liệu ảnh trong Wayland clipboard."
            echo "Lỗi: Clipboard không chứa dữ liệu hình ảnh (hoặc thiếu wl-paste)." >&2
            return 1
        fi

        if wl-paste --type "$mime" > "$target_file" 2>/dev/null && [[ -s "$target_file" ]]; then
            tip_log_info "Trích xuất ảnh thành công (Wayland): $target_file [MIME: $mime]"
            echo "$target_file"
            return 0
        fi
    elif [[ "$display_server" == "x11" ]]; then
        local mime
        mime=$(_tip_get_image_mime_x11)
        if [[ -z "$mime" ]]; then
            tip_log_warn "Không tìm thấy dữ liệu ảnh trong X11 clipboard."
            echo "Lỗi: Clipboard không chứa dữ liệu hình ảnh (hoặc thiếu xclip)." >&2
            return 1
        fi

        if xclip -selection clipboard -t "$mime" -o > "$target_file" 2>/dev/null && [[ -s "$target_file" ]]; then
            tip_log_info "Trích xuất ảnh thành công (X11): $target_file [MIME: $mime]"
            echo "$target_file"
            return 0
        fi
    else
        tip_log_error "Không thể nhận diện Display Server (Wayland hoặc X11)."
        echo "Lỗi: Môi trường không có WAYLAND_DISPLAY hoặc DISPLAY." >&2
        return 1
    fi

    rm -f "$target_file" 2>/dev/null || true
    tip_log_error "Thất bại khi ghi dữ liệu ảnh ra $target_file."
    echo "Lỗi: Không thể trích xuất dữ liệu ảnh ra file." >&2
    return 1
}
