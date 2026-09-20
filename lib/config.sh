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
    HOTKEY="<Ctrl><Super>v"
    FILENAME_FORMAT="static"
    LOG_LEVEL="INFO"
}

tip_config_init() {
    if [[ ! -d "$TIP_CONFIG_DIR" ]]; then
        mkdir -p "$TIP_CONFIG_DIR" 2>/dev/null || true
    fi

    if [[ ! -f "$TIP_CONFIG_FILE" ]]; then
        cat <<'EOF' > "$TIP_CONFIG_FILE"
# Terminal Image Paste Configuration (tip)
# Paste format: timg | path | custom
PASTE_FORMAT="timg"

# Automatically press Enter after pasting command (true | false)
AUTO_ENTER="true"

# Custom command prefix when PASTE_FORMAT="custom" (e.g. chafa, viu, catimg)
CUSTOM_PREFIX="timg"

# Temporary image storage directory
STORAGE_DIR="/tmp"

# Global shortcut (used for desktop keybinding)
HOTKEY="<Ctrl><Super>v"

# Filename pattern: static (clipboard.png) | timestamp | hash
FILENAME_FORMAT="static"

# Log level: DEBUG | INFO | WARN | ERROR
LOG_LEVEL="INFO"
EOF
    fi
}

tip_config_load() {
    tip_config_defaults
    tip_config_init

    if [[ -f "$TIP_CONFIG_FILE" ]]; then
        # Safely read configuration by parsing KEY="VALUE" pairs
        while IFS='=' read -r key val || [[ -n "$key" ]]; do
            # Skip comments and empty lines
            [[ "$key" =~ ^[[:space:]]*# ]] && continue
            [[ -z "${key// }" ]] && continue

            # Strip whitespace and quotes
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

    # Ensure storage directory exists
    if [[ ! -d "$STORAGE_DIR" ]]; then
        mkdir -p "$STORAGE_DIR" 2>/dev/null || STORAGE_DIR="/tmp"
    fi
}

tip_config_show() {
    echo "Configuration file: $TIP_CONFIG_FILE"
    echo "----------------------------------------"
    if [[ -f "$TIP_CONFIG_FILE" ]]; then
        cat "$TIP_CONFIG_FILE"
    else
        echo "No configuration file found. Initializing with defaults..."
        tip_config_init
        cat "$TIP_CONFIG_FILE"
    fi
}

tip_config_set() {
    local key="$1"
    local val="$2"

    if [[ -z "$key" ]]; then
        echo "Error: Missing configuration key." >&2
        return 1
    fi

    tip_config_init

    if grep -q "^[[:space:]]*${key}=" "$TIP_CONFIG_FILE" 2>/dev/null; then
        sed -i "s|^[[:space:]]*${key}=.*|${key}=\"${val}\"|" "$TIP_CONFIG_FILE"
    else
        echo "${key}=\"${val}\"" >> "$TIP_CONFIG_FILE"
    fi

    # Reload into memory
    tip_config_load
}

