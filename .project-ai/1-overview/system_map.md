# SYSTEM MAP: TERMINAL IMAGE PASTE (`tip`)
@status: 🟡 PLANNING & ARCHITECTURE | @git_branch: main | @last_update: 2026-09-19

---

## 1. TỔNG QUAN & TECH STACK (OVERVIEW & TECH STACK)
- **Mục tiêu:** Công cụ tiện ích dòng lệnh (CLI / Daemon) giúp dán nhanh ảnh từ clipboard vào terminal dưới dạng đường dẫn file, lệnh xem ảnh (`timg`), hoặc Markdown trên **mọi bản phân phối Linux**.
- **Display Servers hỗ trợ:**
  - **Wayland:** `wl-clipboard` (`wl-paste`, `wl-copy`), `wtype` (hoặc `ydotool`).
  - **X11:** `xclip` / `xsel`, `xdotool`.
- **Desktop Environments (Auto-detect Shortcut):**
  - **Wayland Compositors:** Niri (`config.kdl`), Hyprland / Sway (`config file append`).
  - **Desktop Environments:** GNOME (`gsettings`), KDE Plasma (`kwriteconfig` / `kglobalaccel`), XFCE (`xfconf-query`), i3.
- **Cấu hình & Nhật ký (XDG Standard):**
  - File cấu hình: `~/.config/tip/config.conf`
  - File nhật ký lỗi/hoạt động: `~/.local/state/tip/tip.log` (tự động xoay vòng tối đa 500 dòng).
- **Giao diện cấu hình (TUI):** Menu tương tác chọn phím tắt & định dạng hiển thị ngay trong terminal.
- **Hệ thống chẩn đoán & kiểm lỗi thuần Terminal (Zero-Popup):**
  - Lệnh kiểm tra môi trường: `tip doctor`
  - Lệnh xem log trực tiếp: `tip log` / `tip log -f`
  - *Không dùng popup notify-send để tránh làm phiền và giảm phụ thuộc thư viện.*

---

## 2. CẤU TRÚC DỰ ÁN (PROJECT STRUCTURE)
```text
terminal-image-paste/
├── bin/
│   └── tip                         # CLI executable chính (quản lý subcommands: paste, config, log, doctor...)
├── lib/
│   ├── clipboard.sh               # Module nhận diện & trích xuất ảnh từ clipboard (Wayland vs X11)
│   ├── formatter.sh               # Module định dạng chuỗi xuất (path, timg, markdown, custom template)
│   ├── injector.sh                # Module mô phỏng gõ phím / chèn text vào terminal active
│   ├── config.sh                  # Module đọc / ghi file cấu hình (~/.config/tip/config.conf)
│   ├── logger.sh                  # Module ghi log và xoay vòng log (~/.local/state/tip/tip.log)
│   ├── doctor.sh                  # Module kiểm tra chẩn đoán hệ thống (Wayland/X11, packages, hotkey)
│   ├── tui.sh                     # Module giao diện bảng cài đặt tương tác (menu chọn option)
│   └── shortcut.sh                # Module tự động đăng ký phím tắt (Niri, GNOME, KDE, Hyprland...)
├── install.sh                     # Trình cài đặt 1-line tự động (curl -sSL ... | bash)
└── .project-ai/                   # Hệ thống tài liệu & bộ nhớ AI Agent (4 ngăn kéo chuẩn)
    ├── 1-overview/                # Bản đồ hệ thống, kiến trúc chi tiết, roadmap từng phase
    ├── 2-memory/                  # Quyết định kiến trúc (decision-log), checkpoint bàn giao
    ├── 3-ecosystem/modules/       # Tài liệu kỹ thuật chi tiết của từng module trong lib/
    └── 4-rules/                   # Quy chuẩn kỹ thuật dự án
```

---

## 3. DANH BẠ MODULE & TIẾN ĐỘ (MODULE REGISTRY & STATUS)

| Module Name | File Path | Trách nhiệm cốt lõi | Trạng thái |
| :--- | :--- | :--- | :--- |
| **Core CLI Entrypoint** | `bin/tip` | Điều phối các lệnh `paste`, `config`, `log`, `doctor`, `install-shortcut`, `status`. | 🟢 Done |
| **Clipboard Engine** | `lib/clipboard.sh` | Tự động detect X11/Wayland, trích xuất ảnh nhị phân và lưu vào `/tmp/clip_YYYYMMDD_HHMMSS.png`. | 🟢 Done |
| **Output Formatter** | `lib/formatter.sh` | Xử lý format đầu ra: Raw Path, `timg <path>`, Markdown `![](<path>)`, hoặc Custom Command. | 🟢 Done |
| **Terminal Injector** | `lib/injector.sh` | Mô phỏng gõ chuỗi vào cửa sổ terminal đang active (`wtype` / `xdotool` / clipboard fallback). | 🟢 Done |
| **Logger** | `lib/logger.sh` | Ghi log vào `~/.local/state/tip/tip.log`, xoay vòng tối đa 500 dòng, hiển thị khi chạy `tip log`. | 🟢 Done |
| **System Doctor** | `lib/doctor.sh` | Kiểm tra dependencies, display server, permissions, phím tắt và in bảng chẩn đoán màu sắc. | 🟢 Done |
| **Configuration Manager** | `lib/config.sh` | Đọc / ghi file cấu hình `~/.config/tip/config.conf`. | 🟢 Done |
| **Interactive TUI Setup** | `lib/tui.sh` | Hiển thị bảng setting tương tác cho người dùng tùy chọn format và phím tắt. | 🟡 Planning |
| **Shortcut Manager** | `lib/shortcut.sh` | Nhận diện DE/Compositor (Niri, GNOME, KDE, Hyprland...) và bind phím tắt toàn cục. | 🟡 Planning |
| **One-Line Installer** | `install.sh` | Kiểm tra dependencies của distro (apt/dnf/pacman), copy binary và chạy wizard thiết lập ban đầu. | 🟡 Planning |

---

## 4. BẢNG CẤU HÌNH MẪU (`~/.config/tip/config.conf`)
```ini
# Terminal Image Paste Configuration
PASTE_FORMAT="timg"                  # path | timg | markdown | custom
AUTO_ENTER="true"                    # true | false (áp dụng khi dùng lệnh timg/custom)
CUSTOM_PREFIX="timg"                 # Lệnh tùy chỉnh (ví dụ: chafa, viu, catimg)
STORAGE_DIR="/tmp"                   # Thư mục lưu ảnh tạm
HOTKEY="<Super><Shift>v"             # Tổ hợp phím toàn cục
FILENAME_FORMAT="timestamp"          # timestamp (clip_20260919_123456.png) | hash | static (clipboard.png)
LOG_LEVEL="INFO"                     # DEBUG | INFO | WARN | ERROR
```

---

## 5. NHẬT KÝ THAY ĐỔI GẦN ĐÂY (RECENT LOGS)
- **2026-09-20:**
  - Hoàn thành triển khai và kiểm thử 100% Phase 1 (Core Engine & CLI Pipeline): `bin/tip`, `lib/logger.sh`, `lib/config.sh`, `lib/clipboard.sh`, `lib/formatter.sh`, `lib/injector.sh`, `lib/doctor.sh`.
  - Khởi tạo kho lưu trữ Git trên nhánh `main`.
- **2026-09-19:** 
  - Khởi tạo System Map cho dự án **Terminal Image Paste (`tip`)**.
  - Bổ sung `niri` vào danh sách Window Manager / Compositor hỗ trợ phím tắt.
  - Tối giản hóa kiểm lỗi: Loại bỏ `notify-send` (Zero-Popup), tập trung hoàn toàn vào kiểm tra log trên terminal (`tip log`, `tip log -f`) và chẩn đoán (`tip doctor`).