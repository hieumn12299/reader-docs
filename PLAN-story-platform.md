# 📚 Story Platform - Kiến Trúc & Product Plan

> **Mục tiêu**: Xây dựng nền tảng đọc/viết truyện tương tự Wattpad, side project nhưng có kiến trúc đủ tốt để mở rộng khi user tăng.

---

## 1. Overview

### 1.1 Mô Tả App

Một nền tảng web cho phép người dùng:

- **Đọc truyện**: Theo chương, có animation, lưu vị trí đọc
- **Viết truyện**: Rich text editor (Tiptap), upload ảnh, quản lý chương
- **Tương tác**: Like, comment, follow, bookmark
- **Khám phá**: Search, filter, trending, recommendations

### 1.2 Target Users

| Nhóm                | Đặc điểm                                 |
| ------------------- | ---------------------------------------- |
| Học sinh, sinh viên | Đọc truyện giải trí, chủ yếu mobile web  |
| Tác giả nghiệp dư   | Viết truyện đầu tiên, cần editor dễ dùng |
| Tác giả bán chuyên  | Cần quản lý nhiều truyện, theo dõi stats |

### 1.3 Mục Tiêu Kiến Trúc

```
Side Project → Medium Scale → Ready to Scale
   (<1K)         (1K-10K)        (10K-100K)
```

---

## 2. What Is Missing? (Gap Analysis)

> ⚠️ **Phân tích những gì ĐÃ CÓ vs CẦN BỔ SUNG**

### 2.1 Đã Có (Từ Requirements)

| Layer    | Đã chọn                                 |
| -------- | --------------------------------------- |
| Frontend | Next.js App Router, TailwindCSS, Tiptap, lucide-react, motion |
| Backend  | Node.js REST                            |
| Database | MySQL                                   |
| Auth     | Email/Password, Google OAuth            |
| Storage  | Presigned URL (cloud storage)           |
| Deploy   | Vercel (FE), Docker (BE)                |

### 2.2 Còn Thiếu - BẮT BUỘC

| #   | Component             | Tại sao cần                               | Đề xuất                                           |
| --- | --------------------- | ----------------------------------------- | ------------------------------------------------- |
| 1   | **ORM/Query Builder** | Không có → viết raw SQL, dễ SQL injection | **Prisma** (type-safe, migrations, MySQL support) |
| 2   | **Rate Limiting**     | Không có → API bị abuse, DDoS             | **Upstash Redis** + express-rate-limit            |
| 3   | **Input Validation**  | Rich text editor → XSS risk cao           | **Zod** (FE+BE) + DOMPurify (sanitize HTML)       |
| 4   | **Error Handling**    | Side project hay bỏ qua → hard to debug   | Centralized error handler + structured logging    |
| 5   | **Email Service**     | Email verification, password reset        | **Resend** hoặc **Nodemailer + Gmail SMTP**       |
| 6   | **Cloud Storage**     | Presigned URL cần provider cụ thể         | **Cloudinary** (free tier tốt) hoặc **AWS S3**    |
| 7   | **CDN**               | Images từ cloud storage cần CDN           | **Cloudinary CDN** hoặc **CloudFront**            |
| 8   | **Queue System**      | Email gửi async, không block API          | **BullMQ** + Redis (optional Phase 2)             |

### 2.3 Còn Thiếu - NÊN CÓ (Wattpad Parity)

| #   | Feature                   | Mô tả                                        |
| --- | ------------------------- | -------------------------------------------- |
| 1   | **Reading List**          | User tạo nhiều thư viện custom               |
| 2   | **Notification System**   | Khi có chương mới, được follow, được comment |
| 3   | **Reading Progress Sync** | Đồng bộ vị trí đọc across devices            |
| 4   | **Mature Content Filter** | 18+ content toggle                           |
| 5   | **Story Stats Dashboard** | Views, reads, engagement cho tác giả         |
| 6   | **Offline Reading**       | PWA + service worker cache                   |
| 7   | **Social Sharing**        | Share truyện lên Facebook, Twitter           |
| 8   | **Report System**         | Báo cáo nội dung vi phạm                     |
| 9   | **Tag/Genre System**      | Taxonomy rõ ràng, nhiều genre per story      |
| 10  | **Recommendation Engine** | "Bạn có thể thích" based on reading history  |

---

## 3. Suggested Full Architecture

### 3.1 High-Level Architecture

```
┌────────────────────────────────────────────────────────────────┐
│                         FRONTEND                               │
│  Next.js 14 (App Router) + TailwindCSS + Tiptap               │
│  Vercel Deployment                                             │
└─────────────────────────────┬──────────────────────────────────┘
                              │ HTTPS
                              ▼
┌────────────────────────────────────────────────────────────────┐
│                         BACKEND                                │
│  Node.js + Express/Fastify + Prisma ORM                        │
│  Docker Container (Railway/Render/VPS)                         │
├────────────────────────────────────────────────────────────────┤
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────────────┐  │
│  │   Auth   │ │  Story   │ │  User    │ │   Interaction    │  │
│  │  Module  │ │  Module  │ │  Module  │ │     Module       │  │
│  └──────────┘ └──────────┘ └──────────┘ └──────────────────┘  │
└─────────────────────────────┬──────────────────────────────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        ▼                     ▼                     ▼
┌──────────────┐    ┌──────────────┐    ┌──────────────────────┐
│    MySQL     │    │    Redis     │    │   Cloud Storage      │
│  (Primary)   │    │   (Cache)    │    │  (Cloudinary/S3)     │
│  PlanetScale │    │   Upstash    │    │                      │
└──────────────┘    └──────────────┘    └──────────────────────┘
```

### 3.2 Frontend Architecture

```
src/
├── app/                    # Next.js App Router
│   ├── (auth)/            # Auth routes group
│   │   ├── login/
│   │   ├── register/
│   │   └── forgot-password/
│   ├── (reader)/          # Reading experience
│   │   ├── story/[id]/
│   │   └── chapter/[id]/
│   ├── (writer)/          # Writing experience
│   │   ├── dashboard/
│   │   ├── story/[id]/edit/
│   │   └── chapter/[id]/edit/
│   ├── (discover)/        # Discovery
│   │   ├── search/
│   │   ├── trending/
│   │   └── genre/[slug]/
│   └── (admin)/           # Admin panel
├── components/
│   ├── ui/                # Design system components
│   ├── reader/            # Reading components
│   ├── editor/            # Tiptap editor wrapper
│   └── layouts/           # Layout components
├── lib/
│   ├── api/               # API client
│   ├── hooks/             # Custom hooks
│   └── utils/             # Utilities
└── styles/                # Global styles
```

**Key Decisions:**

- **Route Groups** `(auth)`, `(reader)`: Tổ chức code theo feature
- **Server Components by default**: Chỉ client component khi cần interactivity
- **Tiptap Config**: Custom extensions cho story formatting

### 3.3 Backend Architecture

```
src/
├── modules/
│   ├── auth/
│   │   ├── auth.controller.ts
│   │   ├── auth.service.ts
│   │   ├── auth.middleware.ts
│   │   └── strategies/
│   │       ├── local.strategy.ts
│   │       └── google.strategy.ts
│   ├── user/
│   ├── story/
│   ├── chapter/
│   ├── interaction/       # Like, Comment, Bookmark
│   ├── notification/
│   └── admin/
├── shared/
│   ├── middleware/
│   │   ├── rate-limit.ts
│   │   ├── error-handler.ts
│   │   └── validate.ts
│   ├── services/
│   │   ├── email.service.ts
│   │   ├── storage.service.ts
│   │   └── cache.service.ts
│   └── utils/
├── prisma/
│   ├── schema.prisma
│   └── migrations/
└── config/
    └── index.ts
```

**Key Decisions:**

- **Modular Monolith**: Tách module rõ ràng, dễ extract microservice sau
- **Service Layer**: Business logic tách khỏi controller
- **Prisma**: Type-safe, auto migrations, MySQL support tốt

### 3.4 Database Schema (MySQL + Prisma)

```prisma
// User & Auth
model User {
  id            String    @id @default(cuid())
  email         String    @unique
  passwordHash  String?
  displayName   String
  avatarUrl     String?
  role          Role      @default(USER)
  emailVerified Boolean   @default(false)
  createdAt     DateTime  @default(now())
  updatedAt     DateTime  @updatedAt

  // Relations
  oauthAccounts OAuthAccount[]
  stories       Story[]
  chapters      Chapter[]
  comments      Comment[]
  likes         Like[]
  bookmarks     Bookmark[]
  follows       Follow[]     @relation("follower")
  followers     Follow[]     @relation("following")
  readingProgress ReadingProgress[]

  @@index([email])
}

enum Role {
  USER
  AUTHOR
  ADMIN
}

model OAuthAccount {
  id          String   @id @default(cuid())
  provider    String   // "google"
  providerId  String
  userId      String
  user        User     @relation(fields: [userId], references: [id], onDelete: Cascade)

  @@unique([provider, providerId])
  @@index([userId])
}

// Story System
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

  // Relations
  author      User        @relation(fields: [authorId], references: [id])
  chapters    Chapter[]
  genres      StoryGenre[]
  tags        StoryTag[]
  likes       Like[]
  bookmarks   Bookmark[]
  comments    Comment[]

  @@index([authorId])
  @@index([status, publishedAt])
  @@index([slug])
}

enum StoryStatus {
  DRAFT
  PUBLISHED
  COMPLETED
  HIATUS
  HIDDEN    // For moderation
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

  // Relations
  story       Story         @relation(fields: [storyId], references: [id], onDelete: Cascade)
  author      User          @relation(fields: [authorId], references: [id])
  versions    ChapterVersion[]
  readingProgress ReadingProgress[]
  comments    Comment[]

  @@unique([storyId, orderIndex])
  @@index([storyId, status])
}

enum ChapterStatus {
  DRAFT
  PUBLISHED
  SCHEDULED
}

model ChapterVersion {
  id        String   @id @default(cuid())
  content   String   @db.LongText
  chapterId String
  createdAt DateTime @default(now())

  chapter   Chapter  @relation(fields: [chapterId], references: [id], onDelete: Cascade)

  @@index([chapterId])
}

// Taxonomy
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
  story   Story  @relation(fields: [storyId], references: [id], onDelete: Cascade)
  genre   Genre  @relation(fields: [genreId], references: [id], onDelete: Cascade)

  @@id([storyId, genreId])
}

model StoryTag {
  storyId String
  tagId   String
  story   Story @relation(fields: [storyId], references: [id], onDelete: Cascade)
  tag     Tag   @relation(fields: [tagId], references: [id], onDelete: Cascade)

  @@id([storyId, tagId])
}

// Interaction
model Like {
  id        String   @id @default(cuid())
  userId    String
  storyId   String
  createdAt DateTime @default(now())

  user  User  @relation(fields: [userId], references: [id], onDelete: Cascade)
  story Story @relation(fields: [storyId], references: [id], onDelete: Cascade)

  @@unique([userId, storyId])
}

model Bookmark {
  id        String   @id @default(cuid())
  userId    String
  storyId   String
  createdAt DateTime @default(now())

  user  User  @relation(fields: [userId], references: [id], onDelete: Cascade)
  story Story @relation(fields: [storyId], references: [id], onDelete: Cascade)

  @@unique([userId, storyId])
}

model Follow {
  id          String   @id @default(cuid())
  followerId  String
  followingId String
  createdAt   DateTime @default(now())

  follower  User @relation("follower", fields: [followerId], references: [id], onDelete: Cascade)
  following User @relation("following", fields: [followingId], references: [id], onDelete: Cascade)

  @@unique([followerId, followingId])
}

model Comment {
  id        String   @id @default(cuid())
  content   String   @db.Text
  userId    String
  storyId   String?
  chapterId String?
  parentId  String?  // For nested comments
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt

  user     User      @relation(fields: [userId], references: [id], onDelete: Cascade)
  story    Story?    @relation(fields: [storyId], references: [id], onDelete: Cascade)
  chapter  Chapter?  @relation(fields: [chapterId], references: [id], onDelete: Cascade)
  parent   Comment?  @relation("replies", fields: [parentId], references: [id])
  replies  Comment[] @relation("replies")

  @@index([storyId])
  @@index([chapterId])
}

model ReadingProgress {
  id          String   @id @default(cuid())
  userId      String
  chapterId   String
  scrollPosition Float  @default(0) // Percentage 0-100
  updatedAt   DateTime @updatedAt

  user    User    @relation(fields: [userId], references: [id], onDelete: Cascade)
  chapter Chapter @relation(fields: [chapterId], references: [id], onDelete: Cascade)

  @@unique([userId, chapterId])
}

// Admin & Moderation
model Report {
  id          String       @id @default(cuid())
  type        ReportType
  targetId    String       // storyId or userId or commentId
  reason      String       @db.Text
  reporterId  String
  status      ReportStatus @default(PENDING)
  createdAt   DateTime     @default(now())
  resolvedAt  DateTime?
  resolvedBy  String?

  @@index([status])
  @@index([targetId])
}

enum ReportType {
  STORY
  CHAPTER
  COMMENT
  USER
}

enum ReportStatus {
  PENDING
  REVIEWED
  RESOLVED
  DISMISSED
}
```

### 3.5 Authentication Flow

```
┌─────────────────────────────────────────────────────────────┐
│                    AUTH FLOWS                                │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  EMAIL/PASSWORD:                                            │
│  ┌────────┐    ┌────────┐    ┌────────┐    ┌────────┐      │
│  │Register│───▶│Verify  │───▶│ Login  │───▶│ JWT    │      │
│  │  Form  │    │ Email  │    │  Form  │    │ Token  │      │
│  └────────┘    └────────┘    └────────┘    └────────┘      │
│                                                             │
│  GOOGLE OAUTH:                                              │
│  ┌────────┐    ┌────────┐    ┌────────┐    ┌────────┐      │
│  │ Google │───▶│Callback│───▶│Link/   │───▶│ JWT    │      │
│  │ Button │    │ Handle │    │Create  │    │ Token  │      │
│  └────────┘    └────────┘    └────────┘    └────────┘      │
│                                                             │
│  JWT STRATEGY:                                              │
│  • Access Token: 15 minutes, stored in memory               │
│  • Refresh Token: 7 days, stored in httpOnly cookie         │
│  • Refresh rotation on each use                             │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 3.6 Storage Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    IMAGE UPLOAD FLOW                         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. Client requests presigned URL                           │
│     POST /api/upload/presign                                │
│     { type: "cover" | "chapter-image", fileType: "jpeg" }   │
│                                                             │
│  2. Backend validates & returns presigned URL               │
│     { uploadUrl, publicUrl, expiresAt }                     │
│                                                             │
│  3. Client uploads directly to cloud storage                │
│     PUT {uploadUrl} with file body                          │
│                                                             │
│  4. Client saves publicUrl to database                      │
│     POST /api/story/{id} { coverImage: publicUrl }          │
│                                                             │
├─────────────────────────────────────────────────────────────┤
│  RECOMMENDED: Cloudinary (free tier: 25GB storage/month)    │
│  • Auto-optimization (WebP, resize)                         │
│  • Built-in CDN                                             │
│  • Easy transformations                                     │
│  • Generous free tier for side project                      │
├─────────────────────────────────────────────────────────────┤
│  ALTERNATIVE: AWS S3 + CloudFront                           │
│  • More control                                             │
│  • Pay-as-you-go (có thể đắt hơn ban đầu)                  │
│  • Better for scale                                         │
└─────────────────────────────────────────────────────────────┘
```

---

## 4. Feature Expansion (Wattpad Parity)

### 4.1 Core Features (Phase 1 - MVP)

| Feature                   | Priority | Complexity | Notes                        |
| ------------------------- | -------- | ---------- | ---------------------------- |
| User Registration (Email) | P0       | Medium     | Email verification required  |
| Google OAuth              | P0       | Medium     | Passport.js strategy         |
| Story CRUD                | P0       | High       | Draft/Publish flow           |
| Chapter CRUD              | P0       | High       | Rich text + images           |
| Tiptap Editor             | P0       | High       | Custom extensions needed     |
| Basic Search              | P0       | Low        | MySQL LIKE + FULLTEXT        |
| Genre/Tag Filter          | P0       | Low        | Many-to-many relations       |
| Dark/Light Mode           | P0       | Low        | CSS variables + localStorage |
| Responsive Design         | P0       | Medium     | Mobile-first                 |

### 4.2 Engagement Features (Phase 2)

| Feature          | Priority | Complexity | Notes                       |
| ---------------- | -------- | ---------- | --------------------------- |
| Like Story       | P1       | Low        | Toggle, show count          |
| Bookmark/Library | P1       | Medium     | Personal collections        |
| Follow Author    | P1       | Low        | Follower/Following          |
| Comments         | P1       | Medium     | Per chapter, nested replies |
| Reading Progress | P1       | Medium     | Save scroll position        |
| View Count       | P1       | Low        | Increment on chapter load   |
| Author Dashboard | P1       | Medium     | Stats, story management     |

### 4.3 Discovery Features (Phase 2-3)

| Feature                | Priority | Complexity | Notes                                      |
| ---------------------- | -------- | ---------- | ------------------------------------------ |
| Trending Stories       | P2       | Medium     | Based on recent likes/views                |
| New Releases           | P2       | Low        | Sort by publishedAt                        |
| Recommended            | P3       | High       | Collaborative filtering hoặc content-based |
| Reading Lists (Public) | P2       | Medium     | User-created lists                         |
| Search Suggestions     | P2       | Medium     | Autocomplete                               |

### 4.4 Admin Features (Phase 2)

| Feature             | Priority | Complexity | Notes                   |
| ------------------- | -------- | ---------- | ----------------------- |
| User Management     | P1       | Medium     | Ban, role change        |
| Story Moderation    | P1       | Medium     | Hide, feature           |
| Report Queue        | P2       | Medium     | Review user reports     |
| Analytics Dashboard | P3       | High       | User growth, engagement |

### 4.5 Advanced Features (Phase 3+)

| Feature               | Priority | Complexity | Notes                     |
| --------------------- | -------- | ---------- | ------------------------- |
| Notifications         | P2       | High       | Real-time hoặc polling    |
| Offline Reading (PWA) | P3       | High       | Service worker caching    |
| Social Sharing        | P2       | Low        | Meta tags + share buttons |
| i18n (Đa ngôn ngữ)    | P3       | Medium     | next-intl hoặc next-i18n  |
| Reading Modes         | P2       | Low        | Font size, line height    |
| Chapter Scheduling    | P2       | Medium     | Publish at specific time  |

---

## 5. Deployment Strategy

### 5.1 Frontend (Vercel) ✅

```yaml
Why Vercel:
  - Native Next.js support
  - Automatic deployments from Git
  - Edge network (global CDN)
  - Preview deployments per PR
  - Free tier generous

Setup: 1. Connect GitHub repo
  2. Set environment variables
  3. Configure custom domain (optional)

Environment Variables:
  - NEXT_PUBLIC_API_URL
  - NEXT_PUBLIC_CLOUDINARY_CLOUD_NAME
  - GOOGLE_CLIENT_ID (for OAuth)
```

### 5.2 Backend Options

| Option                 | Pros                                         | Cons                               | Cost     |
| ---------------------- | -------------------------------------------- | ---------------------------------- | -------- |
| **Railway** ⭐         | Easy Docker deploy, managed DB, auto-scaling | Sleep after 15min (free)           | $5-20/mo |
| **Render**             | Similar to Railway, good DX                  | Cold starts                        | $7-25/mo |
| **Fly.io**             | Edge deployment, good perf                   | More complex setup                 | $0-20/mo |
| **VPS (DigitalOcean)** | Full control, no cold starts                 | Manual management                  | $6-12/mo |
| **AWS/GCP**            | Enterprise-grade                             | Complex, overkill for side project | Variable |

**Recommendation**: **Railway** cho side project

- Deploy from Dockerfile
- Managed MySQL add-on
- Managed Redis add-on
- Auto-sleep saves cost

### 5.3 Database (MySQL)

| Option             | Pros                                         | Cons                    | Cost          |
| ------------------ | -------------------------------------------- | ----------------------- | ------------- |
| **PlanetScale** ⭐ | Serverless MySQL, branching, Prisma-friendly | Free tier limited       | Free → $29/mo |
| **Railway MySQL**  | Bundled with backend                         | Not as feature-rich     | $5/mo         |
| **Neon**           | Serverless, branching                        | PostgreSQL only         | Free → $19/mo |
| **Self-hosted**    | Full control                                 | Manual backups, scaling | VPS cost      |

**Recommendation**: **PlanetScale**

- MySQL compatible (như requirement)
- Schema branching (safe migrations)
- Connection pooling built-in
- Generous free tier (1B row reads/mo)

### 5.4 Caching (Redis)

| Option            | Pros                         | Cons                      | Cost          |
| ----------------- | ---------------------------- | ------------------------- | ------------- |
| **Upstash** ⭐    | Serverless, pay-per-request  | May be expensive at scale | Free → $10/mo |
| **Railway Redis** | Bundled                      | Always on (cost)          | $5/mo         |
| **Redis Cloud**   | Managed, enterprise features | Complex                   | $0-200/mo     |

**Recommendation**: **Upstash**

- Serverless (pay only for what you use)
- REST API (no persistent connection needed)
- Rate limiting package available

### 5.5 Recommended Stack Summary

```
┌────────────────────────────────────────────────────────────┐
│                    PRODUCTION STACK                         │
├────────────────────────────────────────────────────────────┤
│  Frontend:      Vercel (free → pro)                        │
│  Backend:       Railway (Docker)                            │
│  Database:      PlanetScale (MySQL serverless)             │
│  Cache:         Upstash Redis                               │
│  Storage:       Cloudinary                                  │
│  Email:         Resend                                      │
│  Monitoring:    Vercel Analytics + Sentry (free tier)      │
└────────────────────────────────────────────────────────────┘

Monthly Cost Estimate:
  - Phase 1 (MVP): $0-10/mo (free tiers)
  - Phase 2 (1K users): $20-40/mo
  - Phase 3 (10K users): $50-100/mo
```

---

## 6. CI/CD Suggestions

### 6.1 Recommended: GitHub Actions + Vercel + Railway

```yaml
# .github/workflows/ci.yml
name: CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  lint-and-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: "20"
          cache: "npm"

      - name: Install dependencies
        run: npm ci

      - name: Lint
        run: npm run lint

      - name: Type check
        run: npm run type-check

      - name: Unit tests
        run: npm run test

  # Frontend auto-deploys via Vercel GitHub integration
  # Backend deploys via Railway GitHub integration
```

### 6.2 Branch Strategy

```
main          ─────────────────────────────▶ Production
                    │
develop       ──────┼─────────────────────▶ Staging (optional)
                    │
feature/*     ─────────────────────────────▶ Preview (Vercel)
```

### 6.3 Deployment Flow

```
1. Push to feature branch
   └─▶ GitHub Actions: lint, test
   └─▶ Vercel: Preview deployment
   └─▶ Railway: (optional) Preview environment

2. Merge to main
   └─▶ GitHub Actions: lint, test
   └─▶ Vercel: Auto-deploy to production
   └─▶ Railway: Auto-deploy to production
   └─▶ PlanetScale: Safe schema migration (if any)
```

---

## 7. Scalability Notes

### 7.1 Current Architecture Supports

| Metric           | Phase 1 | Phase 2 | Phase 3   |
| ---------------- | ------- | ------- | --------- |
| Concurrent Users | 100     | 1,000   | 10,000    |
| Stories          | 1,000   | 10,000  | 100,000   |
| Chapters         | 10,000  | 100,000 | 1,000,000 |
| Monthly Reads    | 100K    | 1M      | 10M       |

### 7.2 Scaling Checklist

> Khi nào nên làm gì?

**At 1K Users:**

- [ ] Add Redis caching for hot stories
- [ ] Implement rate limiting
- [ ] Add CDN for images (Cloudinary đã có)
- [ ] Monitor slow queries

**At 10K Users:**

- [ ] Add read replicas (PlanetScale supports)
- [ ] Implement cursor-based pagination
- [ ] Add full-text search (MySQL FULLTEXT hoặc Meilisearch)
- [ ] Consider horizontal scaling (multiple backend instances)

**At 100K Users:**

- [ ] Extract heavy services (notifications, search)
- [ ] Add message queue (BullMQ) for background jobs
- [ ] Consider Elasticsearch for search
- [ ] Add APM (Datadog/New Relic)

### 7.3 Database Optimization Roadmap

```sql
-- Phase 1: Basic indexes (already in Prisma schema)
@@index([storyId, status])
@@index([authorId])

-- Phase 2: Add composite indexes for common queries
CREATE INDEX idx_story_trending ON Story (status, publishedAt, viewCount DESC);
CREATE INDEX idx_chapter_reading ON Chapter (storyId, orderIndex, status);

-- Phase 3: Full-text search
ALTER TABLE Story ADD FULLTEXT(title, description);
ALTER TABLE Chapter ADD FULLTEXT(title, content);
```

---

## 8. Security & Best Practices

### 8.1 Security Checklist

| Area                 | Implementation                       | Priority |
| -------------------- | ------------------------------------ | -------- |
| **Authentication**   |                                      |          |
| Password hashing     | bcrypt with salt rounds 12           | P0       |
| JWT security         | Short-lived access, httpOnly refresh | P0       |
| OAuth state          | CSRF protection with state param     | P0       |
| **Input Validation** |                                      |          |
| API validation       | Zod schemas on all endpoints         | P0       |
| XSS prevention       | DOMPurify for Tiptap content         | P0       |
| SQL injection        | Prisma (parameterized queries)       | P0       |
| **Rate Limiting**    |                                      |          |
| Auth endpoints       | 5 req/min per IP                     | P0       |
| API endpoints        | 100 req/min per user                 | P0       |
| Upload endpoints     | 10 req/min per user                  | P0       |
| **Headers**          |                                      |          |
| CORS                 | Whitelist frontend domain            | P0       |
| CSP                  | Strict policy for scripts            | P1       |
| HSTS                 | Enable on production                 | P1       |
| **Data Protection**  |                                      |          |
| HTTPS                | Enforced everywhere                  | P0       |
| File uploads         | Type + size validation               | P0       |
| Sensitive data       | Never log passwords/tokens           | P0       |

### 8.2 Code Quality

```yaml
Tools:
  - ESLint: Consistent code style
  - Prettier: Auto-formatting
  - TypeScript: Type safety
  - Husky: Pre-commit hooks

Pre-commit checks:
  - npm run lint
  - npm run type-check
  - npm run test (affected)
```

### 8.3 Error Handling Pattern

```typescript
// Centralized error handler
class AppError extends Error {
  constructor(
    public statusCode: number,
    public message: string,
    public isOperational = true
  ) {
    super(message);
  }
}

// Usage
throw new AppError(404, "Story not found");
throw new AppError(403, "Not authorized to edit this story");
```

---

## 9. Simple Development Roadmap

### Phase 1: MVP Foundation (8-12 tuần)

```
Week 1-2: Setup & Auth
├── [ ] Project setup (Next.js, Express, Prisma)
├── [ ] Database schema & migrations
├── [ ] Email/Password registration
├── [ ] Email verification flow
├── [ ] Login/Logout
└── [ ] Google OAuth

Week 3-4: Story System
├── [ ] Story CRUD (author only)
├── [ ] Chapter CRUD
├── [ ] Tiptap editor integration
├── [ ] Image upload (Cloudinary)
└── [ ] Draft/Publish flow

Week 5-6: Reading Experience
├── [ ] Story listing page
├── [ ] Story detail page
├── [ ] Chapter reading page
├── [ ] Dark/Light mode
└── [ ] Mobile responsive

Week 7-8: Discovery
├── [ ] Search functionality
├── [ ] Genre/Tag filtering
├── [ ] Basic sorting (new, popular)
└── [ ] User profile page

Week 9-10: Polish & Deploy
├── [ ] UI/UX polish
├── [ ] Error handling
├── [ ] Loading states
├── [ ] SEO meta tags
└── [ ] Production deployment

Week 11-12: Testing & Bug fixes
├── [ ] Manual testing
├── [ ] Bug fixes
├── [ ] Performance optimization
└── [ ] Documentation
```

**MVP Deliverables:**

- ✅ Users can register, login, reset password
- ✅ Authors can create/edit/publish stories
- ✅ Readers can browse, search, and read stories
- ✅ Works on mobile and desktop
- ✅ Dark/Light mode

---

### Phase 2: Engagement & Community (6-8 tuần)

```
Week 1-2: Interactions
├── [ ] Like stories
├── [ ] Bookmark/Library
├── [ ] Follow authors
└── [ ] Reading progress sync

Week 3-4: Comments & Notifications
├── [ ] Chapter comments
├── [ ] Comment replies
├── [ ] Basic notifications (polling)
└── [ ] Notification preferences

Week 5-6: Author Tools
├── [ ] Author dashboard
├── [ ] Story statistics
├── [ ] Chapter scheduling
└── [ ] Story reordering

Week 7-8: Admin Panel
├── [ ] User management
├── [ ] Story moderation
├── [ ] Report system
└── [ ] Basic analytics
```

**Phase 2 Deliverables:**

- ✅ Users can like, bookmark, follow
- ✅ Comments on chapters
- ✅ Notifications for new chapters
- ✅ Author analytics dashboard
- ✅ Admin can moderate content

---

### Phase 3: Growth & Scale (8-12 tuần)

```
Week 1-3: Discovery Enhancement
├── [ ] Trending algorithm
├── [ ] Recommendation engine (basic)
├── [ ] Reading lists (public)
└── [ ] Search improvements

Week 4-6: Advanced Features
├── [ ] Offline reading (PWA)
├── [ ] i18n (Tiếng Việt + English)
├── [ ] Social sharing
└── [ ] Reading modes (font, spacing)

Week 7-9: Performance & Scale
├── [ ] Redis caching
├── [ ] Database optimization
├── [ ] CDN optimization
└── [ ] Load testing

Week 10-12: Community Features
├── [ ] User badges/achievements
├── [ ] Writing contests
├── [ ] Featured stories
└── [ ] Community forums (optional)
```

**Phase 3 Deliverables:**

- ✅ Smart recommendations
- ✅ Offline reading capability
- ✅ Multi-language support
- ✅ Handles 10K+ concurrent users

---

## 10. Tech Stack Summary

| Layer          | Technology                | Why                           |
| -------------- | ------------------------- | ----------------------------- |
| **Frontend**   | Next.js 14 (App Router)   | SSR, RSC, best DX             |
|                | TailwindCSS               | Fast styling, dark mode       |
|                | Tiptap                    | Best rich text for React      |
|                | Framer Motion             | Smooth animations             |
| **Backend**    | Node.js + Express/Fastify | Simple, you know it           |
|                | Prisma                    | Type-safe ORM, MySQL support  |
|                | Zod                       | Runtime validation            |
|                | Passport.js               | Auth strategies               |
| **Database**   | MySQL (PlanetScale)       | Relational, serverless        |
|                | Redis (Upstash)           | Caching, rate limiting        |
| **Storage**    | Cloudinary                | Images, CDN, optimization     |
| **Email**      | Resend                    | Modern, good DX, free tier    |
| **Deploy**     | Vercel (FE)               | Native Next.js                |
|                | Railway (BE)              | Easy Docker, managed services |
| **CI/CD**      | GitHub Actions            | Free, integrated              |
| **Monitoring** | Sentry                    | Error tracking                |
|                | Vercel Analytics          | Frontend metrics              |

---

## 11. Quick Start Commands

```bash
# Frontend
npx create-next-app@latest story-platform-web --typescript --tailwind --app --eslint
cd story-platform-web
npm install @tiptap/react @tiptap/starter-kit framer-motion

# Backend
mkdir story-platform-api && cd story-platform-api
npm init -y
npm install express prisma @prisma/client zod bcrypt jsonwebtoken passport passport-google-oauth20
npm install -D typescript @types/express @types/node ts-node nodemon

# Database
npx prisma init --datasource-provider mysql
# Update schema.prisma with models above
npx prisma migrate dev --name init
```

---

## 12. Critical Success Factors

> [!IMPORTANT] > **Để project không "chết yểu":**

1. **MVP First**: Launch Phase 1 trong 3 tháng, đừng over-engineer
2. **Mobile-First**: 70%+ users sẽ đọc trên điện thoại
3. **Performance**: Chapter load < 2s, editor smooth
4. **Tiptap Investment**: Dành thời gian customize editor tốt
5. **Content Seeding**: Mời 5-10 tác giả viết truyện đầu tiên
6. **Feedback Loop**: Lắng nghe user từ ngày đầu

---

> **Document created**: 2026-01-29
> **Last updated**: 2026-01-29
> **Author**: Antigravity Agent (Senior Fullstack Architect & Product Planner role)
