# TERMINAL IMAGE PASTE: SYSTEM & ARCHITECTURE RULES
@target: Terminal Image Paste | @architecture: Modular CLI / Daemon / Utility

## 0. KHẨU QUYẾT TỐI THƯỢNG (THE PRIME DIRECTIVES)
1. **Cross-Platform Clipboard & Terminal Support:** Ưu tiên hỗ trợ chuẩn xác các backend clipboard trên Linux (X11 với `xclip`/`xsel`, Wayland với `wl-clipboard`/`wl-paste`), macOS (`osascript`/`pngpaste`), và Windows (`PowerShell`/`clip`).
2. **Modular & Decoupled Architecture:** Tách biệt rõ ràng các tầng: Clipboard Listener/Reader, Image Processing/Converter, Terminal Renderer/Formatter, và Storage/File Manager.
3. **No-Lag, Zero Memory Leak:** Vì công cụ có thể chạy ngầm (daemon/watcher) hoặc thao tác nhanh trong terminal, quản lý tài nguyên bộ nhớ phải triệt để, giải phóng buffer ngay sau khi ghi file/render.
4. **Clean Code & Single Responsibility:** Mỗi hàm, module chỉ chịu trách nhiệm một tác vụ duy nhất. Không viết hàm quá 50 dòng, không để file vượt mốc 500 dòng.
5. **Fail-Safe & Graceful Fallback:** Khi không tìm thấy dữ liệu ảnh trong clipboard hoặc clipboard bị khóa bởi tiến trình khác, xử lý ngoại lệ mượt mà, thông báo rõ ràng, không làm crash shell/terminal.

## 1. PHÂN CHIA TRÁCH NHIỆM (MODULE RESPONSIBILITY)
- **Core / Engine:** Xử lý đọc dữ liệu nhị phân của ảnh từ clipboard, xác thực MIME type (image/png, image/jpeg, v.v.).
- **Storage / File Management:** Tạo đường dẫn, đặt tên file (timestamp, hash, custom prefix), lưu ảnh vào thư mục cấu hình.
- **Terminal Integration / Output:** Định dạng kết quả đầu ra phù hợp (chèn link markdown `![](path)`, path tương đối, path tuyệt đối, base64, hoặc ANSI/kitty/sixel graphic protocol).
- **CLI / Config:** Parser tham số dòng lệnh và đọc/ghi file cấu hình của người dùng.

## 2. AI WORKFLOW PROTOCOL BẮT BUỘC
- **Step 1 (Context):** Quét `.project-ai/1-overview/` để nắm giới hạn kiến trúc.
- **Step 2 (Schema / Interface First):** Thiết kế interface và signature của hàm/module TRƯỚC khi gõ code thực thi.
- **Step 3 (Targeted Changes):** Chỉ sửa các vùng code liên quan, tránh rewrite toàn bộ file.
- **Step 4 (Documentation Loop):** Sau khi hoàn thành tác vụ, cập nhật tài liệu và ghi log vào `.project-ai/2-memory/decision-log.md`.

## 3. VERSIONING RULES (QUY TẮC ĐÁNH DẤU PHIÊN BẢN)
- Tuân thủ chuẩn Semantic Versioning (`MAJOR.MINOR.PATCH`).
- Tăng PATCH cho bug fixes và tối ưu nhỏ.
- Tăng MINOR khi thêm cờ CLI, tính năng mới hoặc hỗ trợ định dạng/giao thức mới.
- Tăng MAJOR khi có thay đổi phá vỡ tương thích (breaking changes).
