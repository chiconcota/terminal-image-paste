# PROJECT MANAGER: PHASE 1 & 2 — CORE ENGINE, TUI & GITHUB RELEASE
@status: 🟢 COMPLETED | @git_branch: main | @last_update: 2026-09-20

## 1. MỤC TIÊU ĐÃ HOÀN THÀNH
- Xây dựng bộ khung CLI `bin/tip` và toàn bộ các module trong `lib/`.
- Hỗ trợ dán ảnh mượt mà trên Wayland (`wl-clipboard`, `wtype`) và X11 (`xclip`, `xdotool`).
- Triển khai giao diện TUI interactive menu (`lib/tui.sh`) và Shortcut Manager (`lib/shortcut.sh`).
- Hỗ trợ giải mã phím bấm CSI u (Ghostty/Kitty) và bind phím tắt tự động vào Niri.
- Chế độ Zero-RAM Bloat (`FILENAME_FORMAT="static"`), luôn lưu đè vào `/tmp/clipboard.png`.
- Quốc tế hóa 100% tiếng Anh, tạo `README.md`, `LICENSE`, `.gitignore` và phát hành lên GitHub.

## 2. ROADMAP TIẾP THEO (PHASE 3 - AUR & MULTI-DISTRO TESTING)
- [x] Tạo PKGBUILD và .SRCINFO để đóng gói phát hành lên Arch User Repository (AUR) -> Đã phát hành `terminal-image-paste-git`.
- [x] Viết script cài đặt tự động `install.sh` hỗ trợ phát hiện package manager (`pacman`, `apt`, `dnf`, `zypper`).
- [x] Sửa lỗi Chromium/Electron scancode collision & bổ sung Smart Fallback tái sử dụng ảnh.
- [ ] Kiểm thử runtime thực tế trên các bản phân phối khác: Ubuntu/Debian, Fedora, openSUSE.
- [ ] Mở rộng tự động bind phím cho các Window Manager khác: Hyprland, Sway, GNOME, KDE.

