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

tip_tui_show_shortcut_guide() {
    tip_tui_header
    echo -e "${C_BOLD}SHORTCUT CONFIGURATION GUIDE:${C_RESET}"
    echo -e "${C_DIM}tip does not automatically modify your WM config files to prevent syntax corruption.${C_RESET}"
    echo -e "${C_DIM}Simply bind the command ${C_GREEN}tip paste${C_RESET}${C_DIM} to your preferred key in your WM/DE settings.${C_RESET}\n"

    local detected
    detected=$(tip_detect_wm)

    echo -e "  ${C_CYAN}[1]${C_RESET} View guide for current environment (${C_YELLOW}${detected}${C_RESET})"
    echo -e "  ${C_CYAN}[2]${C_RESET} View snippets for ALL window managers (Niri, Hyprland, Sway, i3, KDE, GNOME, Openbox)"
    echo -e "  ${C_DIM}[0] Back to main menu${C_RESET}"
    echo ""
    read -r -p "👉 Enter choice [0-2]: " guide_choice

    case "$guide_choice" in
        1)
            clear 2>/dev/null || true
            tip_shortcut_show_guide
            echo ""
            read -r -p "Press Enter to return..." _
            ;;
        2)
            clear 2>/dev/null || true
            tip_shortcut_guide_all
            echo ""
            read -r -p "Press Enter to return..." _
            ;;
        *)
            return 0
            ;;
    esac
}

tip_tui_main_menu() {
    while true; do
        tip_config_load
        tip_tui_header

        echo -e "${C_BOLD}CURRENT CONFIGURATION OPTIONS:${C_RESET}"
        echo -e "  ${C_CYAN}[1]${C_RESET} Output format (PASTE_FORMAT):     ${C_GREEN}${C_BOLD}${PASTE_FORMAT}${C_RESET}"
        echo -e "  ${C_CYAN}[2]${C_RESET} Auto Enter (AUTO_ENTER):          ${C_GREEN}${C_BOLD}${AUTO_ENTER}${C_RESET} ${C_DIM}(Press to toggle true/false)${C_RESET}"
        echo -e "  ${C_CYAN}[3]${C_RESET} 📖 Shortcut Setup Guide (How to bind hotkey)"
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
            3) tip_tui_show_shortcut_guide ;;
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
