# CHECKPOINT & PROGRESS HANDOVER (checkpoint.md)
@status: PHASE 1 COMPLETED | @git_branch: main | @last_update: 2026-09-20

## 1. TRẠNG THÁI HIỆN TẠI (CURRENT STATUS)
- **Phase 1 (Core Engine & CLI Pipeline):** Đã hoàn tất 100% (8/8 tasks trong `pm_phase1.md`).
- **Các module đã kiểm thử thành công:**
  - `lib/logger.sh`: Ghi log và tự xoay vòng 500 dòng.
  - `lib/config.sh`: XDG config chuẩn (`~/.config/tip/config.conf`).
  - `lib/clipboard.sh`: Tự nhận diện Wayland/X11, trích xuất ảnh sang `/tmp`.
  - `lib/formatter.sh`: Hỗ trợ định dạng `path`, `timg`, `markdown`, `custom`.
  - `lib/injector.sh`: Mô phỏng gõ phím `wtype` / `xdotool`.
  - `lib/doctor.sh`: Chẩn đoán môi trường Arch Linux + Wayland + Niri thành công.
  - `bin/tip`: CLI entrypoint điều phối đầy đủ subcommands.

## 2. LƯU Ý KIỂM LỖI CHO PHIÊN SAU (PENDING DEBUG / KNOWN ISSUE)
- **Triệu chứng:** Người dùng chạy `./bin/tip paste` -> lệnh inject `timg /tmp/clip_...png` thành công nhưng khi chạy lệnh `timg` trên terminal thì terminal không hiển thị ảnh (ra output `t    timg ...` rồi No output).
- **Kế hoạch xử lý phiên sau:**
  1. Kiểm tra terminal emulator (kitty, alacritty, foot, ghostty...) có hỗ trợ render graphic protocol của `timg` không.
  2. Kiểm tra `wtype` delay và cơ chế gõ phím xem có bị dính ký tự thừa không.
  3. Thử nghiệm fallback sang `chafa` hoặc chế độ `PASTE_FORMAT="path"`.

## 3. CÔNG VIỆC BÀN GIAO CHO PHIÊN TIẾP THEO (NEXT TASKS - PHASE 2)
1. Kiểm lỗi hiển thị `timg` trên môi trường terminal của người dùng.
2. Triển khai `lib/shortcut.sh` (tự động cấu hình phím tắt cho Niri `config.kdl`, Hyprland, GNOME, KDE).
3. Triển khai `lib/tui.sh` (bảng chọn định dạng và phím tắt tương tác).
4. Triển khai `install.sh` (trình cài đặt tự động).

## 4. DANH SÁCH FILE LIÊN QUAN
- `1-overview/system_map.md`
- `1-overview/project-managers/pm_phase1.md`
- `2-memory/decision-log.md`
- `3-ecosystem/modules/core_engine.md`
- `4-rules/project-rules.md`
- `.agents/AGENTS.md`
