# CHECKPOINT & PROGRESS HANDOVER (checkpoint.md)
@status: PHASE 3 (v1.1.2 RELEASED 🟢 -> UBUNTU 26.04 & FEDORA 44 VERIFIED 🎯) | @git_branch: main | @last_update: 2026-09-22

## 1. TRẠNG THÁI HIỆN TẠI (CURRENT STATUS)
- **Phase 1 & 2:** Hoàn tất 100% (Core Engine, TUI Setup, Localization, GitHub Release).
- **Phase 3 (Tiến độ mới nhất trong phiên 8):**
  - **Ubuntu 26.04 (GNOME Wayland):**
    + Sửa lỗi lặp chữ ydotool & dính prompt: Nâng cấp `lib/injector.sh` dùng `ydotool key` (Ctrl+Shift+V) kèm `sleep 0.2` nhả phím vật lý.
    + Chuẩn hóa fallback stdout dùng `echo "$text"` có xuống dòng (`\n`).
    + Bổ sung gợi ý reload PATH (`source ~/.profile` hoặc `export PATH="$HOME/.local/bin:$PATH"`).
  - **Fedora 44 (KDE Plasma Wayland):**
    + Phát hiện và xử lý lỗi thiếu user unit: `install.sh` tự tạo `~/.config/systemd/user/ydotool.service`.
    + Tài liệu hóa cách mở quyền `/dev/uinput` (`sudo chmod 666 /dev/uinput`) và xử lý chặn SELinux (`sudo setenforce 0`).
  - **Tối ưu install.sh & doctor.sh:** Tự tạo sẵn `~/.local/state/tip` và `~/.config/tip`; sửa gợi ý service `ydotool`.
  - **Phát hành phiên bản v1.1.2:** Đã đồng bộ mã nguồn, README, AUR và đẩy lên GitHub.

## 2. CÔNG VIỆC BÀN GIAO CHO PHIÊN TIẾP THEO (NEXT TASKS)
1. **Kiểm thử môi trường tiếp theo:**
   - Kiểm thử trên openSUSE Tumbleweed và Debian 12/Testing nếu cần.
   - Kiểm tra tính ổn định lâu dài của daemon ydotool trên các bản phân phối Wayland.
2. **Cân nhắc đóng gói RPM / Copr:** Có thể nghiên cứu tạo spec file cho Fedora Copr nếu có nhu cầu.

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
