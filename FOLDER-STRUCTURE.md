# 📁 Cấu Trúc Thư Mục — Story Platform

> **Mục đích**: Quy ước cấu trúc thư mục cho cả Frontend và Backend. Mọi file mới tạo phải tuân theo cấu trúc này.

> **Cập nhật lần cuối**: 2026-03-01

---

## 1. Frontend (Next.js 16)

```
src/
├── app/                              # Next.js App Router
│   ├── [locale]/                     # Đa ngôn ngữ (next-intl)
│   │   ├── layout.tsx                # Layout chung cho locale
│   │   ├── page.tsx                  # Trang chủ
│   │   ├── not-found.tsx             # Trang 404
│   │   ├── (auth)/                   # Route group: Xác thực
│   │   │   ├── login/page.tsx
│   │   │   ├── register/page.tsx
│   │   │   └── forgot-password/page.tsx
│   │   ├── (reader)/                 # Route group: Đọc truyện
│   │   │   ├── story/[id]/page.tsx
│   │   │   └── story/[id]/chapter/[chapterId]/page.tsx
│   │   ├── (writer)/                 # Route group: Viết truyện
│   │   │   ├── dashboard/page.tsx
│   │   │   ├── story/[id]/edit/page.tsx
│   │   │   └── chapter/[id]/edit/page.tsx
│   │   ├── (discover)/               # Route group: Khám phá
│   │   │   ├── search/page.tsx
│   │   │   ├── trending/page.tsx
│   │   │   └── genre/[slug]/page.tsx
│   │   └── (admin)/                  # Route group: Quản trị
│   │       └── dashboard/page.tsx
│   ├── globals.css                   # CSS toàn cục + Tailwind
│   └── layout.tsx                    # Root layout
│
├── components/                       # Components
│   ├── ui/                           # 🔄 DÙNG CHUNG: Base components
│   │   ├── button.tsx                # shadcn/ui pattern
│   │   ├── card.tsx
│   │   ├── input.tsx
│   │   ├── dialog.tsx
│   │   └── ...
│   ├── layout/                       # 🔄 DÙNG CHUNG: Layout components
│   │   ├── navbar.tsx
│   │   ├── footer.tsx
│   │   └── sidebar.tsx
│   ├── providers/                    # 🔄 DÙNG CHUNG: Context providers
│   │   ├── theme-provider.tsx
│   │   ├── query-provider.tsx
│   │   └── auth-provider.tsx
│   └── features/                     # 📦 THEO TÍNH NĂNG
│       ├── auth/                     # Components chỉ dùng cho auth
│       │   ├── login-form.tsx
│       │   ├── register-form.tsx
│       │   └── social-login-button.tsx
│       ├── story/                    # Components cho story
│       │   ├── story-card.tsx
│       │   ├── story-list.tsx
│       │   └── story-filters.tsx
│       ├── reader/                   # Components cho đọc truyện
│       │   ├── chapter-reader.tsx
│       │   ├── reading-progress-bar.tsx
│       │   └── reading-settings.tsx
│       ├── editor/                   # Components cho viết truyện
│       │   ├── tiptap-editor.tsx
│       │   ├── chapter-form.tsx
│       │   └── image-upload.tsx
│       └── dashboard/               # Components cho dashboard
│           ├── stats-overview.tsx
│           └── story-manager.tsx
│
├── hooks/                            # Custom hooks
│   ├── use-auth.ts                   # 🔄 DÙNG CHUNG
│   ├── use-media-query.ts            # 🔄 DÙNG CHUNG
│   ├── use-debounce.ts               # 🔄 DÙNG CHUNG
│   ├── use-local-storage.ts          # 🔄 DÙNG CHUNG
│   └── features/                     # 📦 THEO TÍNH NĂNG
│       ├── use-reading-progress.ts
│       ├── use-stories.ts
│       └── use-comments.ts
│
├── stores/                           # Zustand stores
│   ├── auth.store.ts                 # Trạng thái xác thực
│   ├── reading.store.ts              # Cài đặt đọc (font, cỡ chữ)
│   └── ui.store.ts                   # Trạng thái UI (sidebar, modal)
│
├── services/                         # API service layers
│   ├── api.ts                        # fetch wrapper (baseURL, interceptors)
│   ├── auth.service.ts               # Login, register, refresh token
│   ├── story.service.ts              # Story CRUD
│   ├── chapter.service.ts            # Chapter CRUD
│   ├── user.service.ts               # User profile
│   ├── interaction.service.ts        # Like, bookmark, follow
│   └── upload.service.ts             # Presigned URL, upload
│
├── lib/                              # Utilities & types
│   ├── utils.ts                      # cn(), formatDate(), truncate()...
│   ├── constants.ts                  # Hằng số toàn cục
│   ├── types/                        # TypeScript types
│   │   ├── api.types.ts              # ApiResponse<T>, ApiError, PaginatedResponse
│   │   ├── user.types.ts             # User, Role, AuthState
│   │   ├── story.types.ts            # Story, StoryStatus, Chapter
│   │   └── interaction.types.ts      # Like, Bookmark, Comment
│   └── validations/                  # Zod schemas
│       ├── auth.schema.ts            # loginSchema, registerSchema
│       ├── story.schema.ts           # createStorySchema, updateStorySchema
│       └── chapter.schema.ts         # createChapterSchema
│
├── i18n/                             # next-intl config
│   ├── request.ts
│   └── routing.ts
│
├── messages/                         # Bản dịch
│   ├── vi.json
│   └── en.json
│
└── middleware.ts                     # next-intl middleware
```

---

## 2. Backend (NestJS)

```
src/
├── main.ts                           # Entry point
├── app.module.ts                     # Root module
│
├── shared/                           # 🔄 DÙNG CHUNG: Code dùng lại giữa các module
│   ├── decorators/                   # Custom decorators
│   │   ├── roles.decorator.ts        # @Roles('AUTHOR', 'ADMIN')
│   │   └── current-user.decorator.ts # @CurrentUser()
│   ├── guards/                       # Auth & Role guards
│   │   ├── jwt-auth.guard.ts
│   │   └── roles.guard.ts
│   ├── filters/                      # Exception filters
│   │   └── http-exception.filter.ts
│   ├── interceptors/                 # Response transformation
│   │   ├── transform.interceptor.ts
│   │   └── logging.interceptor.ts
│   ├── middleware/                    # Express middleware
│   │   └── rate-limit.middleware.ts
│   ├── dto/                          # Shared DTOs
│   │   └── pagination.dto.ts
│   ├── services/                     # Shared services
│   │   ├── email.service.ts
│   │   ├── storage.service.ts
│   │   └── cache.service.ts
│   └── utils/                        # Utility functions
│       ├── slug.util.ts
│       └── hash.util.ts
│
├── modules/                          # 📦 Feature modules
│   ├── auth/
│   │   ├── auth.module.ts
│   │   ├── auth.controller.ts
│   │   ├── auth.service.ts
│   │   ├── dto/
│   │   │   ├── login.dto.ts
│   │   │   ├── register.dto.ts
│   │   │   └── token-response.dto.ts
│   │   └── strategies/
│   │       ├── jwt.strategy.ts
│   │       └── google.strategy.ts
│   ├── user/
│   │   ├── user.module.ts
│   │   ├── user.controller.ts
│   │   ├── user.service.ts
│   │   └── dto/
│   ├── story/
│   │   ├── story.module.ts
│   │   ├── story.controller.ts
│   │   ├── story.service.ts
│   │   └── dto/
│   ├── chapter/
│   │   ├── chapter.module.ts
│   │   ├── chapter.controller.ts
│   │   ├── chapter.service.ts
│   │   └── dto/
│   ├── interaction/                  # Like, Comment, Bookmark, Follow
│   │   ├── interaction.module.ts
│   │   ├── like.controller.ts
│   │   ├── comment.controller.ts
│   │   ├── bookmark.controller.ts
│   │   ├── follow.controller.ts
│   │   ├── interaction.service.ts
│   │   └── dto/
│   ├── notification/
│   │   ├── notification.module.ts
│   │   ├── notification.controller.ts
│   │   └── notification.service.ts
│   ├── upload/
│   │   ├── upload.module.ts
│   │   ├── upload.controller.ts
│   │   └── upload.service.ts
│   └── admin/
│       ├── admin.module.ts
│       ├── admin.controller.ts
│       └── admin.service.ts
│
├── prisma/                           # Database
│   ├── schema.prisma
│   ├── seed.ts
│   └── migrations/
│
└── config/                           # Environment config
    ├── app.config.ts
    ├── auth.config.ts
    └── database.config.ts
```

---

## 3. Quy Tắc Phân Bổ Code

### Khi nào đặt ở đâu?

```
Câu hỏi: Component/hook/util này dùng ở bao nhiêu nơi?

┌─────────────────────┐
│ Dùng ở 1 feature?   │──── YES ──▶ Đặt trong features/{feature}/
└─────────┬───────────┘
          │ NO
          ▼
┌─────────────────────┐
│ Dùng ở 2+ features? │──── YES ──▶ Đặt ở shared folder (ui/, hooks/, lib/)
└─────────┬───────────┘            + Thêm vào REUSABLE-COMPONENTS.md
          │ NO
          ▼
    Chưa cần tạo!
```

### Quy tắc di chuyển

1. **Component mới** → Đặt trong `features/` trước
2. **Khi feature thứ 2 cần dùng** → Di chuyển ra `components/ui/` hoặc `hooks/`
3. **Sau khi di chuyển** → Cập nhật `REUSABLE-COMPONENTS.md`
4. **Utility functions** → Luôn đặt trong `lib/utils.ts` hoặc `lib/` folder

### Quy tắc đặt tên file

| Loại         | Convention                        | Ví dụ              |
| ------------ | --------------------------------- | ------------------ |
| Component    | kebab-case                        | `story-card.tsx`   |
| Hook         | camelCase với prefix `use`        | `use-auth.ts`      |
| Store        | kebab-case với suffix `.store`    | `auth.store.ts`    |
| Service      | kebab-case với suffix `.service`  | `story.service.ts` |
| Type         | kebab-case với suffix `.types`    | `story.types.ts`   |
| Schema (Zod) | kebab-case với suffix `.schema`   | `auth.schema.ts`   |
| Constant     | kebab-case                        | `constants.ts`     |
| Page         | `page.tsx` (Next.js convention)   | `page.tsx`         |
| Layout       | `layout.tsx` (Next.js convention) | `layout.tsx`       |

---

## 4. Dependencies Cần Cài Đặt

### Đã cài (trong `package.json`):

- next, react, react-dom, framer-motion, lucide-react
- class-variance-authority, clsx, tailwind-merge
- next-intl, next-themes, sonner, radix-ui

### Cần cài thêm (chạy trong WSL):

```bash
# State & Data
pnpm add zustand @tanstack/react-query

# Forms & Validation
pnpm add react-hook-form zod @hookform/resolvers

# HTTP Client (nếu dùng axios)
# pnpm add axios  # hoặc dùng native fetch wrapper
```

---

> **Tài liệu liên quan**: [ARCHITECTURE.md](./ARCHITECTURE.md) · [REUSABLE-COMPONENTS.md](./REUSABLE-COMPONENTS.md) · [CODING-STANDARDS.md](./CODING-STANDARDS.md)
