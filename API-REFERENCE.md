# 📖 BE API Reference — Story Platform

> **Base URL**: `http://localhost:3001/api` > **Swagger UI**: `http://localhost:3001/api/docs` > **Auth**: JWT Bearer Token (`Authorization: Bearer <accessToken>`)
> **i18n**: Header `x-lang: vi` hoặc `x-lang: en` (default: `vi`)

---

## Response Format

### ✅ Success Response

```jsonc
{
  "statusCode": 200,
  "message": "Thông báo thành công",
  "data": { ... },
  "meta": {                    // Chỉ có khi paginated
    "page": 1,
    "limit": 10,
    "total": 50,
    "totalPages": 5
  }
}
```

### ❌ Error Response

```jsonc
{
  "statusCode": 400,
  "message": "Mô tả lỗi",
  "error": "Bad Request",
  "details": {
    // Chỉ có khi validation error
    "email": ["Email không hợp lệ"],
    "password": ["Mật khẩu phải có ít nhất 6 ký tự"]
  }
}
```

---

## Enums

| Enum            | Values                                                    |
| --------------- | --------------------------------------------------------- |
| `Role`          | `READER` · `AUTHOR` · `ADMIN`                             |
| `StoryStatus`   | `DRAFT` · `PUBLISHED` · `COMPLETED` · `HIATUS` · `HIDDEN` |
| `ChapterStatus` | `DRAFT` · `PUBLISHED` · `SCHEDULED`                       |
| `SortOrder`     | `ASC` · `DESC`                                            |

---

## 🔐 Auth Module

### `POST /api/auth/register`

Đăng ký tài khoản mới.

| Field         | Type   | Required | Validation  |
| ------------- | ------ | -------- | ----------- |
| `email`       | string | ✅       | Valid email |
| `password`    | string | ✅       | 6–50 chars  |
| `displayName` | string | ✅       | 2–50 chars  |

**Response `201`** → `{ user, accessToken, refreshToken, expiresIn }`

```jsonc
{
  "statusCode": 201,
  "message": "Đăng ký thành công",
  "data": {
    "user": {
      "id": "cuid",
      "email": "...",
      "displayName": "...",
      "role": "READER"
    },
    "accessToken": "eyJ...",
    "refreshToken": "eyJ...",
    "expiresIn": 900 // seconds (15 phút)
  }
}
```

**Errors**: `400` email đã tồn tại

---

### `POST /api/auth/login`

| Field      | Type   | Required |
| ---------- | ------ | -------- |
| `email`    | string | ✅       |
| `password` | string | ✅       |

**Response `200`** → `{ user, accessToken, refreshToken, expiresIn }`

```jsonc
{
  "data": {
    "user": {
      "id": "...",
      "email": "...",
      "displayName": "...",
      "role": "AUTHOR",
      "avatarUrl": null
    },
    "accessToken": "eyJ...",
    "refreshToken": "eyJ...",
    "expiresIn": 900
  }
}
```

**Errors**: `401` sai email/mật khẩu

---

### `POST /api/auth/refresh`

| Field          | Type   | Required |
| -------------- | ------ | -------- |
| `refreshToken` | string | ✅       |

**Response `200`** → `{ accessToken, refreshToken, expiresIn }`

**Errors**: `401` token hết hạn/không hợp lệ

---

### `GET /api/auth/me` 🔒

**Headers**: `Authorization: Bearer <accessToken>`

**Response `200`**:

```jsonc
{
  "data": {
    "id": "...",
    "email": "...",
    "displayName": "...",
    "avatarUrl": null,
    "role": "AUTHOR",
    "emailVerified": true,
    "createdAt": "2026-03-01T...",
    "_count": { "stories": 8, "followers": 5, "follows": 3 }
  }
}
```

---

## 📚 Story Module

### `GET /api/stories`

Danh sách truyện có phân trang và filter.

| Query Param | Type        | Default     | Note                                   |
| ----------- | ----------- | ----------- | -------------------------------------- |
| `page`      | number      | `1`         | min: 1                                 |
| `limit`     | number      | `10`        | 1–100                                  |
| `sortBy`    | string      | `createdAt` | `createdAt` · `viewCount` · `title`    |
| `order`     | string      | `DESC`      | `ASC` · `DESC`                         |
| `status`    | StoryStatus | —           | Mặc định chỉ `PUBLISHED` + `COMPLETED` |
| `genreId`   | string      | —           | Filter theo genre ID                   |
| `search`    | string      | —           | Tìm theo title (contains)              |

**Response `200`**:

```jsonc
{
  "data": [
    {
      "id": "...",
      "title": "...",
      "slug": "...",
      "description": "...",
      "coverImage": null,
      "status": "PUBLISHED",
      "mature": false,
      "viewCount": 15200,
      "authorId": "...",
      "createdAt": "...",
      "updatedAt": "...",
      "publishedAt": "...",
      "author": { "id": "...", "displayName": "...", "avatarUrl": null },
      "genres": [
        {
          "storyId": "...",
          "genreId": "...",
          "genre": { "id": "...", "name": "Fantasy", "slug": "fantasy" }
        }
      ],
      "_count": { "chapters": 3, "likes": 0, "bookmarks": 0, "comments": 0 }
    }
  ],
  "meta": { "page": 1, "limit": 10, "total": 8, "totalPages": 1 }
}
```

---

### `GET /api/stories/:id`

Chi tiết truyện (kèm published chapters).

**Response `200`** — thêm so với list:

- `tags[]` — `{ storyId, tagId, tag: { id, name } }`
- `chapters[]` — `{ id, title, orderIndex, wordCount, publishedAt }` (chỉ PUBLISHED, sort by orderIndex ASC)

**Errors**: `404`

---

### `POST /api/stories` 🔒 AUTHOR/ADMIN

| Field         | Type     | Required | Validation         |
| ------------- | -------- | -------- | ------------------ |
| `title`       | string   | ✅       | 1–200 chars        |
| `description` | string   | ✅       | 10–5000 chars      |
| `coverImage`  | string   | ❌       | Valid URL          |
| `mature`      | boolean  | ❌       | default `false`    |
| `genreIds`    | string[] | ❌       | Array of genre IDs |
| `tagIds`      | string[] | ❌       | Array of tag IDs   |

**Response `201`** → Story object (includes author, genres, tags)

**Errors**: `401` chưa login · `403` READER không có quyền

---

### `PATCH /api/stories/:id` 🔒 Owner only

Partial update — gửi field nào update field đó.

| Field         | Type        | Note                                                      |
| ------------- | ----------- | --------------------------------------------------------- |
| `title`       | string      | 1–200 chars                                               |
| `description` | string      | 10–5000 chars                                             |
| `coverImage`  | string      | Valid URL                                                 |
| `mature`      | boolean     |                                                           |
| `status`      | StoryStatus | `DRAFT` · `PUBLISHED` · `COMPLETED` · `HIATUS` · `HIDDEN` |
| `genreIds`    | string[]    | Replace all genres                                        |
| `tagIds`      | string[]    | Replace all tags                                          |

> Khi set `status = PUBLISHED` lần đầu → auto set `publishedAt`.

**Errors**: `401` · `403` không phải tác giả · `404`

---

### `DELETE /api/stories/:id` 🔒 Owner only

Soft delete → set `status = HIDDEN`.

**Response `200`** → `{ data: null }`

---

## 🔑 JWT Configuration

| Config            | Value                                       |
| ----------------- | ------------------------------------------- |
| Access Token TTL  | **15 phút** (900s)                          |
| Refresh Token TTL | **7 ngày**                                  |
| JWT Payload       | `{ sub: userId, email, role, displayName }` |

---

## 🧪 Test Accounts (Seed Data)

| Email               | Password       | Role   |
| ------------------- | -------------- | ------ |
| `admin@reader.com`  | `Password123!` | ADMIN  |
| `author@reader.com` | `Password123!` | AUTHOR |
| `reader@reader.com` | `Password123!` | READER |

Chạy `pnpm db:seed` trong `be-reader` để tạo data.

---

## 📊 Models chưa có API

Các model sau có trong Prisma schema nhưng **chưa có controller** — cần implement khi FE yêu cầu:

| Model             | Mô tả                      | Priority  |
| ----------------- | -------------------------- | --------- |
| `Chapter`         | CRUD chương truyện         | 🔴 High   |
| `Genre`           | List thể loại              | 🔴 High   |
| `Tag`             | List tags                  | 🟡 Medium |
| `Like`            | Like/unlike truyện         | 🟡 Medium |
| `Bookmark`        | Bookmark truyện            | 🟡 Medium |
| `Comment`         | Bình luận (nested replies) | 🟡 Medium |
| `Follow`          | Follow tác giả             | 🟢 Low    |
| `ReadingProgress` | Tiến trình đọc             | 🟢 Low    |
| `Report`          | Báo cáo vi phạm            | 🟢 Low    |
| `ChapterVersion`  | Lịch sử chỉnh sửa          | 🟢 Low    |
| `OAuthAccount`    | OAuth login                | 🟢 Low    |
