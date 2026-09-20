---
description: Bắt đầu phiên làm việc chuẩn Terminal Image Paste (Load Context & Memory)
---

1. **Khởi động bộ nhớ (Context Loading):**
   - Đọc file `.project-ai/2-memory/checkpoint.md` LÀ BƯỚC ĐẦU TIÊN để nhận bàn giao trạng thái công việc, Git branch, và task đang làm dở từ phiên trước.
   - Dựa trên file checkpoint, đọc file project manager đang làm trong thư mục `.project-ai/1-overview/project-managers/` để biết công việc đang ở giai đoạn nào.
   - Đọc file `.project-ai/1-overview/system_map.md`. Đây là bước BẮT BUỘC để nắm cấu trúc hệ thống.
   - Đọc file `.project-ai/2-memory/decision-log.md` để biết những quyết định thiết kế gần nhất.
   - Đọc file `.project-ai/2-memory/self-improve.md` để nạp danh sách lỗi hành vi cần tránh và quy tắc tự sửa lỗi của Agent.

2. **Xác định tiêu điểm & Nhánh làm việc (Focus & Git Branch Decision):**
   - Nếu người dùng chưa chỉ định rõ Module mục tiêu, hãy hỏi để cô lập vùng làm việc.
   - Kiểm tra nhánh Git hiện tại (dùng `git branch` hoặc `git status`).
   - Cùng người dùng quyết định: **Nên làm việc trực tiếp trên nhánh `main` hay cần khởi tạo/chuyển sang một nhánh tính năng mới (`feature/ten-tinh-nang`)?** 
   - Ghi nhận thông tin nhánh này để cập nhật vào `checkpoint.md` khi kết thúc phiên.

3. **Load Module Memory (Context-Switching):**
   - Dựa vào Module mục tiêu, đọc tài liệu liên quan trong thư mục `.project-ai/3-ecosystem/modules/`.
   - Lưu ý: Tuyệt đối KHÔNG đọc lộn tài liệu của Module không liên quan để tránh Hallucination/Tràn RAM.

4. **Sẵn sàng (Ready Check):**
   - Phản hồi ngắn gọn: "Đã nạp kiến trúc hệ thống (system_map.md) và Nhật ký tự cải thiện (self-improve.md). Đang làm việc trên nhánh Git: [Tên Nhánh]. Đang cô lập vùng làm việc vào Module: [Tên Module]. Sẵn sàng nhận lệnh."