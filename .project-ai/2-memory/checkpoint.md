# CHECKPOINT & PROGRESS HANDOVER (checkpoint.md)
@status: PHASE 3 (KDE TESTED 🟢 -> NEXT: GNOME TESTING 🎯) | @git_branch: main | @last_update: 2026-09-21

## 1. TRẠNG THÁI HIỆN TẠI (CURRENT STATUS)
- **Phase 1 & 2:** Hoàn tất 100% (Core Engine, TUI Setup, Shortcut Manager, Localization, GitHub Release).
- **Phase 3 (Tiến độ mới nhất trong phiên 4):**
  - **Kiểm thử KDE Plasma (KWin Wayland):** Đã kiểm thử thực tế trên CachyOS Boxes.
  - **Khắc phục lỗi KWin/Mutter chặn virtual keyboard:** Bắt chính xác exit code của `wtype`, fallback sang `ydotool` (kernel uinput) và in trực tiếp ra `stdout`, luôn đưa câu lệnh vào `wl-copy` để dán an toàn.
  - **Tự động đăng ký phím tắt KDE & GNOME:**
    - KDE Plasma: Tạo `tip-paste.desktop` kèm cờ `X-KDE-GlobalAccel-CommandShortcut=true`, dùng `kwriteconfig6`/`kwriteconfig5` ghi vào `kglobalshortcutsrc` và kích hoạt qua D-Bus KWin.
    - GNOME: Ghi nhận trực tiếp qua `gsettings` custom keybindings, có hiệu lực tức thì 100%.
  - **Cập nhật cài đặt & AUR:** Sửa `bin/tip` ưu tiên nạp thư viện tương đối, thêm `ydotool` vào `aur/PKGBUILD`, `aur/.SRCINFO` và cập nhật hướng dẫn chi tiết trong `README.md`.
- **Mã nguồn đã phát hành:** [https://github.com/chiconcota/terminal-image-paste](https://github.com/chiconcota/terminal-image-paste) trên nhánh `main`.

## 2. CÔNG VIỆC BÀN GIAO CHO PHIÊN TIẾP THEO (NEXT TASKS)
1. **Kiểm thử trên môi trường GNOME (Trọng tâm hàng đầu):**
   - Chạy `install.sh --system` trên GNOME.
   - Thử nghiệm đăng ký phím tắt tự động qua `tip shortcut` / `gsettings`.
   - Kiểm tra hành vi dán ảnh và kích hoạt `ydotool` (`systemctl --user enable --now ydotool`) trên GNOME Wayland.
2. **Kiểm thử trên máy ảo các distro khác:** Test `install.sh` trên Ubuntu 22.04/24.04 (GNOME) và Fedora 39/40 (GNOME/KDE).
3. **Đẩy gói lên AUR chính thức:** Dùng tài khoản AUR SSH để clone `ssh://aur@aur.archlinux.org/terminal-image-paste-git.git`, commit `PKGBUILD` và `.SRCINFO`.

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
