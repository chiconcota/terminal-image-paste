# Terminal Image Paste (`tip`)

> 🖼️ **Quickly paste images from your clipboard directly into the terminal on Linux (Wayland & X11).**

`tip` is a fast, modular, zero-popup command-line utility and TUI application that bridges the gap between your desktop clipboard and your terminal workflow.

---

## ✨ Features

- ⚡ **Instant Paste Workflow:** Copy an image from your browser, screenshot tool, or file manager, then paste it immediately into your terminal using a global hotkey or command.
- 🖥️ **Universal Linux Support:**
  - **Wayland:** Native support via `wl-clipboard` (`wl-paste`) and `wtype` (or `ydotool`).
  - **X11:** Native support via `xclip` / `xsel` and `xdotool`.
- 🖼️ **Flexible Terminal Renderers:**
  - `timg`: High-resolution graphics protocol rendering (Kitty, Sixel, iTerm2 graphics).
  - `path`: Paste the file path directly (`/tmp/clipboard.png`).
  - `custom`: Use any custom image viewer (e.g. `chafa`, `viu`, `catimg`).
- 🧠 **Zero-RAM Bloat:** Defaults to static cache mode (`/tmp/clipboard.png`), overwriting the previous image so your `tmpfs` (RAM) never accumulates junk files.
- 🎛️ **Interactive TUI Setup:** Built-in pure Bash/ANSI terminal menu (`tip config`) to configure formats, auto-enter, logging, and keybindings with zero external dependencies.
- 🩺 **Zero-Popup Diagnostics:** Clean terminal diagnostics via `tip doctor` and self-rotating activity logs (`tip log`, max 500 lines) without annoying desktop popups.
- ⌨️ **Safe & Clean Keybinding Integration:** Built-in copy-paste snippet guides (`tip shortcut`) for Niri, Hyprland, Sway, i3, KDE Plasma, GNOME, and Openbox without risking syntax errors in your personal dotfiles.

---

## 🚀 Installation & Quick Start

### Option 1: Arch Linux (AUR)

If you are using Arch Linux, Manjaro, or any Arch-based distro, install via your preferred AUR helper:

```bash
# Using paru
paru -S terminal-image-paste-git

# Using yay
yay -S terminal-image-paste-git
```

### Option 2: Automated 1-Line Installer (Arch, Ubuntu/Debian, Fedora)

The automated script auto-detects your distribution, checks dependencies, and installs `tip`:

```bash
curl -sSL https://raw.githubusercontent.com/chiconcota/terminal-image-paste/main/install.sh | bash
```

Or clone and run locally:

```bash
git clone https://github.com/chiconcota/terminal-image-paste.git
cd terminal-image-paste

# Install for current user (~/.local/bin)
./install.sh --user

# Or install system-wide (requires sudo)
sudo ./install.sh --system
```

To uninstall at any time:
```bash
./install.sh --uninstall
```

### 2. Verify Dependencies

Run the built-in system doctor to verify required tools:

```bash
tip doctor
```

**Recommended dependencies for your distro:**
- **Arch Linux:** `sudo pacman -S wl-clipboard wtype timg` (Wayland) or `sudo pacman -S xclip xdotool timg` (X11)
- **Debian / Ubuntu:** `sudo apt install wl-clipboard wtype timg` (Wayland) or `sudo apt install xclip xdotool` (X11)
- **Fedora:** `sudo dnf install wl-clipboard wtype timg` (Wayland)

### 3. Configure

Launch the interactive TUI configuration menu:

```bash
tip config
```

Select your desired paste format (`timg`, `path`, or `custom`), toggle auto-enter, and choose your preferred shortcut.

---

## 📖 Command Reference

| Command | Description |
| :--- | :--- |
| `tip paste` | Extract image from clipboard, format, and type into active terminal |
| `tip config` | Open interactive TUI configuration menu |
| `tip config show` | Print contents of `~/.config/tip/config.conf` |
| `tip config set <KEY> <VAL>` | Update configuration key directly from CLI |
| `tip config path` | Print absolute path to configuration file |
| `tip config edit` | Open configuration file in `$EDITOR` |
| `tip shortcut [wm\|all]` | Display copy-paste keybinding snippets for your window manager |
| `tip doctor` | Run comprehensive system and environment diagnostics |
| `tip log` | View last 30 activity log lines |
| `tip log -f` | Stream activity logs in realtime |
| `tip status` | Show current configuration and environment summary |
| `tip help` | Display help screen |
| `tip version` | Display version information |

---

## ⌨️ Desktop Keybinding Setup

`tip` executes via the single command `tip paste`. You only need to bind this command to your preferred shortcut in your window manager or desktop environment.

To view setup snippets directly in your terminal at any time, run:
```bash
# Auto-detect your current environment
tip shortcut

# Or display snippets for all environments
tip shortcut all
```

### Niri (`~/.config/niri/config.kdl`)
Add inside your `binds { ... }` block:
```kdl
binds {
    Ctrl+Super+V { spawn "tip" "paste"; }
}
```

---

### Hyprland

**Standard Hyprland (`~/.config/hypr/hyprland.conf`):**
```ini
bind = SUPER CTRL, V, exec, tip paste
```

**CachyOS Noctalia Lua (`~/.config/hypr/config/binds.lua`):**
```lua
hl.bind("SUPER CTRL", "V", "exec", "tip paste")
```

---

### Sway / i3 (`~/.config/sway/config` or `~/.config/i3/config`)
```ini
bindsym $mod+Ctrl+v exec tip paste
```

---

### KDE Plasma (KWin)
1. Open **System Settings** ➔ **Shortcuts** ➔ Click **Add New** ➔ **Command or Script**.
2. Set Name: `Terminal Image Paste`
3. Set Command: `tip paste`
4. Assign shortcut: `Meta+Ctrl+V` (or `Meta+Shift+V`) and click **Apply**.

> **Note for KDE Wayland:** KWin restricts third-party virtual keyboards (`wtype`). Install `ydotool` for automated keystroke injection:
> `sudo pacman -S ydotool && sudo usermod -aG input $USER && systemctl --user enable --now ydotool`

---

### GNOME
1. Open **Settings** ➔ **Keyboard** ➔ **Keyboard Shortcuts** ➔ **Custom Shortcuts (+)**.
2. Set Name: `Terminal Image Paste`
3. Set Command: `tip paste`
4. Assign shortcut: `Super+Ctrl+V` (or `Super+Shift+V`).

> **Note for GNOME Wayland:** Install `ydotool` to allow keystroke injection across Wayland clients:
> `sudo pacman -S ydotool && sudo usermod -aG input $USER && systemctl --user enable --now ydotool`

---

### Openbox / LXDE (`~/.config/openbox/lxde-rc.xml` or `rc.xml`)
Add inside the `<keyboard>` section:
```xml
<keybind key="C-W-v">
  <action name="Execute">
    <command>tip paste</command>
  </action>
</keybind>
```

---

## ⚙️ Configuration (`~/.config/tip/config.conf`)

`tip` adheres strictly to the [XDG Base Directory Specification](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html):
- **Config:** `~/.config/tip/config.conf`
- **Logs:** `~/.local/state/tip/tip.log`

```ini
# Terminal Image Paste Configuration (tip)
PASTE_FORMAT="timg"                  # timg | path | custom
AUTO_ENTER="true"                    # true | false
CUSTOM_PREFIX="timg"                 # chafa | viu | catimg
STORAGE_DIR="/tmp"                   # Temporary image directory
HOTKEY="<Ctrl><Super>v"              # Global desktop shortcut
FILENAME_FORMAT="static"             # static (clipboard.png) | timestamp | hash
LOG_LEVEL="INFO"                     # DEBUG | INFO | WARN | ERROR
```

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
