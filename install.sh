#!/usr/bin/env bash
# install.sh - Automated installer for Terminal Image Paste (tip)
# Supports Arch Linux, Ubuntu/Debian, Fedora, openSUSE

set -e

C_RESET="\033[0m"
C_BOLD="\033[1m"
C_GREEN="\033[32m"
C_YELLOW="\033[33m"
C_BLUE="\033[34m"
C_CYAN="\033[36m"
C_RED="\033[31m"
C_DIM="\033[2m"

info() { echo -e "${C_CYAN}[INFO]${C_RESET} $*"; }
success() { echo -e "${C_GREEN}[OK]${C_RESET} $*"; }
warn() { echo -e "${C_YELLOW}[WARN]${C_RESET} $*"; }
error() { echo -e "${C_RED}[ERROR]${C_RESET} $*" >&2; }

BANNER="${C_CYAN}${C_BOLD}
  ╔═════════════════════════════════════════════════════════════╗
  ║          🖼️   Terminal Image Paste (tip) Installer           ║
  ║      Universal CLI Tool for Wayland & X11 on Linux         ║
  ╚═════════════════════════════════════════════════════════════╝${C_RESET}"

echo -e "$BANNER"

# Detect package manager
detect_pkg_mgr() {
    if command -v pacman &>/dev/null; then
        echo "pacman"
    elif command -v apt-get &>/dev/null; then
        echo "apt"
    elif command -v dnf &>/dev/null; then
        echo "dnf"
    elif command -v zypper &>/dev/null; then
        echo "zypper"
    else
        echo "unknown"
    fi
}

# Determine install locations based on permissions
determine_targets() {
    local mode="${1:-auto}"
    if [[ "$mode" == "system" ]] || [[ "$mode" == "auto" && "$EUID" -eq 0 ]]; then
        BIN_DIR="/usr/local/bin"
        LIB_DIR="/usr/local/lib/tip"
        INSTALL_TYPE="system"
    else
        BIN_DIR="${HOME}/.local/bin"
        LIB_DIR="${HOME}/.local/lib/tip"
        INSTALL_TYPE="user"
    fi
}

# Install missing dependencies prompt
check_dependencies() {
    local pkg_mgr
    pkg_mgr=$(detect_pkg_mgr)
    info "Detected package manager: ${C_BOLD}${pkg_mgr}${C_RESET}"

    local missing_pkgs=()
    local is_wayland=false
    if [[ -n "$WAYLAND_DISPLAY" ]] || [[ "$XDG_SESSION_TYPE" == "wayland" ]]; then
        is_wayland=true
    fi

    # Check clipboard tools
    if $is_wayland; then
        if ! command -v wl-copy &>/dev/null || ! command -v wl-paste &>/dev/null; then
            missing_pkgs+=("wl-clipboard")
        fi
        local de="${XDG_CURRENT_DESKTOP:-$DESKTOP_SESSION}"
        if [[ "$de" =~ (KDE|Plasma|GNOME) ]]; then
            if ! command -v ydotool &>/dev/null; then
                missing_pkgs+=("ydotool")
            fi
        else
            if ! command -v wtype &>/dev/null; then
                missing_pkgs+=("wtype")
            fi
        fi
    else
        if ! command -v xclip &>/dev/null; then
            missing_pkgs+=("xclip")
        fi
        if ! command -v xdotool &>/dev/null; then
            missing_pkgs+=("xdotool")
        fi
    fi

    # Optional image viewer
    if ! command -v timg &>/dev/null && ! command -v chafa &>/dev/null; then
        missing_pkgs+=("timg")
    fi

    if [[ ${#missing_pkgs[@]} -gt 0 ]]; then
        warn "Missing recommended packages: ${C_YELLOW}${missing_pkgs[*]}${C_RESET}"
        echo -e "${C_DIM}You can install them via:${C_RESET}"
        case "$pkg_mgr" in
            pacman)
                echo -e "  ${C_BOLD}sudo pacman -S ${missing_pkgs[*]}${C_RESET}"
                ;;
            apt)
                echo -e "  ${C_BOLD}sudo apt update && sudo apt install ${missing_pkgs[*]}${C_RESET}"
                ;;
            dnf)
                echo -e "  ${C_BOLD}sudo dnf install ${missing_pkgs[*]}${C_RESET}"
                ;;
            zypper)
                echo -e "  ${C_BOLD}sudo zypper install ${missing_pkgs[*]}${C_RESET}"
                ;;
            *)
                echo -e "  ${C_BOLD}Install packages manually: ${missing_pkgs[*]}${C_RESET}"
                ;;
        esac
        echo ""
    else
        success "All recommended dependencies are installed!"
    fi
}

do_uninstall() {
    info "Uninstalling Terminal Image Paste (tip)..."
    local removed=false

    for b in "/usr/local/bin/tip" "${HOME}/.local/bin/tip"; do
        if [[ -f "$b" ]]; then
            rm -f "$b"
            success "Removed binary: $b"
            removed=true
        fi
    done

    for l in "/usr/local/lib/tip" "${HOME}/.local/lib/tip"; do
        if [[ -d "$l" ]]; then
            rm -rf "$l"
            success "Removed libraries: $l"
            removed=true
        fi
    done

    if $removed; then
        success "tip has been cleanly uninstalled."
    else
        warn "No previous tip installation found to remove."
    fi
    exit 0
}

do_install() {
    local script_dir
    script_dir="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"

    # If running from curl pipe, clone repository into temporary directory
    local temp_repo=""
    if [[ ! -f "${script_dir}/bin/tip" ]] || [[ ! -d "${script_dir}/lib" ]]; then
        info "Source repository not detected locally. Cloning latest release..."
        temp_repo=$(mktemp -d /tmp/tip_install_XXXXXX)
        git clone --depth 1 "https://github.com/chiconcota/terminal-image-paste.git" "$temp_repo"
        script_dir="$temp_repo"
    fi

    determine_targets "$MODE"
    info "Installing in ${C_BOLD}${INSTALL_TYPE}${C_RESET} mode:"
    info "  Binary destination:    ${C_BOLD}${BIN_DIR}/tip${C_RESET}"
    info "  Libraries destination: ${C_BOLD}${LIB_DIR}/${C_RESET}"

    # Create destination directories
    mkdir -p "$BIN_DIR" "$LIB_DIR"

    # Copy binary
    install -m 755 "${script_dir}/bin/tip" "${BIN_DIR}/tip"
    success "Installed binary -> ${BIN_DIR}/tip"

    # Copy library scripts
    for f in "${script_dir}/lib"/*.sh; do
        install -m 644 "$f" "${LIB_DIR}/"
    done
    success "Installed libraries -> ${LIB_DIR}/"

    # Cleanup temp repo if used
    if [[ -n "$temp_repo" && -d "$temp_repo" ]]; then
        rm -rf "$temp_repo"
    fi

    # Check PATH if user mode
    if [[ "$INSTALL_TYPE" == "user" ]]; then
        if [[ ":$PATH:" != *":${BIN_DIR}:"* ]]; then
            warn "${BIN_DIR} is not in your current PATH!"
            echo -e "${C_DIM}Add this to your shell profile (~/.bashrc, ~/.zshrc, or ~/.config/fish/config.fish):${C_RESET}"
            echo -e "  ${C_BOLD}export PATH=\"\$HOME/.local/bin:\$PATH\"${C_RESET}\n"
        fi
    fi

    echo ""
    success "${C_BOLD}Terminal Image Paste (tip) successfully installed!${C_RESET}"
    echo "---------------------------------------------------------"

    # Check dependencies and run diagnostics
    check_dependencies
    echo ""
    info "Running system diagnostics (tip doctor):"
    echo ""
    "${BIN_DIR}/tip" doctor || true

    echo ""
    echo -e "${C_GREEN}${C_BOLD}QUICK START:${C_RESET}"
    echo -e "  1. Configure format: ${C_CYAN}tip config${C_RESET}"
    echo -e "  2. Test paste:       ${C_CYAN}tip paste${C_RESET}"
    echo -e "  3. View diagnostics: ${C_CYAN}tip doctor${C_RESET}"
    echo ""
}

MODE="auto"
for arg in "$@"; do
    case "$arg" in
        --uninstall|-u)
            do_uninstall
            ;;
        --system|-s)
            MODE="system"
            ;;
        --user)
            MODE="user"
            ;;
        --help|-h)
            echo "Usage: ./install.sh [OPTIONS]"
            echo "Options:"
            echo "  --system, -s       Install system-wide into /usr/local/bin (requires sudo)"
            echo "  --user             Install for current user only into ~/.local/bin"
            echo "  --uninstall, -u    Remove installed binary and libraries"
            echo "  --help, -h         Show this help screen"
            exit 0
            ;;
        *)
            ;;
    esac
done

do_install
