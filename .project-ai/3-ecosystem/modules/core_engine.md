# MODULE ARCHITECTURE: CORE ENGINE & CLI PIPELINE (`tip`)
@module: Core Engine & CLI | @status: 🟢 Done | @last_update: 2026-09-20

---

## 1. TRÁCH NHIỆM CỐT LÕI (RESPONSIBILITIES)
- Cung cấp giao diện CLI thống nhất (`bin/tip`) cho người dùng cuối.
- Tự động nhận diện Display Server (Wayland hoặc X11) và trích xuất ảnh nhị phân từ clipboard sang file tạm trong `$STORAGE_DIR`.
- Định dạng chuỗi xuất phù hợp (`path`, `timg <path>`, `![](<path>)`, `custom`) và mô phỏng gõ phím vào terminal active qua `wtype` hoặc `xdotool`.
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
- `tip_clipboard_extract()`: Trích xuất ảnh từ clipboard, lưu vào file và in đường dẫn ra stdout. Trả về mã `0` khi thành công, `1` khi thất bại.

### `lib/formatter.sh`
- `tip_format_output(file_path)`: Định dạng đường dẫn theo `PASTE_FORMAT` (`timg`, `path`, `custom`).
- `tip_should_auto_enter()`: Trả về `0` nếu cấu hình `AUTO_ENTER="true"` và format là `timg` hoặc `custom`.

### `lib/injector.sh`
- `tip_inject_text(text, auto_enter)`: Mô phỏng gõ chuỗi vào cửa sổ terminal active thông qua `wtype` (Wayland) hoặc `xdotool` (X11). Fallback in ra stdout nếu thiếu công cụ.

### `lib/doctor.sh`
- `tip_run_doctor()`: Chẩn đoán môi trường hệ điều hành, display server, compositors, dependencies, và quyền thư mục.

### `lib/tui.sh`
- `tip_tui_main_menu()`: Bảng điều khiển tương tác TUI (chọn format, auto-enter, hotkey, log level, doctor, log).
- `tip_tui_select_format()`, `tip_tui_toggle_auto_enter()`, `tip_tui_select_log_level()`, `tip_tui_select_hotkey()`.

### `lib/shortcut.sh`
- `tip_decode_csi_u(input)`: Giải mã chuỗi escape CSI u từ Ghostty/Kitty (ví dụ: `^[[98;5u` -> `Ctrl+B`).
- `tip_shortcut_to_niri(raw)`: Chuẩn hóa tổ hợp phím sang định dạng Niri (`Ctrl+Super+V`, `Super+Ctrl+B`...).
- `tip_shortcut_install(hotkey)`: Tự động ghi phím tắt vào khối `binds` toàn cục của Niri (`~/.config/niri/config.kdl`).

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
