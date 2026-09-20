#!/usr/bin/env bash
# lib/formatter.sh - Output string formatter for Terminal Image Paste (tip)
# Formats file path into path, timg, markdown, or custom command

tip_format_output() {
    local file_path="$1"
    local format="${PASTE_FORMAT:-timg}"
    local custom_cmd="${CUSTOM_PREFIX:-timg}"

    if [[ -z "$file_path" ]]; then
        return 1
    fi

    case "$format" in
        path)
            printf "%s" "$file_path"
            ;;
        timg)
            printf "timg %s" "$file_path"
            ;;
        custom)
            printf "%s %s" "$custom_cmd" "$file_path"
            ;;
        *)
            printf "%s" "$file_path"
            ;;
    esac
}

tip_should_auto_enter() {
    local auto_enter="${AUTO_ENTER:-false}"
    local format="${PASTE_FORMAT:-timg}"

    if [[ "$auto_enter" == "true" ]] && [[ "$format" =~ ^(timg|custom)$ ]]; then
        return 0
    fi
    return 1
}
