# ✅ Templates Checklist — Story Platform

> **Mục đích**: Các template checklist sẵn có cho mọi task. Copy và điều chỉnh theo task cụ thể.

> **Cập nhật lần cuối**: 2026-03-01

---

## 1. Checklist Trước Khi Code (Pre-Coding)

```markdown
## Pre-Coding Checklist: [Tên Task]

### Phân tích

- [ ] Requirements đã rõ ràng (không còn câu hỏi mở)
- [ ] Đã đọc `REUSABLE-COMPONENTS.md` — đánh giá tái sử dụng
- [ ] Đã đọc `FOLDER-STRUCTURE.md` — biết đặt file ở đâu
- [ ] Đã đọc `CODING-STANDARDS.md` — nắm quy tắc

### Kế hoạch

- [ ] Có sơ đồ hoạt động (activity diagram)
- [ ] Đã liệt kê files cần tạo/sửa
- [ ] Đã liệt kê components cần tạo/reuse
- [ ] Đã xác định dependencies cần cài thêm
- [ ] Đã xác định API endpoints liên quan

### Database (nếu có)

- [ ] Schema changes đã thiết kế
- [ ] Migration plan rõ ràng
- [ ] Indexes đã cân nhắc
```

---

## 2. Checklist Sau Khi Code (Post-Coding)

```markdown
## Post-Coding Checklist: [Tên Task]

### Code Quality

- [ ] Không có `any` trong code
- [ ] Không có `console.log` cho production
- [ ] Tất cả biến, hàm đặt tên đúng convention
- [ ] Import đúng thứ tự (React → Third-party → Internal)
- [ ] Không có unused imports/variables

### TypeScript

- [ ] Tất cả props đã có interface/type
- [ ] Không có type assertion không cần thiết (`as`)
- [ ] Generic types dùng đúng (`ApiResponse<Story>`)

### UI/UX

- [ ] Responsive (mobile 375px, tablet 768px, desktop 1024px+)
- [ ] Dark mode hoạt động đúng
- [ ] Loading states hiển thị
- [ ] Empty states hiển thị
- [ ] Error states hiển thị
- [ ] Skeleton loading cho data fetch

### Accessibility

- [ ] Tất cả `<img>` có `alt` text
- [ ] Tất cả interactive elements có `aria-label` (nếu không có visible text)
- [ ] Color contrast đủ (WCAG AA: 4.5:1)
- [ ] Keyboard navigation hoạt động
- [ ] Focus visible trên tất cả focusable elements

### Performance

- [ ] Images dùng `next/image` với `priority` cho above-the-fold
- [ ] Không N+1 queries
- [ ] Bundle import tối ưu (không barrel imports nặng)
- [ ] Framer Motion animations dùng `transform` (hardware-accelerated)
```

---

## 3. Checklist Review Code

```markdown
## Code Review Checklist: [PR/Feature Name]

### Logic

- [ ] Business logic đúng theo requirements
- [ ] Edge cases đã xử lý
- [ ] Error handling đầy đủ (try/catch, error boundaries)
- [ ] Không hardcode giá trị magic (dùng constants)

### Security

- [ ] Input đã validate (Zod schemas)
- [ ] Không hardcode secrets/API keys
- [ ] Auth check trên protected routes
- [ ] XSS prevention (DOMPurify cho rich text)
- [ ] SQL injection prevention (Prisma parameterized)

### Reusability

- [ ] Component mới có cần dùng chung? → Đặt đúng folder
- [ ] `REUSABLE-COMPONENTS.md` đã cập nhật
- [ ] Hook mới có generic? → Tách ra `hooks/`

### Documentation

- [ ] JSDoc cho hàm phức tạp
- [ ] `REUSABLE-COMPONENTS.md` cập nhật (nếu tạo component mới)
- [ ] `FOLDER-STRUCTURE.md` cập nhật (nếu thêm folder mới)
```

---

## 4. Checklist Trước Khi Deploy (Pre-Deploy)

```markdown
## Pre-Deploy Checklist: [Version/Release]

### Build

- [ ] `pnpm build` thành công, không lỗi
- [ ] `pnpm lint` không có errors
- [ ] `pnpm format:check` pass
- [ ] TypeScript compilation thành công

### Testing

- [ ] Unit tests pass
- [ ] Integration tests pass (nếu có)
- [ ] Manual testing trên browser hoàn thành
- [ ] Responsive testing pass (mobile, tablet, desktop)

### Environment

- [ ] Environment variables đã set trên production
  - [ ] `NEXT_PUBLIC_API_URL`
  - [ ] `NEXT_PUBLIC_CLOUDINARY_CLOUD_NAME`
  - [ ] Các biến khác theo tính năng
- [ ] Database migrations đã chạy
- [ ] SSL/HTTPS đã cấu hình

### Monitoring

- [ ] Sentry configured
- [ ] Error tracking active
- [ ] Vercel Analytics enabled (nếu dùng Vercel)

### Rollback

- [ ] Biết cách rollback nếu cần
- [ ] Database backup trước migration (production)
```

---

## 5. Checklist Security Audit

```markdown
## Security Audit Checklist: [Feature/Module]

### Authentication

- [ ] Password hash bcrypt (salt rounds >= 12)
- [ ] JWT access token ngắn hạn (15 phút)
- [ ] Refresh token lưu httpOnly cookie
- [ ] Logout xoá token đúng cách
- [ ] OAuth state parameter chống CSRF

### Authorization

- [ ] Protected routes kiểm tra auth
- [ ] Role-based access control (RBAC) đúng
- [ ] Users chỉ truy cập dữ liệu của mình
- [ ] Admin-only routes được bảo vệ

### Input Validation

- [ ] Tất cả API input validate bằng Zod/class-validator
- [ ] Rich text content sanitize bằng DOMPurify
- [ ] File upload validate type + size
- [ ] URL parameters validate

### Headers & Transport

- [ ] CORS whitelist chỉ frontend domain
- [ ] HTTPS enforced
- [ ] Sensitive data không log
- [ ] Rate limiting trên auth endpoints

### Data

- [ ] Không expose internal IDs không cần thiết
- [ ] Pagination limit có max cap
- [ ] Sensitive fields không trả về client (passwordHash)
```

---

## 6. Checklist Tính Năng (Feature-Specific)

### Template cho Story CRUD

```markdown
## Feature: Story CRUD

### Tạo truyện

- [ ] Form có fields: title, description, cover image, genres, tags
- [ ] Validation: title required (3-200 chars), description optional
- [ ] Cover image upload qua presigned URL
- [ ] Slug tự sinh từ title (unique)
- [ ] Trạng thái mặc định: DRAFT

### Sửa truyện

- [ ] Chỉ author hoặc admin sửa được
- [ ] Giữ nguyên slug cũ (không đổi URL)
- [ ] Update genres/tags

### Xoá truyện

- [ ] Confirm dialog trước khi xoá
- [ ] Cascade delete chapters
- [ ] Soft delete (đổi status sang HIDDEN) hay hard delete?

### Publish/Unpublish

- [ ] Chỉ author thay đổi status
- [ ] Publish set `publishedAt` = now
- [ ] Unpublish giữ nguyên `publishedAt`
```

### Template cho Auth Flow

```markdown
## Feature: Authentication

### Đăng ký

- [ ] Form: email, password, confirm password, display name
- [ ] Email format validation
- [ ] Password strength: min 8 chars, 1 uppercase, 1 number
- [ ] Check email đã tồn tại
- [ ] Gửi email verification

### Đăng nhập

- [ ] Form: email, password
- [ ] Remember me option
- [ ] Hiển thị lỗi "Email hoặc mật khẩu không đúng" (không reveal nào sai)
- [ ] Rate limit: 5 lần/phút

### Quên mật khẩu

- [ ] Form: email
- [ ] Gửi OTP/link reset
- [ ] Link hết hạn sau 15 phút
- [ ] Không reveal email có tồn tại hay không

### Google OAuth

- [ ] Button "Đăng nhập bằng Google"
- [ ] Tạo tài khoản mới nếu chưa có
- [ ] Link với tài khoản cũ nếu email trùng
```

---

## 7. Cách Sử Dụng

1. **Copy template** phù hợp vào kế hoạch task
2. **Tuỳ chỉnh** thêm/bớt items theo task cụ thể
3. **Đánh dấu** `[x]` khi hoàn thành
4. **Include** vào Final Report (Phase 5 của WORKFLOW-GUIDE.md)

---

> **Tài liệu liên quan**: [WORKFLOW-GUIDE.md](./WORKFLOW-GUIDE.md) · [TESTING-GUIDE.md](./TESTING-GUIDE.md) · [CODING-STANDARDS.md](./CODING-STANDARDS.md)
