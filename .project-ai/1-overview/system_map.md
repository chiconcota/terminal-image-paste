# SYSTEM MAP: TERMINAL IMAGE PASTE (`tip`)
@status: 🟢 PHASE 3 IMPLEMENTATION | @git_branch: main | @last_update: 2026-09-21

---

## 1. TỔNG QUAN & TECH STACK (OVERVIEW & TECH STACK)
- **Mục tiêu:** Công cụ tiện ích dòng lệnh (CLI / Daemon) giúp dán nhanh ảnh từ clipboard vào terminal dưới dạng đường dẫn file, lệnh xem ảnh (`timg`), hoặc Markdown trên **mọi bản phân phối Linux**.
- **Display Servers hỗ trợ:**
  - **Wayland:** `wl-clipboard` (`wl-paste`, `wl-copy`), `wtype` (hoặc `ydotool`).
  - **X11:** `xclip` / `xsel`, `xdotool`.
- **Desktop Environments (Auto-detect Shortcut):**
  - **Wayland Compositors:** Niri (`config.kdl`), Hyprland / Sway (`config file append`).
  - **Desktop Environments:** GNOME (`gsettings`), KDE Plasma (`kwriteconfig` / `kglobalaccel`), LXDE / Openbox (`lxde-rc.xml` / `rc.xml`), XFCE (`xfconf-query`), i3.
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
| **Interactive TUI Setup** | `lib/tui.sh` | Hiển thị bảng setting tương tác cho người dùng tùy chọn format và phím tắt. | 🟢 Done |
| **Shortcut Manager** | `lib/shortcut.sh` | Nhận diện DE/Compositor (Niri, GNOME, KDE, Hyprland...) và bind phím tắt toàn cục. | 🟢 Done |
| **One-Line Installer** | `install.sh` | Tự động nhận diện distro (Arch/Ubuntu/Fedora), cài đặt dependencies và binary. | 🟢 Done |
| **AUR Package** | `aur/PKGBUILD` | Đặc tả đóng gói phát hành lên Arch User Repository (`terminal-image-paste-git`). | 🟢 Done |

---

## 4. BẢNG CẤU HÌNH MẪU (`~/.config/tip/config.conf`)
```ini
# Terminal Image Paste Configuration (tip)
PASTE_FORMAT="timg"                  # timg | path | custom
AUTO_ENTER="true"                    # true | false
CUSTOM_PREFIX="timg"                 # chafa | viu | catimg
STORAGE_DIR="/tmp"                   # Thư mục lưu ảnh tạm
HOTKEY="<Ctrl><Super>v"              # Tổ hợp phím toàn cục
FILENAME_FORMAT="static"             # static (clipboard.png) | timestamp | hash
LOG_LEVEL="INFO"                     # DEBUG | INFO | WARN | ERROR
```

---

## 5. NHẬT KÝ THAY ĐỔI GẦN ĐÂY (RECENT LOGS)
- **2026-09-21 (Phiên 5 - Hỗ trợ LXDE / Openbox & Khắc phục Key Grab X11):**
  - Khắc phục lỗi nuốt phím tắt trên X11/Openbox: Tăng độ trễ nhả phím lên `0.25s` trong `lib/injector.sh`, sao chép dữ liệu vào cả clipboard và primary selection (`xclip`).
  - Xây dựng adapter tự động đăng ký phím tắt cho LXDE / Openbox: Tự động chuyển đổi sang cú pháp Openbox XML (`W-S-v`, `C-W-v`), cập nhật `lxde-rc.xml` / `rc.xml` và reload tức thì qua `openbox --reconfigure`.
  - Cập nhật nhận diện DE trong `lib/tui.sh` và `lib/doctor.sh`.
- **2026-09-21 (Phiên 4 - Kiểm thử KDE Plasma, ydotool Fallback & Phím tắt KDE/GNOME):**
  - Xử lý lỗi `wtype` không gõ được phím trên KDE Plasma / GNOME Wayland: Bắt mã lỗi exit code, fallback qua `ydotool` hoặc `stdout`, luôn đưa lệnh vào `wl-copy` để dán an toàn.
  - Tự động hóa đăng ký phím tắt cho KDE Plasma (`~/.config/kglobalshortcutsrc` + `tip-paste.desktop` + D-Bus KWin).
  - Tự động hóa đăng ký phím tắt cho GNOME thông qua `gsettings custom-keybindings`.
  - Nâng cấp `bin/tip`: Ưu tiên nạp thư viện cục bộ/người dùng trước thư viện hệ thống `/usr/lib/tip`.
  - Cập nhật `aur/PKGBUILD` và `README.md` hướng dẫn chi tiết cho KDE và GNOME.
- **2026-09-21 (Phiên 3 - AUR Packaging, Multi-distro Installer & Electron Fix):**
  - Xử lý dứt điểm lỗi scancode bàn phím ảo của `wtype` trên Chromium/Electron (Antigravity IDE/VS Code): Chuyển sang cơ chế dán tức thì qua Clipboard (`wl-copy` / `xclip`) kết hợp phím dán `Ctrl+Shift+V`.
  - Bổ sung cơ chế thông minh Smart Fallback: Tự động tái sử dụng `/tmp/clipboard.png` gần nhất khi clipboard không chứa ảnh mới, không bao giờ báo lỗi dừng vô cớ.
  - Xây dựng trình cài đặt tự động đa distro `install.sh`: Nhận diện `pacman`, `apt`, `dnf`, `zypper`, hỗ trợ cài đặt cả cấp hệ thống (`--system`) và cấp người dùng (`--user`), hỗ trợ gỡ cài đặt (`--uninstall`).
  - Đóng gói chuẩn Arch Linux AUR trong `aur/PKGBUILD` và sinh tệp siêu dữ liệu `aur/.SRCINFO`.
  - Cập nhật `bin/tip` phân giải linh hoạt đường dẫn thư viện (`/usr/lib/tip`, `/usr/local/lib/tip`, `~/.local/lib/tip`).
- **2026-09-20 (Phiên 2 - TUI, Shortcut & GitHub Release):**
  - Hoàn thành triển khai `lib/tui.sh` (Interactive TUI Menu) và `lib/shortcut.sh` (Global Shortcut Manager).
  - Tích hợp bộ giải mã CSI u escape sequences từ Ghostty/Kitty (`tip_decode_csi_u`) và hỗ trợ nhập phím tắt tùy ý.
  - Sửa lỗi vị trí khối binds trong Niri (`~/.config/niri/config.kdl`), đưa vào khối `binds` toàn cục chuẩn xác.
  - Thiết lập chế độ **Zero-RAM Bloat** (`FILENAME_FORMAT="static"`), luôn lưu đè vào `/tmp/clipboard.png`, loại bỏ tùy chọn markdown.
  - Quốc tế hóa toàn bộ mã nguồn sang tiếng Anh 100%.
  - Tạo `README.md`, `LICENSE` (MIT), `.gitignore` và phát hành lên GitHub: [https://github.com/chiconcota/terminal-image-paste](https://github.com/chiconcota/terminal-image-paste).
- **2026-09-20 (Phiên 1 - Core Engine):**
  - Hoàn thành triển khai và kiểm thử 100% Phase 1 (Core Engine & CLI Pipeline): `bin/tip`, `lib/logger.sh`, `lib/config.sh`, `lib/clipboard.sh`, `lib/formatter.sh`, `lib/injector.sh`, `lib/doctor.sh`.
  - Khởi tạo kho lưu trữ Git trên nhánh `main`.
- **2026-09-19:** 
  - Khởi tạo System Map cho dự án **Terminal Image Paste (`tip`)**.
  - Bổ sung `niri` vào danh sách Window Manager / Compositor hỗ trợ phím tắt.
  - Tối giản hóa kiểm lỗi: Loại bỏ `notify-send` (Zero-Popup), tập trung hoàn toàn vào kiểm tra log trên terminal (`tip log`, `tip log -f`) và chẩn đoán (`tip doctor`).