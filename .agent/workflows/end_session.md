---
description: Kết thúc phiên làm việc Terminal Image Paste (Ghi nhớ kiến trúc & Decision Log)
---

Bước 1. **Tổng hợp kiến thức (Knowledge Consolidation):**
   - Rà soát lại toàn bộ các tool `write_to_file`, `replace_file_content` đã thực hiện trong phiên hiện tại.
   - Xác định các thay đổi kiến trúc: Có thêm module, interface, CLI flag hoặc sự kiện mới nào không?

Bước 2. **Cập nhật Module Documentation:**
   - Mở thư mục `.project-ai/3-ecosystem/modules/` và tìm module tương ứng vừa thao tác.
   - Tạo hoặc Cập nhật file markdown kiến trúc của module đó với nội dung:
     - Trách nhiệm của module.
     - Interface/API được expose cho các module khác.
     - Luồng dữ liệu mới.

Bước 3. **Ghi sổ quyết định (Decision Log, System Map, self-improve & Update):**
   - Đọc và cập nhật file `.project-ai/2-memory/decision-log.md` bằng cách thêm ngày hôm nay và các Quyết Định Kỹ Thuật Lõi (Core Technical Decisions) đã được chốt/triển khai.
   - Đọc và cập nhật file `.project-ai/1-overview/system_map.md`:
     - **Tình trạng Module:** Chuyển trạng thái từ 🔴 Pending -> 🟡 In Progress -> 🟢 Done trong bảng Module Registry.
     - **Change Log:** Thêm dòng gạch đầu dòng ngắn gọn cho ngày cập nhật.
   - Mở và GHI ĐÈ dữ liệu vào file tương ứng trong `.project-ai/1-overview/project-managers/` để lưu lại tiến độ dự án.
   - Mở và GHI ĐÈ dữ liệu vào file `.project-ai/2-memory/checkpoint.md` để lưu lại tiến độ đang code dở, danh sách file, các lỗi hiện tại, và đặc biệt phải ghi rõ tên nhánh Git hiện tại đang làm việc để bàn giao cho Agent phiên sau.
   - Cập nhật Git: Hỏi ý kiến User xem có nên commit và push lên GitHub không? Nếu đang ở nhánh feature, có cần tạo Pull Request hoặc merge vào `main` luôn không? Thực hiện theo quyết định của User.

Bước 4. **Đánh giá phiên làm việc tương tác (Interactive Session Review & self-improve):**
   - AI dự thảo danh sách các lỗi hành vi (mistakes) hoặc quy tắc tự sửa lỗi mới phát sinh trong phiên.
   - Trình bày danh sách này cho User để nhận phản hồi: *"Bạn có đồng ý ghi nhận các lỗi/quy tắc tự sửa đổi này vào self-improve.md không?"*.
   - Chỉ cập nhật tệp `.project-ai/2-memory/self-improve.md` sau khi User đồng ý hoặc đưa ra chỉnh sửa.
   - Cập nhật trạng thái các lỗi đã giải quyết (Resolved). Nếu độ dài file vượt quá 80 dòng, thực hiện rút gọn, gộp nhóm và di chuyển các lỗi đã sửa lâu ngày vào `.project-ai/2-memory/archive/mistake-history.md`.

Bước 5. **Xác nhận kết thúc:**
   - Thông báo rõ ràng: "Sổ bộ nhớ dự án đã được niêm phong. 
     - Nhánh Git làm việc: [Tên Nhánh] (Đã ghi nhận tại checkpoint.md)
     - Trạng thái Push/Merge: [Quyết định và kết quả đã thực hiện]
     - File bàn giao (Checkpoint) đã được lưu mốc an toàn.
     - Danh sách công việc (project manager) đã được cập nhật.
     - Lịch sử thiết kế được dán vào Decision Log.
     Phiên làm việc kết thúc an toàn, hệ sinh thái sẵn sàng cho phiên kế tiếp không mất ngữ cảnh."