# CHECKPOINT & PROGRESS HANDOVER (checkpoint.md)
@status: PHASE 3 COMPLETED (AUR, INSTALLER, CLIPBOARD FIX) | @git_branch: main | @last_update: 2026-09-21

## 1. TRẠNG THÁI HIỆN TẠI (CURRENT STATUS)
- **Phase 1 & 2:** Hoàn tất 100% (Core Engine, TUI Setup, Shortcut Manager, Localization, GitHub Release).
- **Phase 3 (Đã hoàn thành):**
  - Đóng gói AUR: `aur/PKGBUILD` và `aur/.SRCINFO` chuẩn Arch Linux (`terminal-image-paste-git`).
  - Trình cài đặt tự động đa distro `install.sh`: Hỗ trợ `pacman`, `apt`, `dnf`, `zypper` với dual mode (`--system` / `--user`), kiểm tra dependencies và gỡ cài đặt (`--uninstall`).
  - Nâng cấp `bin/tip`: Hỗ trợ phân giải thư viện động qua `/usr/lib/tip`, `/usr/local/lib/tip`, `~/.local/lib/tip`.
  - Fix Chromium/Electron Scancode Collision: Thay thế cơ chế gõ phím `wtype` bằng Clipboard Injection (`wl-copy` / `xclip` + `Ctrl+Shift+V`), dán tức thì 0ms, không lỗi scancode, không xung đột tiếng Việt.
  - Smart Fallback: Tự động tái sử dụng `/tmp/clipboard.png` khi clipboard không có ảnh mới, người dùng bấm phím tắt bất kỳ lúc nào cũng dán được đường dẫn.
- **Mã nguồn đã phát hành:** [https://github.com/chiconcota/terminal-image-paste](https://github.com/chiconcota/terminal-image-paste) trên nhánh `main`.

## 2. CÔNG VIỆC BÀN GIAO CHO PHIÊN TIẾP THEO (NEXT TASKS)
1. **Kiểm thử trên máy ảo/container các distro khác:** Test `install.sh` trên Ubuntu 22.04/24.04 và Fedora 39/40.
2. **Đẩy gói lên AUR chính thức:** Dùng tài khoản AUR SSH để clone `ssh://aur@aur.archlinux.org/terminal-image-paste-git.git`, commit `PKGBUILD` và `.SRCINFO`.
3. **Mở rộng hỗ trợ phím tắt:** Tự động bind phím cho Hyprland (`hyprland.conf`), Sway, GNOME, KDE.

## 3. DANH SÁCH FILE LIÊN QUAN
- `1-overview/system_map.md`
- `1-overview/project-managers/pm_phase1.md`
- `2-memory/decision-log.md`
- `3-ecosystem/modules/core_engine.md`
- `4-rules/project-rules.md`
- `.agents/AGENTS.md`
