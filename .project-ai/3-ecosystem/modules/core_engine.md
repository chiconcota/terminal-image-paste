# MODULE ARCHITECTURE: CORE ENGINE & CLI PIPELINE (`tip`)
@module: Core Engine & CLI | @status: 🟢 Done | @last_update: 2026-09-20

---

## 1. TRÁCH NHIỆM CỐT LÕI (RESPONSIBILITIES)
- Cung cấp giao diện CLI thống nhất (`bin/tip`) cho người dùng cuối.
- Tự động nhận diện Display Server (Wayland hoặc X11) và trích xuất ảnh nhị phân từ clipboard sang file tạm trong `$STORAGE_DIR`.
- Định dạng chuỗi xuất phù hợp (`path`, `timg <path>`, )`, `custom`) và mô phỏng gõ phím vào terminal active qua `wtype` hoặc `xdotool`.
- Ghi log chuẩn XDG (`~/.local/state/tip/tip.log`) với cơ chế xoay vòng tối đa 500 dòng (Zero-Popup).
- Cung cấp công cụ chẩn đoán hệ thống toàn diện (`tip doctor`).

---

## 2. INTERFACE & API EXPOSED

### `lib/logger.sh`
- `tip_log_init()`: Khởi tạo thư mục và file log nếu chưa có.
- `tip_log_debug(msg)`, `tip_log_info(msg)`, `tip_log_warn(msg)`, `tip_log_error(msg)`: Ghi log có timestamp, log level và tự động xoay vòng.
- `tip_show_logs [-f] [-n N]`: Hiển thị nhật ký log hoặc theo dõi realtime.

### `lib/config.sh`
- `tip_config_load()`: Nạp cấu hình từ `~/.config/tip/config.conf` (hoặc tạo file mặc định nếu chưa tồn tại).
- `tip_config_show()`: In nội dung cấu hình hiện tại.

### `lib/clipboard.sh`
- `tip_detect_display_server()`: Trả về `"wayland"`, `"x11"`, hoặc `"unknown"`.
- `tip_clipboard_extract()`: Trích xuất ảnh từ clipboard sang `$STORAGE_DIR`. Nếu clipboard không chứa ảnh mới, tự động kích hoạt `_tip_find_existing_image()` để tái sử dụng ảnh chụp gần nhất (Smart Fallback).
- `_tip_find_existing_image(target_file, target_dir)`: Kiểm tra file tồn tại hoặc tìm ảnh gần nhất (`clip_*.png`, `clipboard.png`) để tái sử dụng.

### `lib/formatter.sh`
- `tip_format_output(file_path)`: Định dạng đường dẫn theo `PASTE_FORMAT` (`timg`, `path`, `custom`).
- `tip_should_auto_enter()`: Trả về `0` nếu cấu hình `AUTO_ENTER="true"` và format là `timg` hoặc `custom`.

### `lib/injector.sh`
- `tip_inject_text(text, auto_enter)`: Dán chuỗi vào terminal active:
  - **Preferred:** Clipboard Injection qua `wl-copy` (cả Clipboard & Primary) / `xclip` rồi gửi phím `Ctrl+Shift+V` qua `wtype` (Wayland) hoặc `xdotool` (X11).
  - **X11 Key Grab Protection:** Sử dụng `sleep 0.25s` để đảm bảo Window Manager (Openbox, XFCE, i3) giải phóng toàn quyền bàn phím (`XGrabKeyboard`), nạp chuỗi vào cả `clipboard` và `primary selection`.
  - **Fail-Safe & Multi-Compositor Fallback:** Bắt chính xác exit code của `wtype`; nếu compositor không hỗ trợ `virtual-keyboard-v1` (như KWin của KDE hay Mutter của GNOME), tự động chuyển sang `ydotool` (thông qua `/dev/uinput`), hoặc in trực tiếp ra `stdout`.

### `lib/doctor.sh`
- `tip_run_doctor()`: Chẩn đoán môi trường OS, display server (Wayland/X11), Desktop/Compositor (Niri, Hyprland, Sway, KDE Plasma, GNOME, LXDE / Openbox). Cảnh báo khả năng tương thích của `wtype` và kiểm tra trạng thái hoạt động của `ydotool`/`ydotoold`.

### `lib/tui.sh`
- `tip_tui_main_menu()`: Bảng điều khiển tương tác TUI (chọn format, auto-enter, hotkey, log level, doctor, log).
- `tip_tui_select_format()`, `tip_tui_toggle_auto_enter()`, `tip_tui_select_log_level()`, `tip_tui_select_hotkey()`.
- Tự động nhận diện desktop environment để hiển thị thông báo gán phím tắt thân thiện (`KDE Plasma Shortcuts`, `GNOME Shortcuts`, `LXDE / Openbox config`, `Niri config`...).

### `lib/shortcut.sh`
- `tip_decode_csi_u(input)`: Giải mã chuỗi escape CSI u từ Ghostty/Kitty (ví dụ: `^[[98;5u` -> `Ctrl+B`).
- `tip_shortcut_to_niri(raw)` / `tip_shortcut_install_niri(hotkey)`: Định dạng và ghi phím tắt vào `~/.config/niri/config.kdl`.
- `tip_shortcut_to_kde(raw)` / `tip_shortcut_install_kde(hotkey)`: Chuẩn hóa sang `Meta+...`, tạo `.desktop` action và ghi vào `kglobalshortcutsrc` kèm lệnh reload D-Bus KWin.
- `tip_shortcut_to_gnome(raw)` / `tip_shortcut_install_gnome(hotkey)`: Chuẩn hóa sang `<Super>...` và cấu hình tức thì qua `gsettings` custom keybindings.
- `tip_shortcut_to_openbox(raw)` / `tip_shortcut_install_lxde(hotkey)`: Chuẩn hóa sang cú pháp Openbox XML (`W-S-v`, `C-W-v`), ghi vào `~/.config/openbox/lxde-rc.xml` và nạp lại tức thì qua `openbox --reconfigure`.
- `tip_shortcut_install(hotkey)`: Tự động điều hướng cài đặt phím tắt theo compositor đang chạy.

---

## 3. LUỒNG DỮ LIỆU (DATA FLOW)
```text
[User Trigger / Hotkey / CLI: tip paste]
                 │
                 ▼
      [lib/clipboard.sh]
     (Detect Wayland/X11)
  (Check MIME: image/png...)
                 │
                 ▼
  Lưu đè file vào /tmp/clipboard.png (Zero-RAM Bloat)
                 │
                 ▼
      [lib/formatter.sh]
    (Format: timg <path> / path / custom)
                 │
                 ▼
      [lib/injector.sh]
    (wtype / xdotool / stdout fallback)
                 │
                 ▼
  [Terminal Window: Nhận chuỗi và thực thi]
```
Mọi hành động và cảnh báo trong luồng đều được ghi nhận qua `lib/logger.sh`.
