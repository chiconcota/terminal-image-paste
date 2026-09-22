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
- [x] Tương thích KDE Plasma (KWin) & GNOME (Mutter): Bắt mã lỗi `wtype`, fallback sang `ydotool` và `stdout`.
- [x] Tương thích LXDE (Openbox X11): Sửa lỗi key grab `sleep 0.25s` và hỗ trợ cấu hình Openbox XML.
- [x] Tương thích Hyprland (0.56+ Lua): Giải quyết dứt điểm va chạm scancode `btop`, tích hợp native Lua dispatcher `hl.dsp.send_shortcut`.
- [x] Tinh giản chiến lược phím tắt: Chuyển đổi toàn diện sang Shortcut Setup Guide & Snippets (Zero-Risk), loại bỏ auto-modify dotfiles.
- [x] Phát hành v1.1.1: Tương thích hoàn toàn Hyprland Lua (`hl.bind`), bổ sung hướng dẫn `ydotool` cho KDE & GNOME Wayland.
- [ ] Kiểm thử runtime trên máy thật Ubuntu (Ubuntu Real - GNOME Wayland/X11) (Trọng tâm phiên tiếp theo).
- [ ] Mở rộng kiểm thử sang Fedora và openSUSE.

