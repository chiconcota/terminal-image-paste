# [ARCHITECTURAL PILLARS & DECISION LOG]
> File này ghi nhận các nguyên tắc kiến trúc cốt lõi và lịch sử các quyết định kỹ thuật lớn của dự án.
> Các quyết định mới được chốt/triển khai sẽ được chèn lên đầu phần nhật ký theo ngày tháng.

---

## 1. NGUYÊN TẮC KIẾN TRÚC CỐT LÕI (CORE PRINCIPLES)
- **1. Universal Linux Display Support (Wayland & X11):** Tự động phân giải session type để gọi đúng backend (`wl-clipboard` / `wtype` vs `xclip` / `xdotool`).
- **2. Modular & Decoupled Architecture:** Tách biệt rõ các tầng trong `lib/`: Clipboard Engine, Formatter, Injector, Config, Logger, Doctor, TUI, Shortcut Manager.
- **3. Pure Terminal Diagnostics (Zero-Popup):** Không dùng popup desktop (`notify-send`). Mọi hoạt động và lỗi đều ghi vào `~/.local/state/tip/tip.log`, kiểm tra trực tiếp qua `tip log` và `tip doctor`.
- **4. Standard XDG Directory Compliance:** File cấu hình tại `~/.config/tip/config.conf`, file log tại `~/.local/state/tip/tip.log`.
- **5. User-Centric Customization:** Cung cấp TUI cài đặt (`tip config`) cho phép chọn phím tắt và định dạng đầu ra (Raw Path, `timg <path>`, Markdown, Custom).

---

## 2. NHẬT KÝ QUYẾT ĐỊNH (DECISION LOG)

### 2026-09-20 - 🟢 Triển khai hoàn thiện Core Engine & CLI Pipeline (Phase 1)
- **Bối cảnh & Quyết định:**
  1. Khởi tạo kho lưu trữ Git cục bộ trên nhánh `main`.
  2. Triển khai cấu trúc thư mục mô-đun: `bin/tip` (Entrypoint), `lib/logger.sh` (XDG log + auto rotate 500 lines), `lib/config.sh` (XDG config), `lib/clipboard.sh` (Wayland/X11 clipboard image extraction), `lib/formatter.sh` (Path/timg/Markdown/custom output), `lib/injector.sh` (wtype/xdotool), `lib/doctor.sh` (Zero-popup pure terminal diagnosis).
  3. Xử lý an toàn `set -e` trong bash scripts để các lệnh chẩn đoán tùy chọn không ngắt script bất thường.
  4. Xác nhận tương thích runtime trên Arch Linux + Wayland + Niri Compositor + `timg`.

### 2026-09-19 - 🟢 Quyết định: Loại bỏ Notify-send, Tối ưu hóa kiểm lỗi thuần Terminal
- **Vấn đề:** Popup thông báo màn hình (`notify-send`) gây phiền toái trong quá trình làm việc và làm tăng thêm dependency phụ thuộc thư viện desktop.
- **Quyết định:**
  1. Loại bỏ hoàn toàn `notify-send`.
  2. Tập trung trải nghiệm kiểm lỗi 100% trong terminal qua `tip log` (xem 30 dòng gần nhất), `tip log -f` (realtime) và `tip doctor` (chẩn đoán hệ thống).
  3. Bổ sung `niri` vào danh sách Compositor hỗ trợ phím tắt tự động.

### 2026-09-19 - 🟢 Khởi tạo kiến trúc dự án Terminal Image Paste (`tip`)
- **Decision:** Thiết lập bản đồ hệ thống `system_map.md`, định hình các module trong `lib/`, hỗ trợ đa định dạng đầu ra (Path, `timg`, Markdown) và bảng cài đặt TUI.
