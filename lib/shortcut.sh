#!/usr/bin/env bash
# lib/shortcut.sh - Global Shortcut Guide & Snippet Helper for Terminal Image Paste (tip)
# Pure terminal output providing copy-paste configuration snippets for various WMs and DEs

# ANSI Color codes
C_RESET="\033[0m"
C_BOLD="\033[1m"
C_CYAN="\033[36m"
C_GREEN="\033[32m"
C_YELLOW="\033[33m"
C_BLUE="\033[34m"
C_MAGENTA="\033[35m"
C_DIM="\033[2m"

# Detect active Window Manager or Desktop Environment
tip_detect_wm() {
    local de="${XDG_CURRENT_DESKTOP:-$DESKTOP_SESSION}"

    if pgrep -x "niri" &>/dev/null || [[ "$de" =~ [Nn]iri ]]; then
        echo "niri"
    elif pgrep -x "Hyprland" &>/dev/null || [[ "$de" =~ [Hh]yprland ]]; then
        echo "hyprland"
    elif pgrep -x "sway" &>/dev/null || [[ "$de" =~ [Ss]way ]]; then
        echo "sway"
    elif pgrep -x "i3" &>/dev/null || [[ "$de" =~ [iI]3 ]]; then
        echo "i3"
    elif pgrep -x "kwin_wayland" &>/dev/null || pgrep -x "kwin_x11" &>/dev/null || [[ "$de" =~ (KDE|Plasma|KWin) ]]; then
        echo "kde"
    elif pgrep -x "gnome-shell" &>/dev/null || [[ "$de" =~ (GNOME|Mutter) ]]; then
        echo "gnome"
    elif pgrep -x "openbox" &>/dev/null || [[ "$de" =~ (LXDE|Openbox|OPENBOX) ]]; then
        echo "openbox"
    else
        echo "generic"
    fi
}

tip_shortcut_guide_niri() {
    echo -e "${C_CYAN}${C_BOLD}▶ Niri (Scrollable-tiling Wayland Compositor)${C_RESET}"
    echo -e "  File: ${C_YELLOW}~/.config/niri/config.kdl${C_RESET}"
    echo -e "  Add inside your ${C_BOLD}binds { ... }${C_RESET} block:"
    echo ""
    echo -e "${C_GREEN}    Ctrl+Super+V { spawn \"tip\" \"paste\"; }${C_RESET}"
    echo ""
    echo -e "  ${C_DIM}(Reloads automatically upon saving config.kdl)${C_RESET}"
}

tip_shortcut_guide_hyprland() {
    echo -e "${C_CYAN}${C_BOLD}▶ Hyprland${C_RESET}"
    echo -e "  ${C_BOLD}Standard Hyprland:${C_RESET} ${C_YELLOW}~/.config/hypr/hyprland.conf${C_RESET}"
    echo -e "  Add to your keybinds section:"
    echo ""
    echo -e "${C_GREEN}    bind = SUPER CTRL, V, exec, tip paste${C_RESET}"
    echo ""
    echo -e "  ${C_BOLD}CachyOS Noctalia Lua:${C_RESET} ${C_YELLOW}~/.config/hypr/config/binds.lua${C_RESET}"
    echo ""
    echo -e "${C_GREEN}    hl.bind(mainMod .. \" + CONTROL + V\", hl.dsp.exec_cmd(\"tip paste\"))${C_RESET}"
    echo ""
    echo -e "  ${C_DIM}(Hyprland reloads automatically upon saving)${C_RESET}"
}

tip_shortcut_guide_sway() {
    echo -e "${C_CYAN}${C_BOLD}▶ Sway${C_RESET}"
    echo -e "  File: ${C_YELLOW}~/.config/sway/config${C_RESET}"
    echo -e "  Add to your keybindings:"
    echo ""
    echo -e "${C_GREEN}    bindsym \$mod+Ctrl+v exec tip paste${C_RESET}"
    echo ""
    echo -e "  ${C_DIM}(Reload with: swaymsg reload)${C_RESET}"
}

tip_shortcut_guide_i3() {
    echo -e "${C_CYAN}${C_BOLD}▶ i3 Window Manager${C_RESET}"
    echo -e "  File: ${C_YELLOW}~/.config/i3/config${C_RESET}"
    echo -e "  Add to your keybindings:"
    echo ""
    echo -e "${C_GREEN}    bindsym \$mod+Ctrl+v exec tip paste${C_RESET}"
    echo ""
    echo -e "  ${C_DIM}(Reload with: i3-msg reload)${C_RESET}"
}

tip_shortcut_guide_kde() {
    echo -e "${C_CYAN}${C_BOLD}▶ KDE Plasma (KWin)${C_RESET}"
    echo -e "  Configure via System Settings GUI:"
    echo -e "  1. Open ${C_BOLD}System Settings${C_RESET} ➔ ${C_BOLD}Shortcuts${C_RESET} ➔ ${C_BOLD}Custom Shortcuts${C_RESET} (or ${C_BOLD}Shortcuts${C_RESET})"
    echo -e "  2. Click ${C_BOLD}Add New${C_RESET} ➔ ${C_BOLD}Command or Script${C_RESET}"
    echo -e "  3. Name: ${C_GREEN}Terminal Image Paste${C_RESET}"
    echo -e "  4. Command: ${C_GREEN}tip paste${C_RESET}"
    echo -e "  5. Trigger: Assign ${C_YELLOW}Meta+Ctrl+V${C_RESET} (or ${C_YELLOW}Meta+Shift+V${C_RESET}) and click Apply."
}

tip_shortcut_guide_gnome() {
    echo -e "${C_CYAN}${C_BOLD}▶ GNOME (Mutter)${C_RESET}"
    echo -e "  Configure via Settings GUI:"
    echo -e "  1. Open ${C_BOLD}Settings${C_RESET} ➔ ${C_BOLD}Keyboard${C_RESET} ➔ ${C_BOLD}Keyboard Shortcuts${C_RESET} ➔ ${C_BOLD}Custom Shortcuts (+)${C_RESET}"
    echo -e "  2. Name: ${C_GREEN}Terminal Image Paste${C_RESET}"
    echo -e "  3. Command: ${C_GREEN}tip paste${C_RESET}"
    echo -e "  4. Shortcut: Press ${C_YELLOW}Super+Ctrl+V${C_RESET} (or ${C_YELLOW}Super+Shift+V${C_RESET})"
}

tip_shortcut_guide_openbox() {
    echo -e "${C_CYAN}${C_BOLD}▶ Openbox / LXDE${C_RESET}"
    echo -e "  File: ${C_YELLOW}~/.config/openbox/lxde-rc.xml${C_RESET} (or ${C_YELLOW}~/.config/openbox/rc.xml${C_RESET})"
    echo -e "  Add inside the ${C_BOLD}<keyboard>${C_RESET} section:"
    echo ""
    echo -e "${C_GREEN}    <keybind key=\"C-W-v\">${C_RESET}"
    echo -e "${C_GREEN}      <action name=\"Execute\">${C_RESET}"
    echo -e "${C_GREEN}        <command>tip paste</command>${C_RESET}"
    echo -e "${C_GREEN}      </action>${C_RESET}"
    echo -e "${C_GREEN}    </keybind>${C_RESET}"
    echo ""
    echo -e "  ${C_DIM}(Reload with: openbox --reconfigure)${C_RESET}"
}

tip_shortcut_guide_all() {
    echo -e "${C_CYAN}${C_BOLD}═══════════════════════════════════════════════════════════════${C_RESET}"
    echo -e "${C_CYAN}${C_BOLD}       📖 TERMINAL IMAGE PASTE - ALL SHORTCUT SNIPPETS          ${C_RESET}"
    echo -e "${C_CYAN}${C_BOLD}═══════════════════════════════════════════════════════════════${C_RESET}\n"

    tip_shortcut_guide_niri
    echo -e "\n─────────────────────────────────────────────────────────────\n"
    tip_shortcut_guide_hyprland
    echo -e "\n─────────────────────────────────────────────────────────────\n"
    tip_shortcut_guide_sway
    echo -e "\n─────────────────────────────────────────────────────────────\n"
    tip_shortcut_guide_i3
    echo -e "\n─────────────────────────────────────────────────────────────\n"
    tip_shortcut_guide_kde
    echo -e "\n─────────────────────────────────────────────────────────────\n"
    tip_shortcut_guide_gnome
    echo -e "\n─────────────────────────────────────────────────────────────\n"
    tip_shortcut_guide_openbox
    echo ""
}

# Main entrypoint to display shortcut guides
tip_shortcut_show_guide() {
    local target="$1"

    case "${target,,}" in
        all|-a|--all)
            tip_shortcut_guide_all
            return 0
            ;;
        niri)
            echo ""
            tip_shortcut_guide_niri
            echo ""
            return 0
            ;;
        hyprland|hypr)
            echo ""
            tip_shortcut_guide_hyprland
            echo ""
            return 0
            ;;
        sway)
            echo ""
            tip_shortcut_guide_sway
            echo ""
            return 0
            ;;
        i3)
            echo ""
            tip_shortcut_guide_i3
            echo ""
            return 0
            ;;
        kde|plasma|kwin)
            echo ""
            tip_shortcut_guide_kde
            echo ""
            return 0
            ;;
        gnome|mutter)
            echo ""
            tip_shortcut_guide_gnome
            echo ""
            return 0
            ;;
        openbox|lxde)
            echo ""
            tip_shortcut_guide_openbox
            echo ""
            return 0
            ;;
    esac

    # Auto-detect current WM/DE
    local detected
    detected=$(tip_detect_wm)

    echo -e "\n${C_BOLD}📋 Shortcut Setup Guide for your environment:${C_RESET}\n"

    case "$detected" in
        niri)
            tip_shortcut_guide_niri
            ;;
        hyprland)
            tip_shortcut_guide_hyprland
            ;;
        sway)
            tip_shortcut_guide_sway
            ;;
        i3)
            tip_shortcut_guide_i3
            ;;
        kde)
            tip_shortcut_guide_kde
            ;;
        gnome)
            tip_shortcut_guide_gnome
            ;;
        openbox)
            tip_shortcut_guide_openbox
            ;;
        *)
            echo -e "${C_YELLOW}Detected desktop/WM: ${detected}${C_RESET}"
            echo -e "Assign a global keyboard shortcut in your desktop/window manager settings:"
            echo -e "  Command to execute: ${C_GREEN}${C_BOLD}tip paste${C_RESET}"
            echo -e "  Suggested hotkey:   ${C_YELLOW}Ctrl+Super+V${C_RESET} or ${C_YELLOW}Super+Shift+V${C_RESET}"
            ;;
    esac

    echo ""
    echo -e "${C_DIM}💡 Tip: Run '${C_CYAN}tip shortcut all${C_RESET}${C_DIM}' to view configuration snippets for other window managers.${C_RESET}\n"
    return 0
}

# Backward compatibility alias
tip_shortcut_install() {
    tip_shortcut_show_guide "$@"
}
