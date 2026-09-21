# CHECKPOINT & PROGRESS HANDOVER (checkpoint.md)
@status: PHASE 3 (KDE & LXDE TESTED 🟢 -> NEXT: GNOME TESTING 🎯) | @git_branch: main | @last_update: 2026-09-21

## 1. TRẠNG THÁI HIỆN TẠI (CURRENT STATUS)
- **Phase 1 & 2:** Hoàn tất 100% (Core Engine, TUI Setup, Shortcut Manager, Localization, GitHub Release).
- **Phase 3 (Tiến độ mới nhất trong phiên 5):**
  - **Kiểm thử LXDE / Openbox (X11):** Đã kiểm thử thực tế trên CachyOS Boxes.
  - **Khắc phục lỗi Openbox Key Grab:** Tăng độ trễ nhả phím lên `0.25s` trong `lib/injector.sh`, sao chép chuỗi vào cả `clipboard` và `primary selection` (`xclip`), giúp phím tắt toàn cục hoạt động hoàn hảo 100%.
  - **Tự động đăng ký phím tắt LXDE / Openbox:** Chuyển đổi cú pháp sang Openbox XML (`W-S-v`), chèn/cập nhật `lxde-rc.xml` / `rc.xml` và reload tức thì qua `openbox --reconfigure`.
  - **Kiểm thử KDE Plasma (KWin Wayland):** Đã kiểm thử thực tế và hoàn tất ở phiên trước.
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
