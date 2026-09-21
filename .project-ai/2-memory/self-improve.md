# AGENT SELF-IMPROVEMENT LOG (self-improve.md)
@status: ACTIVE | @last_update: 2026-09-20

> Nhật ký tự cải thiện hành vi và sửa sai của Agent. Chứa các lỗi thao tác thực tế và quy tắc tự sửa lỗi.
> **Luật dọn dẹp:** File này không được vượt quá 80 dòng. Các lỗi đã giải quyết (Resolved) sau 3 phiên sẽ được lưu trữ.

---

## 🚨 DANH SÁCH LỖI HÀNH VI ĐANG ĐƯỢC GIÁM SÁT (ACTIVE)

### MISTAKE-001: Chạy lệnh terminal tương tác chờ input
- Lỗi: Chạy lệnh CLI tương tác trực tiếp mà không có cờ non-interactive gây treo lệnh.
- Sửa đổi: Luôn dùng cờ không tương tác (non-interactive) hoặc hỏi người dùng trước.

### MISTAKE-002: Lạm dụng Browser MCP & Screenshot
- Lỗi: Tự ý chạy DevTools, Browser Subagent hoặc chụp screenshot liên tục gây tốn token.
- Sửa đổi: Chỉ kích hoạt browser/screenshot khi User yêu cầu rõ ràng. Ưu tiên checklist cho User test tay.

### MISTAKE-003: ArtifactMetadata sai chỗ
- Lỗi: Dùng ArtifactMetadata cho file code nguồn dự án ngoài thư mục artifacts.
- Sửa đổi: Chỉ dùng cho file markdown trong thư mục artifacts của conversation.

### MISTAKE-004: Trả về non-zero trong hàm chẩn đoán khi bật `set -e`
- Lỗi: Hàm kiểm tra tùy chọn trả về mã lỗi 2 khiến script bash có `set -e` ngắt tiến trình đột ngột.
- Sửa đổi: Các hàm kiểm tra/chẩn đoán tùy chọn phải luôn trả về 0 hoặc bọc `|| true` để không phá vỡ cờ `set -e`.

### MISTAKE-005: Xung đột ký tự phân cách của `sed` với đường dẫn file
- Lỗi: Dùng `sed -i "s/.../.../"` khi chuỗi thay thế chứa đường dẫn `/mnt/Data/...` gây lỗi cú pháp `unknown option to 's'`.
- Sửa đổi: Khi chèn/thay thế chuỗi có đường dẫn hoặc ký tự đặc biệt, ưu tiên sử dụng `awk -v line="..."` để truyền biến an toàn tuyệt đối.

### MISTAKE-007: Nuốt lỗi công cụ gõ phím ảo trên Wayland
- Lỗi: Dùng `wtype ... 2>/dev/null` rồi `return 0` vô điều kiện khiến `tip` im lặng nuốt lỗi khi chạy trên compositor không hỗ trợ virtual keyboard (KWin/Mutter).
- Sửa đổi: Luôn kiểm tra exit code thực tế của các công cụ Wayland (`if wtype ...; then ...; fi`), ghi log cảnh báo chi tiết và kích hoạt fallback (`ydotool` / stdout) thay vì trả về thành công giả.

