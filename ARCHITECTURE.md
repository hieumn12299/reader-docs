# 📐 Kiến Trúc Tổng Thể — Story Platform

> **Mục tiêu**: Xây dựng nền tảng đọc/viết truyện (tương tự Wattpad), kiến trúc đủ tốt để mở rộng từ side project → sản phẩm thực tế.

> **Cập nhật lần cuối**: 2026-03-01

---

## 1. Mô Tả Sản Phẩm

Nền tảng web cho phép người dùng:

- **Đọc truyện**: Theo chương, animation chuyển trang, lưu vị trí đọc
- **Viết truyện**: Rich text editor (Tiptap), upload ảnh, quản lý chương
- **Tương tác**: Like, comment, follow, bookmark
- **Khám phá**: Search, filter, trending, recommendations

### Target Users

| Nhóm                | Đặc điểm                                |
| ------------------- | --------------------------------------- |
| Học sinh, sinh viên | Đọc truyện giải trí, chủ yếu mobile web |
| Tác giả nghiệp dư   | Cần editor dễ dùng                      |
| Tác giả bán chuyên  | Quản lý nhiều truyện, theo dõi stats    |

### Mục Tiêu Scale

```
Side Project → Medium Scale → Ready to Scale
   (<1K)         (1K-10K)        (10K-100K)
```

---

## 2. Tech Stack (Chính Thức)

### Frontend

| Thành phần    | Công nghệ                                   | Phiên bản     |
| ------------- | ------------------------------------------- | ------------- |
| Framework     | Next.js (App Router)                        | 16.1.6        |
| Language      | TypeScript                                  | 5+            |
| UI Library    | React + Radix UI (shadcn/ui pattern)        | React 19.2.3  |
| Styling       | TailwindCSS + tailwind-merge + clsx + CVA   | TailwindCSS 4 |
| Animation     | Framer Motion                               | 12+           |
| Icons         | Lucide React                                | latest        |
| Server State  | @tanstack/react-query                       | latest        |
| Client State  | Zustand                                     | latest        |
| Forms         | react-hook-form + zod + @hookform/resolvers | latest        |
| Notifications | sonner                                      | latest        |
| i18n          | next-intl                                   | 3.x           |
| Theming       | next-themes                                 | 0.4.x         |

### Backend

| Thành phần | Công nghệ                           | Ghi chú                                |
| ---------- | ----------------------------------- | -------------------------------------- |
| Framework  | NestJS                              | Modular architecture, TypeScript-first |
| Language   | TypeScript 5+                       | Strict mode, no `any`                  |
| ORM        | Prisma                              | Type-safe, auto migrations             |
| Database   | MySQL                               | PlanetScale serverless                 |
| Cache      | Redis (Upstash)                     | Rate limiting, caching                 |
| Auth       | @nestjs/passport + @nestjs/jwt      | JWT strategy                           |
| Validation | class-validator + class-transformer | DTOs                                   |
| API Docs   | @nestjs/swagger                     | Auto-generated                         |
| Email      | Resend                              | Transactional emails                   |
| Storage    | Cloudinary                          | Images + CDN                           |

### DevOps & Tools

| Thành phần      | Công nghệ                 |
| --------------- | ------------------------- |
| FE Deploy       | Vercel                    |
| BE Deploy       | Railway (Docker)          |
| DB Hosting      | PlanetScale               |
| CI/CD           | GitHub Actions            |
| Monitoring      | Sentry + Vercel Analytics |
| Package Manager | pnpm                      |
| Linter          | ESLint (flat config)      |
| Formatter       | Prettier                  |

---

## 3. Kiến Trúc Tổng Quát

```
┌──────────────────────────────────────────────────────────┐
│                      FRONTEND                             │
│  Next.js 16 (App Router) + TailwindCSS 4 + Tiptap       │
│  Deploy: Vercel                                           │
└────────────────────────┬─────────────────────────────────┘
                         │ HTTPS (REST API)
                         ▼
┌──────────────────────────────────────────────────────────┐
│                      BACKEND                              │
│  NestJS + Prisma ORM + JWT Auth                          │
│  Deploy: Railway (Docker)                                 │
├──────────────────────────────────────────────────────────┤
│  ┌────────┐ ┌────────┐ ┌────────┐ ┌──────────────────┐  │
│  │  Auth  │ │ Story  │ │  User  │ │   Interaction    │  │
│  │ Module │ │ Module │ │ Module │ │     Module       │  │
│  └────────┘ └────────┘ └────────┘ └──────────────────┘  │
└────────────────────────┬─────────────────────────────────┘
                         │
       ┌─────────────────┼─────────────────┐
       ▼                 ▼                 ▼
┌────────────┐   ┌────────────┐   ┌──────────────────┐
│   MySQL    │   │   Redis    │   │  Cloud Storage   │
│ PlanetScale│   │  Upstash   │   │   Cloudinary     │
└────────────┘   └────────────┘   └──────────────────┘
```

---

## 4. Authentication Flow

```
EMAIL/PASSWORD:
┌────────┐    ┌────────┐    ┌────────┐    ┌────────┐
│Register│───▶│ Verify │───▶│ Login  │───▶│  JWT   │
│  Form  │    │ Email  │    │  Form  │    │ Token  │
└────────┘    └────────┘    └────────┘    └────────┘

GOOGLE OAUTH:
┌────────┐    ┌────────┐    ┌────────┐    ┌────────┐
│ Google │───▶│Callback│───▶│ Link/  │───▶│  JWT   │
│ Button │    │ Handle │    │Create  │    │ Token  │
└────────┘    └────────┘    └────────┘    └────────┘

JWT STRATEGY:
• Access Token : 15 phút, lưu trong memory (Zustand store)
• Refresh Token: 7 ngày, lưu trong httpOnly cookie
• Refresh rotation mỗi lần sử dụng
```

---

## 5. API Response Standard

Tất cả API trả về theo cấu trúc chuẩn:

```typescript
interface ApiResponse<T> {
  statusCode: number;
  message: string;
  data: T;
  meta?: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
  };
}
```

### Error Response

```typescript
interface ApiError {
  statusCode: number;
  message: string;
  error: string;
  details?: Record<string, string[]>;
}
```

---

## 6. Database Schema (MySQL + Prisma)

### Models chính

```prisma
enum Role {
  READER
  AUTHOR
  ADMIN
}

model User {
  id            String    @id @default(cuid())
  email         String    @unique
  passwordHash  String?
  displayName   String
  avatarUrl     String?
  role          Role      @default(READER)
  emailVerified Boolean   @default(false)
  createdAt     DateTime  @default(now())
  updatedAt     DateTime  @updatedAt

  oauthAccounts   OAuthAccount[]
  stories         Story[]
  chapters        Chapter[]
  comments        Comment[]
  likes           Like[]
  bookmarks       Bookmark[]
  follows         Follow[]          @relation("follower")
  followers       Follow[]          @relation("following")
  readingProgress ReadingProgress[]

  @@index([email])
}

enum StoryStatus {
  DRAFT
  PUBLISHED
  COMPLETED
  HIATUS
  HIDDEN
}

model Story {
  id          String      @id @default(cuid())
  title       String
  slug        String      @unique
  description String      @db.Text
  coverImage  String?
  status      StoryStatus @default(DRAFT)
  mature      Boolean     @default(false)
  viewCount   Int         @default(0)
  authorId    String
  createdAt   DateTime    @default(now())
  updatedAt   DateTime    @updatedAt
  publishedAt DateTime?

  author    User        @relation(fields: [authorId], references: [id])
  chapters  Chapter[]
  genres    StoryGenre[]
  tags      StoryTag[]
  likes     Like[]
  bookmarks Bookmark[]
  comments  Comment[]

  @@index([authorId])
  @@index([status, publishedAt])
}

enum ChapterStatus {
  DRAFT
  PUBLISHED
  SCHEDULED
}

model Chapter {
  id          String        @id @default(cuid())
  title       String
  content     String        @db.LongText
  orderIndex  Int
  wordCount   Int           @default(0)
  status      ChapterStatus @default(DRAFT)
  storyId     String
  authorId    String
  createdAt   DateTime      @default(now())
  updatedAt   DateTime      @updatedAt
  publishedAt DateTime?

  story           Story             @relation(fields: [storyId], references: [id], onDelete: Cascade)
  author          User              @relation(fields: [authorId], references: [id])
  versions        ChapterVersion[]
  readingProgress ReadingProgress[]
  comments        Comment[]

  @@unique([storyId, orderIndex])
  @@index([storyId, status])
}
```

### Models phụ trợ

```prisma
model OAuthAccount {
  id         String @id @default(cuid())
  provider   String
  providerId String
  userId     String
  user       User   @relation(fields: [userId], references: [id], onDelete: Cascade)

  @@unique([provider, providerId])
  @@index([userId])
}

model ChapterVersion {
  id        String   @id @default(cuid())
  content   String   @db.LongText
  chapterId String
  createdAt DateTime @default(now())
  chapter   Chapter  @relation(fields: [chapterId], references: [id], onDelete: Cascade)

  @@index([chapterId])
}

model Genre {
  id      String       @id @default(cuid())
  name    String       @unique
  slug    String       @unique
  stories StoryGenre[]
}

model Tag {
  id      String     @id @default(cuid())
  name    String     @unique
  stories StoryTag[]
}

model StoryGenre {
  storyId String
  genreId String
  story   Story @relation(fields: [storyId], references: [id], onDelete: Cascade)
  genre   Genre @relation(fields: [genreId], references: [id], onDelete: Cascade)
  @@id([storyId, genreId])
}

model StoryTag {
  storyId String
  tagId   String
  story   Story @relation(fields: [storyId], references: [id], onDelete: Cascade)
  tag     Tag   @relation(fields: [tagId], references: [id], onDelete: Cascade)
  @@id([storyId, tagId])
}

model Like {
  id        String   @id @default(cuid())
  userId    String
  storyId   String
  createdAt DateTime @default(now())
  user      User     @relation(fields: [userId], references: [id], onDelete: Cascade)
  story     Story    @relation(fields: [storyId], references: [id], onDelete: Cascade)
  @@unique([userId, storyId])
}

model Bookmark {
  id        String   @id @default(cuid())
  userId    String
  storyId   String
  createdAt DateTime @default(now())
  user      User     @relation(fields: [userId], references: [id], onDelete: Cascade)
  story     Story    @relation(fields: [storyId], references: [id], onDelete: Cascade)
  @@unique([userId, storyId])
}

model Follow {
  id          String   @id @default(cuid())
  followerId  String
  followingId String
  createdAt   DateTime @default(now())
  follower    User @relation("follower", fields: [followerId], references: [id], onDelete: Cascade)
  following   User @relation("following", fields: [followingId], references: [id], onDelete: Cascade)
  @@unique([followerId, followingId])
}

model Comment {
  id        String   @id @default(cuid())
  content   String   @db.Text
  userId    String
  storyId   String?
  chapterId String?
  parentId  String?
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
  user      User     @relation(fields: [userId], references: [id], onDelete: Cascade)
  story     Story?   @relation(fields: [storyId], references: [id], onDelete: Cascade)
  chapter   Chapter? @relation(fields: [chapterId], references: [id], onDelete: Cascade)
  parent    Comment? @relation("replies", fields: [parentId], references: [id])
  replies   Comment[] @relation("replies")
  @@index([storyId])
  @@index([chapterId])
}

model ReadingProgress {
  id             String   @id @default(cuid())
  userId         String
  chapterId      String
  scrollPosition Float    @default(0)
  updatedAt      DateTime @updatedAt
  user           User     @relation(fields: [userId], references: [id], onDelete: Cascade)
  chapter        Chapter  @relation(fields: [chapterId], references: [id], onDelete: Cascade)
  @@unique([userId, chapterId])
}

model Report {
  id         String       @id @default(cuid())
  type       ReportType
  targetId   String
  reason     String       @db.Text
  reporterId String
  status     ReportStatus @default(PENDING)
  createdAt  DateTime     @default(now())
  resolvedAt DateTime?
  resolvedBy String?
  @@index([status])
  @@index([targetId])
}

enum ReportType { STORY CHAPTER COMMENT USER }
enum ReportStatus { PENDING REVIEWED RESOLVED DISMISSED }
```

---

## 7. Image Upload Flow

```
1. Client yêu cầu presigned URL
   POST /api/upload/presign
   { type: "cover" | "chapter-image", fileType: "jpeg" }

2. Backend validate & trả presigned URL
   { uploadUrl, publicUrl, expiresAt }

3. Client upload trực tiếp lên Cloudinary
   PUT {uploadUrl} with file body

4. Client lưu publicUrl vào database
   POST /api/story/{id} { coverImage: publicUrl }
```

**Provider**: Cloudinary (free tier: 25GB storage/month, auto-optimize WebP, built-in CDN)

---

## 8. Kế Hoạch Phát Triển

### Phase 1: MVP (8-12 tuần)

| Tuần  | Nội dung                                                      |
| ----- | ------------------------------------------------------------- |
| 1-2   | Setup & Auth (register, login, email verify, Google OAuth)    |
| 3-4   | Story CRUD, Chapter CRUD, Tiptap editor, Image upload         |
| 5-6   | Story listing, detail, chapter reading, dark mode, responsive |
| 7-8   | Search, genre/tag filter, sorting, user profile               |
| 9-10  | UI/UX polish, error handling, loading states, SEO             |
| 11-12 | Testing, bug fixes, production deploy                         |

### Phase 2: Engagement (6-8 tuần)

- Like, bookmark, follow, reading progress sync
- Comments (nested), notifications
- Author dashboard & stats
- Admin panel

### Phase 3: Growth (8-12 tuần)

- Trending, recommendations, reading lists
- PWA offline reading, i18n, social sharing
- Redis caching, DB optimization, load testing

---

## 9. Security

| Lĩnh vực         | Giải pháp                                             | Priority |
| ---------------- | ----------------------------------------------------- | -------- |
| Password hashing | bcrypt (salt rounds 12)                               | P0       |
| JWT              | Short-lived access, httpOnly refresh                  | P0       |
| OAuth CSRF       | State parameter                                       | P0       |
| API validation   | Zod (FE) + class-validator (BE)                       | P0       |
| XSS prevention   | DOMPurify cho Tiptap content                          | P0       |
| SQL injection    | Prisma (parameterized queries)                        | P0       |
| Rate limiting    | Auth: 5 req/min, API: 100 req/min, Upload: 10 req/min | P0       |
| CORS             | Whitelist frontend domain                             | P0       |
| HTTPS            | Enforced everywhere                                   | P0       |
| File uploads     | Type + size validation (jpg, png, webp, max 5MB)      | P0       |

---

## 10. Scalability

| Metric           | Phase 1 | Phase 2 | Phase 3 |
| ---------------- | ------- | ------- | ------- |
| Concurrent Users | 100     | 1,000   | 10,000  |
| Stories          | 1,000   | 10,000  | 100,000 |
| Monthly Reads    | 100K    | 1M      | 10M     |

---

## 11. Deploy

```
┌──────────────────────────────────────────────┐
│              PRODUCTION STACK                 │
├──────────────────────────────────────────────┤
│  Frontend:  Vercel (free → pro)              │
│  Backend:   Railway (Docker)                 │
│  Database:  PlanetScale (MySQL serverless)   │
│  Cache:     Upstash Redis                    │
│  Storage:   Cloudinary                       │
│  Email:     Resend                           │
│  Monitor:   Sentry + Vercel Analytics        │
├──────────────────────────────────────────────┤
│  Chi phí ước tính:                           │
│  MVP:       $0-10/tháng (free tiers)         │
│  1K users:  $20-40/tháng                     │
│  10K users: $50-100/tháng                    │
└──────────────────────────────────────────────┘
```

---

> **Tài liệu liên quan**: [FOLDER-STRUCTURE.md](./FOLDER-STRUCTURE.md) · [CODING-STANDARDS.md](./CODING-STANDARDS.md) · [WORKFLOW-GUIDE.md](./WORKFLOW-GUIDE.md)
