# CHECKPOINT & PROGRESS HANDOVER (checkpoint.md)
@status: PHASE 3 (HYPRLAND RESOLVED 🟢 -> NEXT: NIRI AUR TESTING 🎯) | @git_branch: main | @last_update: 2026-09-21

## 1. TRẠNG THÁI HIỆN TẠI (CURRENT STATUS)
- **Phase 1 & 2:** Hoàn tất 100% (Core Engine, TUI Setup, Shortcut Manager, Localization, GitHub Release).
- **Phase 3 (Tiến độ mới nhất trong phiên 6):**
  - **Khắc phục lỗi Hyprland mở `btop`:** Cô lập không dùng `wtype` trên Hyprland để tránh scancode 1 (`KEY_ESC`). Thay thế bằng Hyprland Lua native dispatcher (`hyprctl dispatch 'hl.dsp.send_shortcut({ mods = "CTRL SHIFT", key = "v" })'`). Đã kiểm thử thực tế trên CachyOS Hyprland thành công 100%.
  - **Tinh giản TUI & Quản lý phím tắt:** Tái cấu trúc mục [3] trong `lib/tui.sh` và `lib/shortcut.sh`. Chỉ tự động can thiệp file config đối với **Niri** (`~/.config/niri/config.kdl`). Các WM/Compositor khác hiển thị hướng dẫn copy snippet thủ công để đảm bảo an toàn dotfiles.
  - **Gỡ cài đặt bản local user trên máy chính:** Đã chạy `./install.sh --uninstall` sạch sẽ, sẵn sàng cho việc kiểm thử gói AUR.
  - **Git Status:** Đã commit và push toàn bộ lên nhánh `main` (`2fdaf74`) trên GitHub: [https://github.com/chiconcota/terminal-image-paste](https://github.com/chiconcota/terminal-image-paste). Working tree sạch 100%.

## 2. CÔNG VIỆC BÀN GIAO CHO PHIÊN TIẾP THEO (NEXT TASKS)
1. **Kiểm thử trực tiếp trên Niri bằng gói AUR (`yay`) theo yêu cầu User:**
   - Cài đặt gói chính thức qua yay: `yay -S terminal-image-paste-git`.
   - Kiểm tra binary hệ thống `/usr/bin/tip` và thư viện `/usr/lib/tip/`.
   - Chạy `tip config` -> Mục [3] để kiểm tra tự động gán phím tắt vào `~/.config/niri/config.kdl`.
   - Kiểm thử thao tác copy ảnh vào clipboard và bấm phím tắt để dán ảnh vào terminal (Ghostty/Foot/Alacritty) trên Niri.
2. **Kiểm thử runtime trên các terminal emulator khác nhau trên Niri:**
   - Kiểm tra Ghostty, Foot, Kitty và Alacritty.
3. **Đẩy cập nhật chính thức lên kho AUR:**
   - Cập nhật `.SRCINFO` và đẩy lên `ssh://aur@aur.archlinux.org/terminal-image-paste-git.git` nếu cần thiết.

## 3. DANH SÁCH FILE LIÊN QUAN
- `1-overview/system_map.md`
- `1-overview/project-managers/pm_phase1.md`
- `2-memory/decision-log.md`
- `3-ecosystem/modules/core_engine.md`
- `lib/shortcut.sh`
- `lib/injector.sh`
- `lib/doctor.sh`
- `lib/tui.sh`
- `README.md`
