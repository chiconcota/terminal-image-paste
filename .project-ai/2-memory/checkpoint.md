# CHECKPOINT & PROGRESS HANDOVER (checkpoint.md)
@status: PHASE 3 (v1.1.2 RELEASED 🟢 -> TESTED ON UBUNTU 26.04 🎯) | @git_branch: main | @last_update: 2026-09-22

## 1. TRẠNG THÁI HIỆN TẠI (CURRENT STATUS)
- **Phase 1 & 2:** Hoàn tất 100% (Core Engine, TUI Setup, Localization, GitHub Release).
- **Phase 3 (Tiến độ mới nhất trong phiên 8):**
  - **Sửa lỗi lặp chữ ydotool & dính prompt:** Nâng cấp `lib/injector.sh` dùng `ydotool key` (Ctrl+Shift+V) kèm `sleep 0.2` nhả phím vật lý, dán tức thì không lặp chữ. Chuẩn hóa fallback stdout dùng `echo "$text"` có xuống dòng.
  - **Cập nhật Shortcut Guide & Snippets:** Bổ sung udev rule `/etc/udev/rules.d/80-uinput.rules` và cấp quyền `/dev/uinput` cho Ubuntu/Debian; nêu rõ command `~/.local/bin/tip paste` khi cài user mode.
  - **Tối ưu install.sh & doctor.sh:** Tự tạo sẵn `~/.local/state/tip` và `~/.config/tip`; sửa gợi ý service `ydotool`.
  - **Nâng cấp phiên bản v1.1.2:** Đã đồng bộ `bin/tip`, `aur/PKGBUILD`, `aur/.SRCINFO`.

## 2. CÔNG VIỆC BÀN GIAO CHO PHIÊN TIẾP THEO (NEXT TASKS)
1. **Kiểm thử trực tiếp trên máy thật Ubuntu (Ubuntu 26.04 GNOME Wayland):**
   - Chạy `git pull` hoặc chạy lại trình cài đặt.
   - Thử nghiệm gán phím tắt `Shift+Super+V` trỏ tới `/home/$USER/.local/bin/tip paste`.
   - Kiểm tra thao tác dán ảnh thực tế bằng phím tắt.
2. **Kiểm thử tiếp theo:** Mở rộng kiểm thử sang Fedora và openSUSE nếu cần.

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
