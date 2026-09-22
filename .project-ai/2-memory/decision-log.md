# [ARCHITECTURAL PILLARS & DECISION LOG]
> File này ghi nhận các nguyên tắc kiến trúc cốt lõi và lịch sử các quyết định kỹ thuật lớn của dự án.
> Các quyết định mới được chốt/triển khai sẽ được chèn lên đầu phần nhật ký theo ngày tháng.

---

## 1. NGUYÊN TẮC KIẾN TRÚC CỐT LÕI (CORE PRINCIPLES)
- **1. Universal Linux Display Support (Wayland & X11):** Tự động phân giải session type để gọi đúng backend (`wl-clipboard` / `wtype` vs `xclip` / `xdotool`).
- **2. Modular & Decoupled Architecture:** Tách biệt rõ các tầng trong `lib/`: Clipboard Engine, Formatter, Injector, Config, Logger, Doctor, TUI, Shortcut Manager.
- **3. Pure Terminal Diagnostics (Zero-Popup):** Không dùng popup desktop (`notify-send`). Mọi hoạt động và lỗi đều ghi vào `~/.local/state/tip/tip.log`, kiểm tra trực tiếp qua `tip log` và `tip doctor`.
- **4. Standard XDG Directory Compliance:** File cấu hình tại `~/.config/tip/config.conf`, file log tại `~/.local/state/tip/tip.log`.
- **5. User-Centric Customization:** Cung cấp TUI cài đặt (`tip config`) cho phép chọn phím tắt và định dạng đầu ra (Raw Path, `timg <path>`, Markdown, Custom).

---

## 2. NHẬT KÝ QUYẾT ĐỊNH (DECISION LOG)

### 2026-09-22 - 🟢 Tối ưu ydotool Clipboard Paste & Cấu hình Ubuntu GNOME Wayland
- **Bối cảnh:**
  1. Khi kiểm thử trên Ubuntu 26.04 (GNOME Wayland), `tip paste` gặp lỗi dính prompt và lặp đường dẫn 2 lần (`/tmp/clipboard.pngchiconcota@...:~$ /tmp/clipboard.png`).
  2. Nguyên nhân: `ydotool type` gõ từng ký tự trả về mã lỗi sau khi gõ, khiến hàm injector lầm tưởng thất bại và chạy tiếp nhánh fallback stdout (`printf "%s"`). Đồng thời lệnh `printf` thiếu ký tự xuống dòng khiến prompt của shell bị dính liền vào chuỗi đường dẫn.
  3. GNOME Shell không tự nạp `~/.local/bin` trong môi trường custom shortcuts; và `/dev/uinput` trên Ubuntu yêu cầu cấp quyền udev.
- **Quyết định:**
  1. **Chuyển `ydotool` sang Clipboard Paste:** Cho `ydotool` phát phím tắt `Ctrl+Shift+V` (`ydotool key 29:1 42:1 47:1 47:0 42:0 29:0`) kèm `sleep 0.2` nhả phím vật lý. Dán tức thì 0ms, thành công ngay lập tức và triệt tiêu 100% nhánh fallback.
  2. **Chuẩn hóa Fallback Stdout:** Dùng `echo "$text"` (có xuống dòng `\n`) thay cho `printf`.
  3. **Cập nhật tài liệu & Shortcut Guide:** Nêu rõ command `~/.local/bin/tip paste` khi cài user mode và bổ sung hướng dẫn cấp quyền udev cho `/dev/uinput`.

### 2026-09-22 - 🟢 Chuyển đổi toàn diện sang Shortcut Setup Guide & Không can thiệp Dotfiles
- **Bối cảnh:**
  1. Việc tự động parse và chèn phím tắt vào file cấu hình của Window Manager (kể cả với Niri `config.kdl` hay KDE/GNOME/Openbox) tiềm ẩn rủi ro cao làm lỗi syntax hoặc hỏng định dạng dotfiles cá nhân của người dùng.
  2. Việc bắt phím trong terminal TUI (nhất là với phím Super/Windows key và các mã escape CSI u) phức tạp, dễ gây hiểu lầm và bối rối cho người dùng.
  3. Người dùng đề xuất: Bỏ hẳn mục tự động gán keybind trong TUI; tool chỉ cần thực thi tốt chức năng dán ảnh (`tip paste`) và cung cấp hướng dẫn snippet rõ ràng để người dùng tự gán theo ý mình.
- **Quyết định:**
  1. **Loại bỏ tính năng Auto-Install dotfiles:** Xóa toàn bộ logic tự động ghi file cấu hình trong `lib/shortcut.sh`.
  2. **Tái cấu trúc thành Shortcut Guide:**
     - Cung cấp tính năng tự nhận diện môi trường (`tip_detect_wm`) và in snippet mẫu chuẩn xác cho Niri, Hyprland (Standard & Lua: `hl.bind(mainMod .. " + CONTROL + V", hl.dsp.exec_cmd("tip paste"))`), Sway, i3, KDE Plasma, GNOME, Openbox.
     - Lệnh CLI: `tip shortcut [wm|all]` hoặc `tip guide [wm|all]`.
     - Menu TUI mục `[3]`: Đổi thành `📖 Shortcut Setup Guide (How to bind hotkey)`, cho phép xem hướng dẫn theo môi trường hiện tại hoặc toàn bộ.
  3. **Tài liệu hóa:** Cập nhật `README.md` với các khối snippet trực quan, dễ copy-paste.

### 2026-09-21 - 🟢 Tương thích Hyprland 0.56+ (Lua Dispatcher) & Tinh giản Phím tắt (Chỉ Auto-Install cho Niri)
- **Bối cảnh:**
  1. Khi kiểm thử trên CachyOS Hyprland (Wayland), chạy `tip paste` lại kích hoạt trình giám sát hệ thống `btop` thay vì dán ảnh.
  2. Nguyên nhân: `wtype -k v` trên Hyprland bị ánh xạ nhầm thành scancode 1 (`KEY_ESC`). Kết hợp với modifiers `Ctrl+Shift`, Hyprland nhận diện `Ctrl+Shift+Escape`, vốn là phím tắt mặc định mở `btop` trên CachyOS.
  3. Cú pháp dispatcher cũ `hyprctl dispatch sendshortcut "..."` bị lỗi cú pháp trên Hyprland 0.56+ chạy runtime Lua IPC.
  4. Việc tự động chèn phím tắt vào dotfiles phức tạp của nhiều WM (như file Lua `binds.lua` của Noctalia/CachyOS hay hyprland.conf) tiềm ẩn rủi ro phá vỡ cấu hình người dùng.
- **Quyết định:**
  1. **Native Lua Dispatcher cho Hyprland (`lib/injector.sh`):**
     - Đưa lệnh native dispatcher `hyprctl dispatch 'hl.dsp.send_shortcut({ mods = "CTRL SHIFT", key = "v" })' &>/dev/null` lên ưu tiên số 1 khi phát hiện Hyprland.
     - Cách ly hoàn toàn, không bao giờ rơi vào `wtype` khi ở môi trường Hyprland để triệt tiêu vĩnh viễn lỗi scancode `btop`.
  2. **Tinh giản phạm vi Auto-Install phím tắt (`lib/shortcut.sh` & `lib/tui.sh`):**
     - **Chỉ tự động cài đặt cho Niri:** Niri có cấu trúc KDL chuẩn tắc, an toàn và đồng nhất (`~/.config/niri/config.kdl`).
     - **Compositor/DE khác:** Không tự ý ghi đè file config của người dùng; thay vào đó, in đoạn snippet hướng dẫn (`tip_shortcut_show_manual_guide`) rõ ràng, sạch sẽ để người dùng tự copy vào file cấu hình.

### 2026-09-21 - 🟢 Tương thích LXDE (Openbox), Sửa lỗi Key Grab X11 & Tự động gán Phím tắt
- **Bối cảnh:**
  1. Khi kiểm thử trên CachyOS LXDE (X11), phím tắt toàn cục trong `lxhotkey` gọi `tip paste` nhưng terminal không dán được.
  2. Nguyên nhân: `sleep 0.05` quá ngắn (50ms). Khi người dùng bấm tổ hợp 3 phím (`Shift+Super+V`), Openbox kích hoạt `XGrabKeyboard` chiếm toàn quyền bàn phím. `xdotool` gửi phím dán khi người dùng chưa kịp nhả tay nên sự kiện bị Openbox nuốt mất.
  3. `tip config` chưa có adapter tự động đăng ký phím tắt cho môi trường LXDE / Openbox.
- **Quyết định:**
  1. **Nâng độ trễ nhả phím X11 (`lib/injector.sh`):** Tăng sleep lên `0.25s` trước khi `xdotool` gửi phím dán `ctrl+shift+v`, đảm bảo Openbox đã nhả key grab. Đồng thời sao chép dữ liệu vào cả `clipboard` và `primary selection` của `xclip`.
  2. **Adapter phím tắt LXDE / Openbox (`lib/shortcut.sh`):**
     - Hàm `tip_shortcut_to_openbox()` chuyển đổi hotkey sang chuẩn Openbox XML: `<Super><Shift>v` ➔ `W-S-v`, `<Ctrl><Super>v` ➔ `C-W-v`.
     - Hàm `tip_shortcut_install_lxde()` chèn/cập nhật thẻ `<keybind>` có comment đánh dấu `<!-- [tip-shortcut] -->` trong `~/.config/openbox/lxde-rc.xml` (hoặc `rc.xml`), kèm lệnh reload tức thì `openbox --reconfigure`.
  3. **Cập nhật nhận diện TUI & Doctor:** Bổ sung nhận diện `LXDE / Openbox` trong `lib/tui.sh` và `lib/doctor.sh`.

### 2026-09-21 - 🟢 Tương thích KDE Plasma (KWin) & GNOME (Mutter), Fallback ydotool & Phím tắt Tự động
- **Bối cảnh:**
  1. Khi kiểm thử trên CachyOS KDE Plasma (Wayland), `wtype` thất bại do KWin không hỗ trợ `zwp_virtual_keyboard_v1`. Tuy nhiên code cũ nuốt mã lỗi (`2>/dev/null`) và `return 0` giả, khiến `tip paste` im lặng kết thúc và fish shell in prompt `~`.
  2. Phím tắt chưa hỗ trợ tự động gán cho KDE Plasma và GNOME.
  3. `bin/tip` ưu tiên nạp `/usr/lib/tip` trước `${HOME}/.local/lib/tip`, gây xung đột khi cài dual-mode.
- **Quyết định:**
  1. **Bắt mã lỗi wtype & Multi-level Fallback:** Kiểm tra chặt chẽ exit code của `wtype`. Luôn nạp dữ liệu vào `wl-copy` trước, sau đó fallback sang `ydotool` (kernel uinput), và cuối cùng fallback in ra `stdout`.
  2. **Tự động đăng ký phím tắt KDE & GNOME:**
     - KDE Plasma: Tạo `tip-paste.desktop` kèm cờ `X-KDE-GlobalAccel-CommandShortcut=true`, dùng `kwriteconfig6`/`kwriteconfig5` ghi vào `kglobalshortcutsrc` và kích hoạt qua D-Bus KWin.
     - GNOME: Ghi nhận trực tiếp qua `gsettings` custom keybindings, có hiệu lực tức thì 100%.
  3. **Ưu tiên Library Resolution:** Cập nhật `bin/tip` ưu tiên nạp thư viện tương đối (`${SOURCE_DIR}/lib/tip`, `${HOME}/.local/lib/tip`) trước khi tìm đến `/usr/lib/tip`.
  4. **Cập nhật AUR & README:** Bổ sung `ydotool` vào `aur/PKGBUILD` và tài liệu chi tiết cách cấu hình phím tắt cho KDE/GNOME.

### 2026-09-21 - 🟢 Cơ chế Paste Clipboard Injection, Smart Fallback & Trình cài đặt Đa Distro
- **Bối cảnh:** 
  1. `wtype` gõ từng ký tự bị Chromium/Electron (VS Code, Antigravity IDE) nhận nhầm scancode 1 thành Escape (`^[`) và scancode 14 thành Backspace (xóa mất chữ `d`).
  2. Người dùng muốn nhấn phím tắt bất kỳ lúc nào cũng dán được đường dẫn ảnh `/tmp/clipboard.png` mà không bị báo lỗi cứng nhắc khi clipboard tạm thời chưa có ảnh mới.
  3. Cần hỗ trợ cài đặt trên Arch (AUR), Ubuntu/Debian, Fedora và openSUSE.
- **Quyết định:**
  1. **Clipboard Injection:** Chuyển sang cơ chế nạp chuỗi vào `wl-copy` / `xclip` rồi mô phỏng phím `Ctrl+Shift+V` kèm độ trễ `0.1s` nhả phím tắt. Tốc độ dán tức thì (0ms), không lỗi scancode, không xung đột bộ gõ tiếng Việt Fcitx5.
  2. **Smart Fallback:** Khi clipboard không có ảnh mới, tự động tái sử dụng `/tmp/clipboard.png` gần nhất thay vì dừng lại báo lỗi.
  3. **Multi-Distro Installer (`install.sh`):** Tự phát hiện package manager (`pacman`, `apt`, `dnf`, `zypper`), hỗ trợ dual mode (`--system` / `--user`), chạy chẩn đoán `tip doctor` sau cài đặt, hỗ trợ `--uninstall`.
  4. **AUR Package:** Tạo `aur/PKGBUILD` và sinh `aur/.SRCINFO` chuẩn Arch Linux (`terminal-image-paste-git`).
  5. **Dynamic Library Resolution:** Cập nhật `bin/tip` tự động tìm kiếm thư viện tại `/usr/lib/tip`, `/usr/local/lib/tip`, hoặc `~/.local/lib/tip`.

### 2026-09-20 - 🟢 Quốc tế hóa tiếng Anh & Phát hành chính thức lên GitHub
- **Bối cảnh:** Dự án cần sẵn sàng cho cộng đồng mã nguồn mở quốc tế sử dụng.
- **Quyết định:**
  1. Chuyển toàn bộ CLI output, TUI menu, Doctor diagnostics, error messages và log sang tiếng Anh chuẩn.
  2. Tạo `README.md` (hướng dẫn chi tiết, bảng lệnh, phím tắt), `LICENSE` (MIT) và `.gitignore`.
  3. Khởi tạo remote và đẩy toàn bộ nhánh `main` lên GitHub: `https://github.com/chiconcota/terminal-image-paste`.

### 2026-09-20 - 🟢 Chế độ Zero-RAM Bloat & Tinh gọn thuần Terminal
- **Bối cảnh:** Thư mục `/tmp` trên Linux là `tmpfs` (nằm trên RAM). Nếu sinh nhiều file timestamp sẽ gây chiếm dụng RAM. Đồng thời người dùng chỉ cần thao tác trên Terminal, không cần Markdown cho Obsidian.
- **Quyết định:**
  1. Đặt mặc định `FILENAME_FORMAT="static"`, mọi ảnh trích xuất đều lưu đè vào duy nhất `/tmp/clipboard.png`. Đảm bảo mức chiếm dụng RAM vĩnh viễn không vượt quá 2MB.
  2. Loại bỏ tùy chọn `markdown` khỏi `lib/formatter.sh` và bảng TUI, tập trung 100% vào trải nghiệm dòng lệnh (`timg`, `path`, `custom`).

### 2026-09-20 - 🟢 Triển khai TUI Interactive Setup & Shortcut Manager
- **Bối cảnh:** Cần giao diện trực quan cho người dùng cấu hình mà không cần sửa file bằng tay, hỗ trợ tự động bind phím vào Niri.
- **Quyết định:**
  1. Xây dựng `lib/tui.sh` thuần Bash & ANSI escape codes, không phụ thuộc thư viện ngoài.
  2. Tích hợp `tip_decode_csi_u` để giải mã escape sequences từ Ghostty/Kitty (ví dụ: `^[[98;5u` -> `Ctrl+B`), đồng thời hướng dẫn rõ ràng về việc gõ phím `Super`.
  3. Xây dựng `lib/shortcut.sh` dùng `awk` để chèn phím tắt an toàn vào đúng khối `binds` toàn cục của Niri (`~/.config/niri/config.kdl`).
  4. Đổi phím tắt mặc định sang `<Ctrl><Super>v` để tránh xung đột với clipboard history manager.

### 2026-09-20 - 🟢 Triển khai hoàn thiện Core Engine & CLI Pipeline (Phase 1)
- **Bối cảnh & Quyết định:**
  1. Khởi tạo kho lưu trữ Git cục bộ trên nhánh `main`.
  2. Triển khai cấu trúc thư mục mô-đun: `bin/tip` (Entrypoint), `lib/logger.sh` (XDG log + auto rotate 500 lines), `lib/config.sh` (XDG config), `lib/clipboard.sh` (Wayland/X11 clipboard image extraction), `lib/formatter.sh` (Path/timg/Markdown/custom output), `lib/injector.sh` (wtype/xdotool), `lib/doctor.sh` (Zero-popup pure terminal diagnosis).
  3. Xử lý an toàn `set -e` trong bash scripts để các lệnh chẩn đoán tùy chọn không ngắt script bất thường.
  4. Xác nhận tương thích runtime trên Arch Linux + Wayland + Niri Compositor + `timg`.

### 2026-09-19 - 🟢 Quyết định: Loại bỏ Notify-send, Tối ưu hóa kiểm lỗi thuần Terminal
- **Vấn đề:** Popup thông báo màn hình (`notify-send`) gây phiền toái trong quá trình làm việc và làm tăng thêm dependency phụ thuộc thư viện desktop.
- **Quyết định:**
  1. Loại bỏ hoàn toàn `notify-send`.
  2. Tập trung trải nghiệm kiểm lỗi 100% trong terminal qua `tip log` (xem 30 dòng gần nhất), `tip log -f` (realtime) và `tip doctor` (chẩn đoán hệ thống).
  3. Bổ sung `niri` vào danh sách Compositor hỗ trợ phím tắt tự động.

### 2026-09-19 - 🟢 Khởi tạo kiến trúc dự án Terminal Image Paste (`tip`)
- **Decision:** Thiết lập bản đồ hệ thống `system_map.md`, định hình các module trong `lib/`, hỗ trợ đa định dạng đầu ra (Path, `timg`, Markdown) và bảng cài đặt TUI.
