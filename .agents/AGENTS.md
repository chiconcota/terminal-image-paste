# TERMINAL IMAGE PASTE: WORKSPACE AGENT CONFIGURATION (AGENTS.md)
This file integrates the system rules and workflows defined in the `.agent` folder of the workspace to guide the AI Agent's behavior, workflow protocols, and coding rules.

---

# SECTION 1: SYSTEM RULES & GUIDELINES

## 1. TERMINAL IMAGE PASTE SYSTEM RULES (project-rules.md)
@target: Terminal Image Paste | @architecture: Modular CLI / Daemon / Utility

### 0. KHẨU QUYẾT TỐI THƯỢNG (THE PRIME DIRECTIVES)
1. **Cross-Platform Clipboard & Terminal Support:** Ưu tiên hỗ trợ chuẩn xác các backend clipboard trên Linux (X11 với `xclip`/`xsel`, Wayland với `wl-clipboard`/`wl-paste`), macOS (`osascript`/`pngpaste`), và Windows (`PowerShell`/`clip`).
2. **Modular & Decoupled Architecture:** Tách biệt rõ ràng các tầng: Clipboard Listener/Reader, Image Processing/Converter, Terminal Renderer/Formatter, và Storage/File Manager.
3. **No-Lag, Zero Memory Leak:** Vì công cụ có thể chạy ngầm (daemon/watcher) hoặc thao tác nhanh trong terminal, quản lý tài nguyên bộ nhớ phải triệt để, giải phóng buffer ngay sau khi ghi file/render.
4. **Clean Code & Single Responsibility:** Mỗi hàm, module chỉ chịu trách nhiệm một tác vụ duy nhất. Không viết hàm quá 50 dòng, không để file vượt mốc 500 dòng.
5. **Fail-Safe & Graceful Fallback:** Khi không tìm thấy dữ liệu ảnh trong clipboard hoặc clipboard bị khóa bởi tiến trình khác, xử lý ngoại lệ mượt mà, thông báo rõ ràng, không làm crash shell/terminal.

### 1. PHÂN CHIA TRÁCH NHIỆM (MODULE RESPONSIBILITY)
- **Core / Engine:** Xử lý đọc dữ liệu nhị phân của ảnh từ clipboard, xác thực MIME type (image/png, image/jpeg, v.v.).
- **Storage / File Management:** Tạo đường dẫn, đặt tên file (timestamp, hash, custom prefix), lưu ảnh vào thư mục cấu hình.
- **Terminal Integration / Output:** Định dạng kết quả đầu ra phù hợp (chèn link markdown `![](path)`, path tương đối, path tuyệt đối, base64, hoặc ANSI/kitty/sixel graphic protocol).
- **CLI / Config:** Parser tham số dòng lệnh và đọc/ghi file cấu hình của người dùng.

### 2. AI WORKFLOW PROTOCOL BẮT BUỘC
- **Step 1 (Context):** Quét `.project-ai/1-overview/` để nắm giới hạn kiến trúc.
- **Step 2 (Schema / Interface First):** Thiết kế interface và signature của hàm/module TRƯỚC khi gõ code thực thi.
- **Step 3 (Targeted Changes):** Chỉ sửa các vùng code liên quan, tránh rewrite toàn bộ file.
- **Step 4 (Documentation Loop):** Sau khi hoàn thành tác vụ, cập nhật tài liệu và ghi log vào `.project-ai/2-memory/decision-log.md`.

### 3. VERSIONING RULES (QUY TẮC ĐÁNH DẤU PHIÊN BẢN)
- Tuân thủ chuẩn Semantic Versioning (`MAJOR.MINOR.PATCH`).
- Tăng PATCH cho bug fixes và tối ưu nhỏ.
- Tăng MINOR khi thêm cờ CLI, tính năng mới hoặc hỗ trợ định dạng/giao thức mới.
- Tăng MAJOR khi có thay đổi phá vỡ tương thích (breaking changes).

---

## 2. CLI & SYSTEM ARCHITECT RULES (cli-architect.md)
Role: Senior CLI & System Architect | Expert in CLI Tools, Clipboard APIs & Terminal Protocols.
Goal: Production-ready, secure, performant CLI & system tools. Priority: Reliability > Security > Performance > Simplicity.

### 1. SECURITY & INPUT SANITIZATION
- **Path Traversal Protection:** Sanitize all file paths and destination directories. Never allow unsanitized input to write to arbitrary system paths.
- **Subprocess Execution:** When calling external tools (`xclip`, `wl-paste`, etc.), always use array/list arguments to prevent shell injection. NEVER pass raw shell string (`shell=True` / `sh -c`) with untrusted input.
- **Sensitive Data:** Avoid leaking clipboard or path contents to unsecured logs.

### 2. CROSS-PLATFORM SYSTEM PROTOCOLS
- **Linux:**
  - X11: Support `xclip` (`-selection clipboard -target image/png`) or `xsel`.
  - Wayland: Support `wl-clipboard` (`wl-paste --type image/png`).
- **macOS:** Support `pngpaste` or `osascript`.
- **Windows:** Support PowerShell clipboard APIs.
- Auto-detect the display server / OS environment before executing commands.

### 3. PERFORMANCE & RESOURCE MANAGEMENT
- Stream binary data directly to file where possible, avoiding loading huge files into memory at once.
- Always close file descriptors and terminate background watcher child processes gracefully.

### 4. ERROR HANDLING
- Graceful error exits with meaningful status codes (`0` for success, non-zero for failure).
- Informative error messages sent to `stderr`, clean payload or empty string on `stdout`.
- Do not dump raw stack traces to end users unless a `--debug` / `--verbose` flag is passed.

---

## 3. DOCUMENTATION MANAGEMENT RULES (docs-management.md)
@target: All AI Agents | @trigger: /end_session or any documentation update

### 1. THIẾT QUÂN LUẬT KHÔNG RÁC (ZERO-TRASH DIRECTIVE)
Mọi tài liệu bắt buộc phải nằm gọn bên trong 4 ngăn kéo:
```text
.project-ai/
├── 1-overview/
│   ├── system_map.md           (Bản đồ kiến trúc tổng thể, Trạng thái Dự án, Nhật ký ngắn)
│   ├── architecture.md         (Kiến trúc kỹ thuật chi tiết)
│   ├── release-workflow.md     (Quy trình phát hành)
│   └── project-managers/       (Thư mục chứa các Roadmap, Kế hoạch cho từng Phase)
├── 2-memory/
│   ├── decision-log.md         (Quy định Kiến trúc lớn, Lịch sử thay đổi cốt lõi)
│   ├── checkpoint.md           (Bàn giao tiến độ dở dang và nhánh Git hiện tại cho phiên sau)
│   ├── self-improve.md         (Nhật ký giám sát lỗi hành vi của Agent)
│   └── archive/                (Lưu trữ các quyết định và log cũ của các Phase trước)
├── 3-ecosystem/
│   └── modules/                (Tài liệu kiến trúc từng module của dự án)
└── 4-rules/
    └── project-rules.md        (Quy chuẩn kỹ thuật và kiến trúc hệ thống)
```

### 2. QUY TRÌNH GHI ĐÈ CHỐNG LỖI (ANTI-DUPLICATION PROTOCOL)
- Trước khi cập nhật bất kỳ tài liệu nào (`system_map.md`, `decision-log.md`...), AI BẮT BUỘC phải kiểm tra sự tồn tại của file trước.
- **Nghiêm Cấm:** Tự ý tạo file mới đối với các file trung tâm nếu chưa kiểm tra file cũ.

### 3. LUẬT NGUYÊN TẮC /END_SESSION BẮT BUỘC
- Khi gọi luồng `/end_session`, AI phải Mở và Sửa nội dung TRỰC TIẾP lên các file cũ.
- Chỉ cập nhật **Tối đa 5 điểm chạm:**
  1. `1-overview/system_map.md` (Sửa trạng thái Status & Recent Logs).
  2. `2-memory/decision-log.md` (Chèn Note lên đầu file, di chuyển log quá hạn vào `archive/` nếu dài).
  3. `2-memory/checkpoint.md` (Bàn giao tiến độ dở dang và nhánh Git hiện tại cho phiên sau).
  4. `3-ecosystem/modules/` (Chỉnh sửa Kiến trúc module vừa Code xong).
  5. `1-overview/project-managers/` (Cập nhật tiến độ làm việc tương ứng với file phase đang làm việc).

---
---

# SECTION 2: SYSTEM WORKFLOWS

## 1. SESSION START WORKFLOW (start_session.md)
1. **Khởi động bộ nhớ (Context Loading):**
   - Đọc `.project-ai/2-memory/checkpoint.md` để nhận bàn giao.
   - Đọc file roadmap/phase tương ứng trong `.project-ai/1-overview/project-managers/`.
   - Đọc `.project-ai/1-overview/system_map.md`.
   - Đọc `.project-ai/2-memory/decision-log.md` và `.project-ai/2-memory/self-improve.md`.
2. **Xác định tiêu điểm & Nhánh làm việc (Focus & Git Branch Decision):**
   - Kiểm tra nhánh Git và thống nhất nhánh làm việc.
3. **Load Module Memory:**
   - Đọc tài liệu module liên quan trong `.project-ai/3-ecosystem/modules/`.
4. **Sẵn sàng (Ready Check):**
   - Phản hồi ngắn gọn và sẵn sàng nhận lệnh.

---

## 2. SESSION END WORKFLOW (end_session.md)
1. **Tổng hợp kiến thức:** Rà soát thay đổi kiến trúc và file đã chỉnh sửa.
2. **Cập nhật Module Documentation:** Ghi nhận trách nhiệm, API và luồng dữ liệu mới vào `.project-ai/3-ecosystem/modules/`.
3. **Ghi sổ quyết định:** Cập nhật `decision-log.md`, `system_map.md`, `project-managers/`, và `checkpoint.md`.
4. **Đánh giá phiên làm việc tương tác:** Trình bày lỗi hành vi (nếu có) để cập nhật `self-improve.md`.
5. **Xác nhận kết thúc:** Bàn giao rõ ràng và niêm phong sổ bộ nhớ.

---

## 3. DEBUG WORKFLOW (debug-workflow.md)
1. **Step 0 — Memory Check:** Đọc checkpoint và decision log.
2. **Step 1 — Comprehend & Clarify:** Trả lời "Logic gãy ở đâu?" và "Tại sao nó xảy ra?".
3. **Step 2 — Isolate & Impact Assessment:** Khoanh vùng file/line và đánh giá rủi ro lan tỏa.
4. **Step 3 — Surgical Solution Proposal:** Trình bày giải pháp và chờ User xác nhận.
5. **Step 4 — Execution & Verification:** Sửa targeted diff, test runtime thực tế và cleanup.

---

## 4. RELEASE AUTOMATION WORKFLOW (release-github.md)
1. **Prerequisites:** Cập nhật SemVer, ghi log vào `system_map.md`, đảm bảo git sạch.
2. **Execution:** Đánh tag `git tag vX.Y.Z`, `git push origin vX.Y.Z`, tạo release trên GitHub.
