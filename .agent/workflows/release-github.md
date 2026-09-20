---
description: RELEASE AUTOMATION WORKFLOW
---

# RELEASE AUTOMATION WORKFLOW
@status: IMPLEMENTED | @purpose: Quy trình đóng gói & Phát hành phiên bản mới

Tài liệu này hướng dẫn cách đóng gói và phát hành phiên bản mới của **Terminal Image Paste** lên GitHub Releases.

---

## 1. ĐIỀU KIỆN TIÊN QUYẾT (PREREQUISITES)
1. **Nâng cấp số phiên bản (SemVer):** Cập nhật số phiên bản trong file cấu hình dự án (ví dụ `package.json`, `Cargo.toml`, `pyproject.toml`, hoặc hằng số `VERSION`).
2. **Ghi log hệ thống:** Viết đầy đủ nhật ký thay đổi của phiên bản mới vào `system_map.md` và `decision-log.md`.
3. **Môi trường Git sạch:** Đã commit toàn bộ code mới trên nhánh đang làm việc.

---

## 2. QUY TRÌNH PHÁT HÀNH CHI TIẾT
1. **Đánh Tag Git & Push lên GitHub:**
   ```bash
   git tag vX.Y.Z
   git push origin vX.Y.Z
   ```
2. **Tạo Release trên GitHub:**
   - Truy cập trang GitHub Releases của repository.
   - Nhập tiêu đề: `Release vX.Y.Z`.
   - Dán nội dung release notes.
   - Đính kèm binaries/packages (nếu có) và Publish.
