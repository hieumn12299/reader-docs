# 🔄 Quy Trình Làm Việc — Story Platform

> **Mục đích**: Hướng dẫn quy trình từ nhận task → lên kế hoạch → thực thi → kiểm tra → bàn giao. Áp dụng cho mọi task.

> **Cập nhật lần cuối**: 2026-03-01

---

## 1. Quy Trình Tổng Quát

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  1. NHẬN    │────▶│ 2. LÊN KẾ  │────▶│ 3. THỰC     │────▶│ 4. KIỂM    │────▶│ 5. BÀN     │
│    TASK     │     │   HOẠCH     │     │    THI      │     │    TRA     │     │   GIAO     │
└─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘
   Đọc docs          Activity diagram    Code + test         Lint + test          Report
   Đánh giá reuse    Checklist           Update docs         Browser test         Walkthrough
```

---

## 2. Phase 1: Nhận Task

### Bước 1.1 — Đọc tài liệu liên quan

Agent **BẮT BUỘC** đọc các file sau trước khi bắt đầu:

| File                     | Mục đích                                |
| ------------------------ | --------------------------------------- |
| `REUSABLE-COMPONENTS.md` | Đánh giá component nào tái sử dụng được |
| `FOLDER-STRUCTURE.md`    | Biết đặt file mới ở đâu                 |
| `CODING-STANDARDS.md`    | Tuân thủ quy tắc code                   |

### Bước 1.2 — Đánh giá tái sử dụng

```
Với mỗi component/hook cần tạo:
├── Đã có trong REUSABLE-COMPONENTS.md?
│   ├── CÓ → Reuse, update nếu cần
│   └── KHÔNG → Tạo mới
│       ├── Dùng ở 1 feature → Đặt trong features/
│       └── Dùng ở 2+ features → Đặt ở shared + thêm vào doc
```

---

## 3. Phase 2: Lên Kế Hoạch

### Bước 2.1 — Sơ đồ hoạt động

Mỗi task PHẢI có sơ đồ hoạt động (dùng Mermaid):

```mermaid
flowchart TD
    A[User click "Tạo truyện"] --> B{Đã đăng nhập?}
    B -->|Có| C[Hiển thị form tạo truyện]
    B -->|Không| D[Redirect đến login]
    C --> E[Nhập title, description]
    E --> F[Upload cover image]
    F --> G{Validate form}
    G -->|Hợp lệ| H[Gọi API POST /stories]
    G -->|Lỗi| I[Hiển thị error messages]
    H -->|Thành công| J[Redirect đến story editor]
    H -->|Lỗi| K[Hiển thị thông báo lỗi]
```

### Bước 2.2 — Checklist chức năng

Tạo checklist dựa trên template từ `CHECKLIST-TEMPLATES.md`:

```markdown
## Checklist: [Tên tính năng]

### Chức năng

- [ ] Mô tả chức năng 1
- [ ] Mô tả chức năng 2

### UI/UX

- [ ] Responsive mobile
- [ ] Dark mode
- [ ] Loading states

### Error handling

- [ ] Validation errors
- [ ] API errors
- [ ] Network errors
```

### Bước 2.3 — Điểm cần lưu ý

Liệt kê:

- Các edge cases
- Dependencies cần cài thêm
- Components cần tạo/sửa
- Files cần cập nhật

---

## 4. Phase 3: Thực Thi

### Bước 3.1 — Code

- Tuân thủ `CODING-STANDARDS.md`
- **KHÔNG dùng `any`**
- Đặt file đúng theo `FOLDER-STRUCTURE.md`

### Bước 3.2 — Cập nhật docs liên quan

| Khi...                   | Cập nhật...                     |
| ------------------------ | ------------------------------- |
| Tạo component dùng chung | `REUSABLE-COMPONENTS.md`        |
| Thêm file/folder mới     | `FOLDER-STRUCTURE.md` (nếu cần) |
| Thêm dependency          | `ARCHITECTURE.md`               |
| Thay đổi API             | Type files + Service files      |

---

## 5. Phase 4: Kiểm Tra (Trước Khi Bàn Giao)

### Bước 4.1 — Code Quality

```bash
# BẮT BUỘC, không có lỗi/warning
pnpm lint
pnpm format:check
```

### Bước 4.2 — Test

Xem `TESTING-GUIDE.md` để biết chiến lược test.

### Bước 4.3 — Browser Test (nếu đủ điều kiện)

Khi có dev server chạy, mở browser để:

- Kiểm tra UI render đúng
- Test responsive (mobile, tablet, desktop)
- Test dark mode
- Test navigation
- Test form validation

---

## 6. Phase 5: Bàn Giao — Bản Hoàn Chỉnh

### Yêu cầu bản hoàn chỉnh (Final Report):

```markdown
# Báo Cáo Hoàn Thành: [Tên Task]

## 1. Tổng Quan

- Mô tả task đã thực hiện
- Thời gian thực thi

## 2. Sơ Đồ Hoạt Động

- [Mermaid diagram]

## 3. Files Đã Thay Đổi

| File    | Hành động         | Mô tả |
| ------- | ----------------- | ----- |
| src/... | Tạo mới / Sửa đổi | ...   |

## 4. Checklist Chức Năng

- [x] Chức năng 1
- [x] Chức năng 2
- [x] Responsive
- [x] Dark mode

## 5. Điểm Cần Lưu Ý

- ...

## 6. Kết Quả Kiểm Tra

- [ ] ESLint: Không lỗi / Không warning
- [ ] Prettier: Đã format
- [ ] Browser test: [Kết quả]

## 7. Test Cases

Xem TESTING-GUIDE.md

## 8. Docs Đã Cập Nhật

- [ ] REUSABLE-COMPONENTS.md
- [ ] FOLDER-STRUCTURE.md
- [ ] Khác: ...
```

---

## 7. Skills & Workflows Thực Tế

### 4 Skills có sẵn

| Skill                         | Khi nào dùng                            | File                                                 |
| ----------------------------- | --------------------------------------- | ---------------------------------------------------- |
| `tiptap`                      | Rich text editor (viết truyện, comment) | `.agent/skills/tiptap/SKILL.md`                      |
| `vercel-react-best-practices` | Viết React/Next.js code                 | `.agent/skills/vercel-react-best-practices/SKILL.md` |
| `vercel-composition-patterns` | Refactor components, compound patterns  | `.agent/skills/vercel-composition-patterns/SKILL.md` |
| `web-design-guidelines`       | Audit UI accessibility                  | `.agent/skills/web-design-guidelines/SKILL.md`       |

### 13 Workflow Commands

| Command         | Mục đích                 |
| --------------- | ------------------------ |
| `/plan`         | Lập kế hoạch task        |
| `/create`       | Tạo app mới              |
| `/enhance`      | Thêm/cập nhật tính năng  |
| `/debug`        | Debug lỗi có phương pháp |
| `/test`         | Viết/chạy tests          |
| `/brainstorm`   | Khám phá ý tưởng         |
| `/preview`      | Quản lý dev server       |
| `/deploy`       | Deploy production        |
| `/review-ui`    | Review UI/UX/a11y        |
| `/orchestrate`  | Điều phối multi-agent    |
| `/status`       | Xem tiến độ              |
| `/tiptap`       | Setup Tiptap editor      |
| `/ARCHITECTURE` | Xem kiến trúc            |

### Auto-Skill Loading

Agent tự động load skill dựa trên keywords trong request:

| Keywords                             | Skill được load                                |
| ------------------------------------ | ---------------------------------------------- |
| "performance", "optimize", "bundle"  | `vercel-react-best-practices`                  |
| "refactor", "component", "compound"  | `vercel-composition-patterns`                  |
| "editor", "tiptap", "rich text"      | `tiptap`                                       |
| "review ui", "accessibility", "a11y" | `web-design-guidelines`                        |
| "re-render", "memo", "useCallback"   | `vercel-react-best-practices` (rerender rules) |

Chi tiết mapping: xem `.agent/rules/auto-skill-loading.md`

---

> **Tài liệu liên quan**: [CHECKLIST-TEMPLATES.md](./CHECKLIST-TEMPLATES.md) · [TESTING-GUIDE.md](./TESTING-GUIDE.md) · [CODING-STANDARDS.md](./CODING-STANDARDS.md)
