# CHECKPOINT & PROGRESS HANDOVER (checkpoint.md)
@status: PHASE 3 (TAG v1.1.0 PUSHED 🟢 -> NEXT: NIRI RUNTIME TEST 🎯) | @git_branch: main | @last_update: 2026-09-22

## 1. TRẠNG THÁI HIỆN TẠI (CURRENT STATUS)
- **Phase 1 & 2:** Hoàn tất 100% (Core Engine, TUI Setup, Localization, GitHub Release).
- **Phase 3 (Tiến độ mới nhất trong phiên 7):**
  - **Nâng cấp phiên bản v1.1.0:** Đã cập nhật SemVer lên `1.1.0` (`bin/tip`, `aur/PKGBUILD`, `aur/.SRCINFO`), commit, tạo tag `v1.1.0` và push lên GitHub.
  - **Chuyển đổi toàn diện sang Shortcut Setup Guide:** Loại bỏ hoàn toàn việc tự động can thiệp file config dotfiles (`config.kdl`, KDE, GNOME, Openbox).
  - **Module `lib/shortcut.sh`:** Tái cấu trúc thành công cụ nhận diện môi trường (`tip_detect_wm`) và cung cấp snippet chuẩn xác (Niri, Hyprland, Sway, i3, KDE, GNOME, Openbox).
  - **TUI & CLI:** Cập nhật mục `[3]` trong `tip config` và lệnh CLI `tip shortcut [wm|all]` / `tip guide [wm|all]`.
  - **Tài liệu:** Cập nhật `README.md` rõ ràng, sạch sẽ.
  - **Khắc phục lỗi Hyprland mở `btop`:** Đã tích hợp Hyprland Lua native dispatcher (`hl.dsp.send_shortcut`) kiểm thử thành công ở phiên trước.

## 2. CÔNG VIỆC BÀN GIAO CHO PHIÊN TIẾP THEO (NEXT TASKS)
1. **Kiểm thử trực tiếp phím tắt trên Niri:**
   - Thêm snippet `Ctrl+Super+V { spawn "tip" "paste"; }` vào `~/.config/niri/config.kdl`.
   - Copy một ảnh vào clipboard và bấm phím tắt để kiểm tra dán ảnh vào terminal trên Niri.
2. **Commit và đẩy cập nhật lên GitHub / AUR:**
   - Commit các thay đổi sạch sẽ trên nhánh `main`.
   - Cập nhật `.SRCINFO` và đẩy lên repo AUR `terminal-image-paste-git` nếu cần.

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
