#!/usr/bin/env bash
# lib/tui.sh - Interactive TUI Setup & Configuration Menu for Terminal Image Paste (tip)
# Pure Bash & ANSI escape codes

# ANSI Color codes
C_RESET="\033[0m"
C_BOLD="\033[1m"
C_CYAN="\033[36m"
C_GREEN="\033[32m"
C_YELLOW="\033[33m"
C_BLUE="\033[34m"
C_MAGENTA="\033[35m"
C_DIM="\033[2m"

tip_tui_header() {
    clear 2>/dev/null || true
    echo -e "${C_CYAN}${C_BOLD}┌─────────────────────────────────────────────────────────────┐${C_RESET}"
    echo -e "${C_CYAN}${C_BOLD}│            🖼️  TERMINAL IMAGE PASTE (tip) - CONFIG           │${C_RESET}"
    echo -e "${C_CYAN}${C_BOLD}│           Interactive Terminal Configuration Menu           │${C_RESET}"
    echo -e "${C_CYAN}${C_BOLD}└─────────────────────────────────────────────────────────────┘${C_RESET}"
    echo ""
}

tip_tui_select_format() {
    tip_tui_header
    echo -e "${C_BOLD}Select default paste format (PASTE_FORMAT):${C_RESET}"
    echo -e "  ${C_DIM}Current: ${C_GREEN}${PASTE_FORMAT}${C_RESET}\n"
    echo -e "  ${C_CYAN}[1]${C_RESET} ${C_BOLD}timg${C_RESET}     - View image directly in terminal using 'timg <path>'"
    echo -e "  ${C_CYAN}[2]${C_RESET} ${C_BOLD}path${C_RESET}     - Paste image file path only (/tmp/clipboard.png)"
    echo -e "  ${C_CYAN}[3]${C_RESET} ${C_BOLD}custom${C_RESET}   - Custom image viewer command (${CUSTOM_PREFIX:-chafa})"
    echo -e "  ${C_DIM}[0] Back to main menu${C_RESET}"
    echo ""
    read -r -p "👉 Enter choice [0-3]: " choice

    case "$choice" in
        1) tip_config_set "PASTE_FORMAT" "timg" ;;
        2) tip_config_set "PASTE_FORMAT" "path" ;;
        3)
            read -r -p "Enter custom command prefix (e.g. chafa, viu, catimg): " custom_cmd
            if [[ -n "$custom_cmd" ]]; then
                tip_config_set "CUSTOM_PREFIX" "$custom_cmd"
            fi
            tip_config_set "PASTE_FORMAT" "custom"
            ;;
        *) return 0 ;;
    esac
}

tip_tui_toggle_auto_enter() {
    if [[ "$AUTO_ENTER" == "true" ]]; then
        tip_config_set "AUTO_ENTER" "false"
    else
        tip_config_set "AUTO_ENTER" "true"
    fi
}

tip_tui_select_log_level() {
    tip_tui_header
    echo -e "${C_BOLD}Select logging verbosity level (LOG_LEVEL):${C_RESET}"
    echo -e "  ${C_DIM}Current: ${C_GREEN}${LOG_LEVEL}${C_RESET}\n"
    echo -e "  ${C_CYAN}[1]${C_RESET} INFO  - Standard informational messages (Recommended)"
    echo -e "  ${C_CYAN}[2]${C_RESET} DEBUG - Verbose messages for troubleshooting"
    echo -e "  ${C_CYAN}[3]${C_RESET} WARN  - Warnings and errors only"
    echo -e "  ${C_CYAN}[4]${C_RESET} ERROR - Critical errors only"
    echo -e "  ${C_DIM}[0] Back${C_RESET}"
    echo ""
    read -r -p "👉 Enter choice [0-4]: " choice

    case "$choice" in
        1) tip_config_set "LOG_LEVEL" "INFO" ;;
        2) tip_config_set "LOG_LEVEL" "DEBUG" ;;
        3) tip_config_set "LOG_LEVEL" "WARN" ;;
        4) tip_config_set "LOG_LEVEL" "ERROR" ;;
        *) return 0 ;;
    esac
}

tip_tui_select_hotkey() {
    tip_tui_header
    echo -e "${C_BOLD}Configure global hotkey (HOTKEY):${C_RESET}"
    echo -e "  ${C_DIM}Current: ${C_YELLOW}${C_BOLD}${HOTKEY}${C_RESET}\n"
    echo -e "  ${C_CYAN}[1]${C_RESET} ${C_BOLD}<Ctrl><Super>v${C_RESET}    - Default (Recommended, avoids desktop conflicts)"
    echo -e "  ${C_CYAN}[2]${C_RESET} ${C_BOLD}<Super><Shift>v${C_RESET}   - Common on Linux desktops"
    echo -e "  ${C_CYAN}[3]${C_RESET} ${C_BOLD}<Ctrl><Alt>v${C_RESET}      - Traditional key combination"
    echo -e "  ${C_CYAN}[4]${C_RESET} ${C_BOLD}Enter custom shortcut...${C_RESET}"
    echo -e "  ${C_DIM}[0] Back to main menu${C_RESET}"
    echo ""
    read -r -p "👉 Enter choice [0-4]: " choice

    local chosen_hotkey=""
    case "$choice" in
        1) chosen_hotkey="<Ctrl><Super>v" ;;
        2) chosen_hotkey="<Super><Shift>v" ;;
        3) chosen_hotkey="<Ctrl><Alt>v" ;;
        4)
            echo ""
            echo -e "${C_CYAN}${C_BOLD}Enter the shortcut you wish to assign:${C_RESET}"
            echo -e "${C_YELLOW}⚠ Note:${C_RESET} The ${C_BOLD}Super${C_RESET} key is handled by your window manager; terminals cannot capture it directly."
            echo -e "  If using ${C_BOLD}Super${C_RESET}, please ${C_GREEN}${C_BOLD}type it as text${C_RESET} (e.g. ${C_CYAN}Ctrl+Super+B${C_RESET}, ${C_CYAN}Super+Shift+V${C_RESET}, ${C_CYAN}<Ctrl><Super>b${C_RESET})."
            echo -e "${C_DIM}  For Ctrl/Alt combinations (e.g. Ctrl+B, Alt+V), you may type text or press the keys directly.${C_RESET}"
            echo ""
            read -r -p "👉 Custom hotkey: " custom_key
            if [[ -n "$custom_key" ]]; then
                chosen_hotkey=$(tip_decode_csi_u "$custom_key")
            else
                echo -e "${C_YELLOW}No hotkey entered. Keeping previous value.${C_RESET}"
                sleep 1
                return 0
            fi
            ;;
        *) return 0 ;;
    esac

    if [[ -n "$chosen_hotkey" ]]; then
        tip_config_set "HOTKEY" "$chosen_hotkey"
        echo -e "\n${C_GREEN}✔ Saved new shortcut: ${C_BOLD}${chosen_hotkey}${C_RESET}"

        # Determine desktop environment name for user-friendly prompt
        local de_name="Window Manager"
        local de="${XDG_CURRENT_DESKTOP:-$DESKTOP_SESSION}"
        if pgrep -x "gnome-shell" &>/dev/null || [[ "$de" =~ (GNOME|Mutter) ]]; then
            de_name="GNOME Shortcuts"
        elif pgrep -x "kwin_wayland" &>/dev/null || pgrep -x "kwin_x11" &>/dev/null || [[ "$de" =~ (KDE|Plasma|KWin) ]]; then
            de_name="KDE Plasma Shortcuts"
        elif pgrep -x "niri" &>/dev/null || [[ "$de" =~ [Nn]iri ]]; then
            de_name="Niri config (config.kdl)"
        elif pgrep -x "Hyprland" &>/dev/null || [[ "$de" =~ [Hh]yprland ]]; then
            de_name="Hyprland config (hyprland.conf)"
        fi

        echo ""
        read -r -p "Automatically register this shortcut in ${de_name}? [Y/n]: " sync_wm
        if [[ -z "$sync_wm" || "$sync_wm" =~ ^[Yy] ]]; then
            echo ""
            if tip_shortcut_install "$chosen_hotkey"; then
                echo -e "${C_GREEN}✔ Successfully registered shortcut in ${de_name}!${C_RESET}"
            else
                echo -e "${C_YELLOW}⚠ Could not register shortcut automatically. You can bind it manually.${C_RESET}"
            fi
            read -r -p "Press Enter to continue..." _
        fi
    fi
}

tip_tui_main_menu() {
    while true; do
        tip_config_load
        tip_tui_header

        echo -e "${C_BOLD}CURRENT CONFIGURATION OPTIONS:${C_RESET}"
        echo -e "  ${C_CYAN}[1]${C_RESET} Output format (PASTE_FORMAT):     ${C_GREEN}${C_BOLD}${PASTE_FORMAT}${C_RESET}"
        echo -e "  ${C_CYAN}[2]${C_RESET} Auto Enter (AUTO_ENTER):          ${C_GREEN}${C_BOLD}${AUTO_ENTER}${C_RESET} ${C_DIM}(Press to toggle true/false)${C_RESET}"
        echo -e "  ${C_CYAN}[3]${C_RESET} Global shortcut (HOTKEY):         ${C_YELLOW}${C_BOLD}${HOTKEY}${C_RESET}"
        echo -e "  ${C_CYAN}[4]${C_RESET} Logging level (LOG_LEVEL):        ${C_GREEN}${C_BOLD}${LOG_LEVEL}${C_RESET}"
        echo -e "  ${C_CYAN}[5]${C_RESET} Temporary directory (STORAGE):    ${C_DIM}${STORAGE_DIR}${C_RESET}"
        echo -e "  ─────────────────────────────────────────────────────────────"
        echo -e "  ${C_CYAN}[6]${C_RESET} 🩺 Run system diagnostics (tip doctor)"
        echo -e "  ${C_CYAN}[7]${C_RESET} 📜 View activity logs (tip log)"
        echo -e "  ${C_DIM}[0] 🚪 Save & Exit${C_RESET}"
        echo ""
        read -r -p "👉 Select an option to configure [0-7]: " menu_choice

        case "$menu_choice" in
            1) tip_tui_select_format ;;
            2) tip_tui_toggle_auto_enter ;;
            3) tip_tui_select_hotkey ;;
            4) tip_tui_select_log_level ;;
            5)
                echo ""
                read -r -p "Enter image storage path (default /tmp): " new_storage
                if [[ -n "$new_storage" ]]; then
                    tip_config_set "STORAGE_DIR" "$new_storage"
                fi
                ;;
            6)
                clear 2>/dev/null || true
                tip_run_doctor || true
                echo ""
                read -r -p "Press Enter to return to menu..." _
                ;;
            7)
                clear 2>/dev/null || true
                tip_show_logs -n 25 || true
                echo ""
                read -r -p "Press Enter to return to menu..." _
                ;;
            0|q|Q)
                echo -e "\n${C_GREEN}Configuration saved. Goodbye!${C_RESET}\n"
                break
                ;;
            *)
                ;;
        esac
    done
}
