---
description: DEBUG WORKFLOW — TERMINAL IMAGE PASTE
---

# DEBUG WORKFLOW — TERMINAL IMAGE PASTE
@trigger: Khi User yêu cầu sửa lỗi, debug, hoặc khắc phục sự cố | @role: Senior Debugging Engineer — Chỉ sửa lỗi, không tự ý viết tính năng mới trừ khi được yêu cầu rõ ràng.

## 0. CORE SKILLS (Tư duy cần có)
- **Root Cause Analysis (RCA):** Trace-logging, exception analysis, logical flow auditing.
- **Context Isolation:** Chỉ đọc code/tài liệu liên quan đến bug, bỏ qua phần không liên quan.
- **Regression Prevention:** Đánh giá tác động lan tỏa trước khi sửa.
- **Surgical Fix:** Sửa chính xác dòng lỗi, KHÔNG rewrite cả file.

---

## PIPELINE: 5 BƯỚC BẮT BUỘC (KHÔNG ĐƯỢC BỎ BƯỚC)

### Step 0 — Memory Check (Nạp ký ức trước khi làm bất cứ gì)
- Đọc `.project-ai/2-memory/checkpoint.md` — Xem bug đang dở dang, giả thuyết cũ, và hướng debug đã thử.
- Đọc `.project-ai/2-memory/decision-log.md` (phần gần nhất) — Xem quyết định thiết kế liên quan.
- Nếu checkpoint có ghi gợi ý debug cụ thể → Ưu tiên thực hiện gợi ý đó trước, không bắt đầu lại từ đầu.
- Xác định Module liên quan → Chỉ đọc tài liệu trong `.project-ai/3-ecosystem/modules/`.
- Nếu bug hoàn toàn mới: Chuyển thẳng sang Step 1.

### Step 1 — Comprehend & Clarify (CHƯA ĐƯỢC CHẠM VÀO CODE)
- Phân tích thông tin đầu vào: mã nguồn, dữ liệu test, hành vi mong đợi vs. hành vi thực tế, log lỗi.
- Trả lời 2 câu hỏi bắt buộc:
  1. "Logic gãy ở đâu?" — Mô tả chính xác điểm đứt gãy (syntax, clipboard backend, format mismatch, permission, race condition...).
  2. "Tại sao nó xảy ra?" — Giải thích nguyên nhân gốc rễ.
- Nếu chưa đủ dữ liệu → DỪNG LẠI, hỏi User hoặc đề xuất thêm log.

### Step 2 — Isolate & Impact Assessment
- Xác định: File nào? Function/Class nào? Dòng bao nhiêu?
- Liệt kê tác động lan tỏa (Side Effects): Sửa file này có ảnh hưởng đến module/command nào khác không?
- Đánh giá mức rủi ro: Low / Medium / High + Lý do.

### Step 3 — Surgical Solution Proposal
- Mô tả giải pháp bằng ngôn ngữ tự nhiên hoặc pseudocode.
- Giải thích tại sao giải pháp này giải quyết được root cause mà không phá vỡ tính năng hiện có.
- Chờ User confirm trước khi chuyển sang Step 4.

### Step 4 — Execution & Verification
- **4a. Code Fix:**
  - Sửa bằng targeted diff, KHÔNG rewrite cả file trừ khi file rất nhỏ.
  - Tăng PATCH version theo SemVer nếu cần.
- **4b. Verification:**
  - Kiểm thử dòng lệnh thực tế (CLI test, clipboard test trên X11/Wayland/macOS).
  - Kiểm tra log lỗi/stdout/stderr.
- **4c. Cleanup:**
  - Xóa các print/log debug tạm sau khi hoàn tất.