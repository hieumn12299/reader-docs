# 📏 Quy Tắc Viết Code — Story Platform

> **Mục đích**: Quy ước code cho toàn dự án. Mọi code mới phải tuân thủ các quy tắc này.

> **Cập nhật lần cuối**: 2026-03-01

---

## 1. TypeScript — Nghiêm Ngặt

### ❌ TUYỆT ĐỐI KHÔNG dùng `any`

```typescript
// ❌ SAI
const handleData = (data: any) => { ... }
const response: any = await fetch(url);

// ✅ ĐÚNG
const handleData = (data: StoryFormData) => { ... }
const response: ApiResponse<Story> = await fetch(url);

// ✅ Nếu chưa biết type → dùng unknown rồi narrowing
const handleUnknown = (data: unknown) => {
  if (isStory(data)) {
    // data giờ là Story type
  }
};
```

**ESLint rule**: `"@typescript-eslint/no-explicit-any": "error"`

### Quy tắc Type khác

```typescript
// ✅ Dùng interface cho object shapes
interface User {
  id: string;
  email: string;
  displayName: string;
}

// ✅ Dùng type cho unions, intersections, mapped types
type StoryStatus = 'DRAFT' | 'PUBLISHED' | 'COMPLETED';
type WithTimestamps<T> = T & { createdAt: Date; updatedAt: Date };

// ✅ Export types từ lib/types/
export type { User, Story, Chapter } from '@/lib/types/story.types';
```

---

## 2. ESLint & Prettier

### Cấu hình hiện tại

**ESLint** (`eslint.config.mjs`):

- Extends: `next/core-web-vitals`, `next/typescript`, `prettier`
- `@typescript-eslint/no-unused-vars`: `"warn"` (bỏ qua `_` prefix)
- `@typescript-eslint/no-explicit-any`: `"error"` ← BẮT BUỘC
- `prefer-const`: `"warn"`

**Prettier** (`.prettierrc`):

- `semi`: true
- `singleQuote`: true
- `tabWidth`: 2
- `trailingComma`: "es5"
- `printWidth`: 100
- `endOfLine`: "lf"
- Plugin: `prettier-plugin-tailwindcss` (tự sắp xếp Tailwind classes)

### Trước khi commit

```bash
pnpm lint        # Kiểm tra ESLint
pnpm lint:fix    # Tự fix ESLint
pnpm format      # Format Prettier
pnpm format:check # Kiểm tra format
```

---

## 3. React & Next.js Conventions

### Server vs Client Components

```typescript
// Server Component (mặc định) — KHÔNG cần directive
// Dùng cho: fetch data, static content, SEO
export default async function StoryPage({ params }: Props) {
  const story = await getStory(params.id);
  return <StoryDetail story={story} />;
}

// Client Component — CẦN "use client"
// Dùng cho: state, hooks, event handlers, browser APIs
"use client";
export function LikeButton({ storyId }: { storyId: string }) {
  const [liked, setLiked] = useState(false);
  return <Button onClick={() => setLiked(!liked)}>Like</Button>;
}
```

### Quy tắc chọn Server vs Client

| Tiêu chí                            | Server Component | Client Component |
| ----------------------------------- | ---------------- | ---------------- |
| Fetch data từ DB/API                | ✅               | ❌               |
| SEO content                         | ✅               | ❌               |
| Dùng hooks (useState, useEffect)    | ❌               | ✅               |
| Event handlers (onClick, onChange)  | ❌               | ✅               |
| Browser APIs (localStorage, window) | ❌               | ✅               |
| Animations (Framer Motion)          | ❌               | ✅               |

### Component Props

```typescript
// ✅ Luôn định nghĩa interface cho props
interface StoryCardProps {
  story: Story;
  showAuthor?: boolean;
  compact?: boolean;
  onBookmark?: (storyId: string) => void;
}

// ✅ Dùng React.ComponentProps cho HTML elements
interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'default' | 'destructive' | 'outline';
  size?: 'default' | 'sm' | 'lg';
}

// ❌ KHÔNG dùng FC (React.FunctionComponent) — đã outdated
// ❌ const MyComponent: React.FC<Props> = (props) => { ... }
// ✅ function MyComponent(props: Props) { ... }
```

### Import Convention

```typescript
// 1. React/Next.js imports
import { useState, useEffect } from 'react';
import Link from 'next/link';
import Image from 'next/image';

// 2. Third-party imports
import { motion } from 'framer-motion';
import { useForm } from 'react-hook-form';

// 3. Internal imports (path alias @/)
import { Button } from '@/components/ui/button';
import { useAuth } from '@/hooks/use-auth';
import { cn } from '@/lib/utils';
import type { Story } from '@/lib/types/story.types';
```

---

## 4. Naming Conventions

### Files & Folders

| Loại       | Convention                    | Ví dụ                   |
| ---------- | ----------------------------- | ----------------------- |
| Components | kebab-case                    | `story-card.tsx`        |
| Pages      | `page.tsx`                    | `app/[locale]/page.tsx` |
| Hooks      | kebab-case, prefix `use-`     | `use-auth.ts`           |
| Stores     | kebab-case, suffix `.store`   | `auth.store.ts`         |
| Services   | kebab-case, suffix `.service` | `story.service.ts`      |
| Types      | kebab-case, suffix `.types`   | `story.types.ts`        |
| Schemas    | kebab-case, suffix `.schema`  | `auth.schema.ts`        |
| Constants  | kebab-case                    | `constants.ts`          |

### Variables & Functions

| Loại               | Convention              | Ví dụ                              |
| ------------------ | ----------------------- | ---------------------------------- |
| Components         | PascalCase              | `StoryCard`, `LoginForm`           |
| Functions          | camelCase               | `getStories()`, `handleSubmit()`   |
| Hooks              | camelCase, prefix `use` | `useAuth()`, `useDebounce()`       |
| Constants          | UPPER_SNAKE_CASE        | `MAX_FILE_SIZE`, `API_BASE_URL`    |
| Type/Interface     | PascalCase              | `Story`, `ApiResponse`             |
| Enum values        | UPPER_SNAKE_CASE        | `DRAFT`, `PUBLISHED`               |
| Boolean props/vars | prefix verb             | `isLoading`, `hasError`, `canEdit` |

---

## 5. API Integration

### Service Layer Pattern

```typescript
// src/services/story.service.ts
import { api } from './api';
import type { Story, CreateStoryInput } from '@/lib/types/story.types';
import type { ApiResponse, PaginatedResponse } from '@/lib/types/api.types';

export const storyService = {
  getAll: (params?: { page?: number; limit?: number }) =>
    api.get<PaginatedResponse<Story>>('/stories', { params }),

  getById: (id: string) => api.get<ApiResponse<Story>>(`/stories/${id}`),

  create: (data: CreateStoryInput) => api.post<ApiResponse<Story>>('/stories', data),

  update: (id: string, data: Partial<CreateStoryInput>) =>
    api.patch<ApiResponse<Story>>(`/stories/${id}`, data),

  delete: (id: string) => api.delete<ApiResponse<null>>(`/stories/${id}`),
};
```

### React Query Convention

```typescript
// Trong component hoặc custom hook
const { data, isLoading, error } = useQuery({
  queryKey: ['stories', filters],
  queryFn: () => storyService.getAll(filters),
  staleTime: 5 * 60 * 1000, // 5 phút
});

const mutation = useMutation({
  mutationFn: storyService.create,
  onSuccess: () => {
    queryClient.invalidateQueries({ queryKey: ['stories'] });
    toast.success('Tạo truyện thành công!');
  },
  onError: (error: ApiError) => {
    toast.error(error.message);
  },
});
```

---

## 6. Error Handling

```typescript
// ✅ Luôn handle error, KHÔNG bỏ trống catch
try {
  const result = await storyService.create(data);
  return result;
} catch (error) {
  if (error instanceof ApiError) {
    toast.error(error.message);
  } else {
    toast.error("Đã xảy ra lỗi không xác định");
    console.error("Unexpected error:", error);
  }
}

// ❌ KHÔNG
try { ... } catch (e) { }  // empty catch
try { ... } catch (e: any) { ... }  // any trong catch
```

---

## 7. Quy Tắc Cập Nhật Liên Quan

> **Yêu cầu #2**: Khi tạo/update bất kỳ thứ gì → update các file liên quan

### Checklist cập nhật khi thay đổi code

| Khi...                       | Cập nhật...                                   |
| ---------------------------- | --------------------------------------------- |
| Tạo component dùng chung mới | `REUSABLE-COMPONENTS.md`                      |
| Thêm file/folder mới         | `FOLDER-STRUCTURE.md` (nếu khác pattern)      |
| Thêm dependency mới          | `ARCHITECTURE.md` (Tech Stack)                |
| Thay đổi API endpoint        | Types trong `lib/types/`, Services            |
| Thêm Zod schema              | `lib/validations/` + `REUSABLE-COMPONENTS.md` |
| Tạo hook mới dùng chung      | `REUSABLE-COMPONENTS.md`                      |
| Thay đổi folder structure    | `FOLDER-STRUCTURE.md`                         |

---

> **Tài liệu liên quan**: [FOLDER-STRUCTURE.md](./FOLDER-STRUCTURE.md) · [REUSABLE-COMPONENTS.md](./REUSABLE-COMPONENTS.md) · [CHECKLIST-TEMPLATES.md](./CHECKLIST-TEMPLATES.md)
