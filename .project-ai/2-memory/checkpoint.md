# CHECKPOINT & PROGRESS HANDOVER (checkpoint.md)
@status: PHASE 3 (TAG v1.1.1 READY 🟢 -> NEXT: UBUNTU & FEDORA VM TESTING 🎯) | @git_branch: main | @last_update: 2026-09-22

## 1. TRẠNG THÁI HIỆN TẠI (CURRENT STATUS)
- **Phase 1 & 2:** Hoàn tất 100% (Core Engine, TUI Setup, Localization, GitHub Release).
- **Phase 3 (Tiến độ mới nhất trong phiên 7):**
  - **Nâng cấp phiên bản v1.1.1:** Đã cập nhật SemVer lên `1.1.1` (`bin/tip`, `aur/PKGBUILD`, `aur/.SRCINFO`).
  - **Kiểm thử thực tế Hyprland Lua:** Người dùng xác nhận cú pháp `hl.bind(mainMod .. " + CONTROL + V", hl.dsp.exec_cmd("tip paste"))` hoạt động mượt mà trên CachyOS Noctalia. Đã cập nhật vào `lib/shortcut.sh` và `README.md`.
  - **Bổ sung ghi chú `ydotool`:** Thêm ghi chú bật dịch vụ `ydotool` có chọn lọc cho KDE Plasma và GNOME (Wayland) trong cả `lib/shortcut.sh` và `README.md`.
  - **Chuyển đổi toàn diện sang Shortcut Setup Guide:** Loại bỏ hoàn toàn việc tự động can thiệp file config dotfiles (`config.kdl`, KDE, GNOME, Openbox).
  - **Tài liệu & Đa Distro:** Hoàn thiện hướng dẫn dependencies cho Arch Linux, Ubuntu/Debian và Fedora trong `README.md`.

## 2. CÔNG VIỆC BÀN GIAO CHO PHIÊN TIẾP THEO (NEXT TASKS)
1. **Kiểm thử trên máy ảo Ubuntu (GNOME):**
   - Chạy trình cài đặt tự động `curl -sSL https://raw.githubusercontent.com/chiconcota/terminal-image-paste/main/install.sh | bash` hoặc clone git.
   - Cài `ydotool`, cấp quyền `input` và kiểm thử `tip doctor` + `tip paste`.
2. **Kiểm thử trên máy ảo Fedora (GNOME):**
   - Kiểm thử chạy `./install.sh --user` trên Fedora và xác nhận các dependencies.
3. **Phát hành chính thức v1.1.1 trên GitHub Releases.**

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
