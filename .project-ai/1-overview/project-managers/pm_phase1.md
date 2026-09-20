# PROJECT MANAGER: PHASE 1 — CORE ENGINE & CLI PIPELINE
@status: READY TO IMPLEMENT | @git_branch: main | @last_update: 2026-09-19

## 1. MỤC TIÊU PHASE 1 (GOALS)
- Xây dựng bộ khung CLI `bin/tip` và các module lõi trong `lib/`.
- Hỗ trợ dán ảnh mượt mà trên Wayland (`wl-clipboard`, `wtype`) và X11 (`xclip`, `xdotool`).
- Hỗ trợ định dạng đầu ra linh hoạt: Raw Path, `timg <path>`, Markdown `![](<path>)`.
- Tích hợp hệ thống logging `~/.local/state/tip/tip.log`, lệnh `tip log`, `tip log -f` và `tip doctor`.

## 2. ROADMAP & TASKS (CHI TIẾT PHIÊN TIẾP THEO)
- [x] Khởi tạo kiến trúc dự án và thống nhất System Map (`system_map.md`).
- [x] Thiết lập bộ nhớ và rules cho AI Agent (`.project-ai/`, `.agents/AGENTS.md`).
- [x] **Task 1 (File Structure):** Khởi tạo khung thư mục `bin/` và `lib/`.
- [x] **Task 2 (Logger Module):** Viết `lib/logger.sh` (ghi log, xoay vòng 500 dòng, hiển thị khi gọi `tip log`).
- [x] **Task 3 (Clipboard Engine):** Viết `lib/clipboard.sh` (tự động nhận diện Wayland/X11, trích xuất ảnh, đặt tên timestamp vào `/tmp`).
- [x] **Task 4 (Formatter Module):** Viết `lib/formatter.sh` (xử lý format Path, `timg <path>`, Markdown, custom prefix, auto-enter).
- [x] **Task 5 (Injector Module):** Viết `lib/injector.sh` (mô phỏng gõ phím `wtype` / `xdotool` / clipboard fallback).
- [x] **Task 6 (System Doctor):** Viết `lib/doctor.sh` (quét dependencies, display server, permissions).
- [x] **Task 7 (CLI Entrypoint):** Viết `bin/tip` liên kết toàn bộ subcommands (`paste`, `log`, `doctor`, `status`).
- [x] **Task 8 (Verification):** Kiểm thử runtime thực tế trên Arch Linux + Niri + Wayland + timg.

## 3. CHECKLIST KIỂM THỬ (TESTING CHECKLIST)
- [x] `tip doctor` chạy thành công và báo cáo chính xác môi trường Arch Linux / Wayland / Niri.
- [x] Copy ảnh vào clipboard -> Chạy `tip paste` -> Kiểm tra xử lý và ghi log.
- [x] Kiểm tra `tip log` ghi nhận đúng tiến trình và xoay vòng.

