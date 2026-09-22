# CHECKPOINT & PROGRESS HANDOVER (checkpoint.md)
@status: PHASE 3 (v1.1.1 RELEASED 🟢 -> NEXT: TEST ON UBUNTU REAL 🎯) | @git_branch: main | @last_update: 2026-09-22

## 1. TRẠNG THÁI HIỆN TẠI (CURRENT STATUS)
- **Phase 1 & 2:** Hoàn tất 100% (Core Engine, TUI Setup, Localization, GitHub Release).
- **Phase 3 (Tiến độ mới nhất trong phiên 7):**
  - **Nâng cấp phiên bản & Release v1.1.1:** Đã cập nhật SemVer lên `1.1.1` (`bin/tip`, `aur/PKGBUILD`, `aur/.SRCINFO`), tag `v1.1.1` đã đẩy lên GitHub.
  - **Kiểm thử thực tế Hyprland Lua:** Xác nhận cú pháp `hl.bind(mainMod .. " + CONTROL + V", hl.dsp.exec_cmd("tip paste"))` hoạt động mượt mà trên CachyOS Noctalia. Đã cập nhật vào `lib/shortcut.sh` và `README.md`.
  - **Bổ sung ghi chú `ydotool`:** Thêm ghi chú bật dịch vụ `ydotool` có chọn lọc cho KDE Plasma và GNOME (Wayland) trong cả `lib/shortcut.sh` và `README.md`.
  - **Chuyển đổi toàn diện sang Shortcut Setup Guide:** Loại bỏ hoàn toàn việc tự động can thiệp file config dotfiles (`config.kdl`, KDE, GNOME, Openbox).
  - **Tài liệu & Đa Distro:** Hoàn thiện hướng dẫn dependencies cho Arch Linux, Ubuntu/Debian và Fedora trong `README.md`.
  - **Cập nhật kiến trúc module:** Đã đồng bộ `3-ecosystem/modules/core_engine.md`.

## 2. CÔNG VIỆC BÀN GIAO CHO PHIÊN TIẾP THEO (NEXT TASKS)
1. **Kiểm thử trực tiếp trên máy thật Ubuntu (Ubuntu Real - GNOME Wayland/X11):**
   - Chạy trình cài đặt tự động `curl -sSL https://raw.githubusercontent.com/chiconcota/terminal-image-paste/main/install.sh | bash` hoặc clone git.
   - Cài đặt các gói phụ thuộc trên Ubuntu: `sudo apt install wl-clipboard ydotool timg`.
   - Cấp quyền và bật service: `sudo usermod -aG input $USER && systemctl --user enable --now ydotool`.
   - Gán phím tắt trong GNOME Settings (`tip paste`) và kiểm thử thao tác dán ảnh thực tế.
2. **Kiểm thử tiếp theo:** Mở rộng kiểm thử sang Fedora và các môi trường khác nếu cần.

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
