# 🧪 Hướng Dẫn Testing — Story Platform

> **Mục đích**: Chiến lược testing, tools, templates test case, và quy trình kiểm tra cho mọi tính năng.

> **Cập nhật lần cuối**: 2026-03-01

---

## 1. Chiến Lược Testing

### Kim tự tháp Testing

```
           ┌─────────┐
           │  E2E    │  ← Ít nhất, đắt nhất
           │(Browser)│
          ┌┴─────────┴┐
          │Integration │  ← Trung bình
          │ (API/Hook) │
         ┌┴────────────┴┐
         │    Unit Test  │  ← Nhiều nhất, rẻ nhất
         │ (Function/Comp)│
         └───────────────┘
```

| Loại        | Công cụ                            | Tỷ lệ | Mục đích                              |
| ----------- | ---------------------------------- | ----- | ------------------------------------- |
| Unit        | Vitest + React Testing Library     | 70%   | Functions, utils, components riêng lẻ |
| Integration | Vitest + MSW (Mock Service Worker) | 20%   | Hooks + API, form submissions         |
| E2E         | Playwright                         | 10%   | User flows trên browser thật          |

---

## 2. Tools Cần Cài Đặt

```bash
# Unit & Integration testing
pnpm add -D vitest @testing-library/react @testing-library/jest-dom @vitejs/plugin-react jsdom

# Mock Service Worker (mock API)
pnpm add -D msw

# E2E testing
pnpm add -D @playwright/test
npx playwright install
```

### Config Files Cần Tạo

**`vitest.config.ts`**:

```typescript
import { defineConfig } from 'vitest/config';
import react from '@vitejs/plugin-react';
import path from 'path';

export default defineConfig({
  plugins: [react()],
  test: {
    environment: 'jsdom',
    globals: true,
    setupFiles: ['./src/test/setup.ts'],
    include: ['src/**/*.{test,spec}.{ts,tsx}'],
    coverage: {
      reporter: ['text', 'html'],
      exclude: ['node_modules/', 'src/test/'],
    },
  },
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
    },
  },
});
```

**`src/test/setup.ts`**:

```typescript
import '@testing-library/jest-dom';
```

**Scripts trong `package.json`**:

```json
{
  "scripts": {
    "test": "vitest",
    "test:run": "vitest run",
    "test:coverage": "vitest run --coverage",
    "test:e2e": "playwright test"
  }
}
```

---

## 3. Quy Tắc Viết Test

### ❌ KHÔNG

```typescript
// ❌ Sử dụng any
const mockData: any = { ... };

// ❌ Test implementation details
expect(component.state.isOpen).toBe(true);

// ❌ Test bỏ trống
it("should work", () => {});
```

### ✅ NÊN

```typescript
// ✅ Type đầy đủ
const mockStory: Story = {
  id: "1",
  title: "Test Story",
  slug: "test-story",
  // ...
};

// ✅ Test behavior (user perspective)
expect(screen.getByText("Test Story")).toBeInTheDocument();

// ✅ Test rõ ràng
it("hiển thị title của truyện khi data load thành công", () => { ... });
```

### Đặt tên file test

| File gốc           | File test               |
| ------------------ | ----------------------- |
| `utils.ts`         | `utils.test.ts`         |
| `button.tsx`       | `button.test.tsx`       |
| `story.service.ts` | `story.service.test.ts` |
| `use-auth.ts`      | `use-auth.test.ts`      |

### Đặt tên test cases

```typescript
describe("StoryCard", () => {
  it("hiển thị title và author name", () => { ... });
  it("hiển thị cover image với fallback khi không có ảnh", () => { ... });
  it("navigate đến trang chi tiết khi click", () => { ... });
  it("hiển thị badge 'Mới' nếu story tạo trong 7 ngày", () => { ... });
});
```

---

## 4. Templates Test Case

### 4.1 Unit Test — Utility Function

```typescript
// src/lib/utils.test.ts
import { cn, formatDate, truncate } from './utils';

describe('cn', () => {
  it('merge classes đơn giản', () => {
    expect(cn('px-4', 'py-2')).toBe('px-4 py-2');
  });

  it('resolve conflicts (class sau thắng)', () => {
    expect(cn('px-4', 'px-8')).toBe('px-8');
  });

  it('handle conditional classes', () => {
    expect(cn('base', false && 'hidden', 'visible')).toBe('base visible');
  });
});

describe('formatDate', () => {
  it('format date sang dd/MM/yyyy', () => {
    expect(formatDate(new Date('2026-01-15'))).toBe('15/01/2026');
  });

  it('handle null/undefined trả về chuỗi rỗng', () => {
    expect(formatDate(null)).toBe('');
  });
});

describe('truncate', () => {
  it('cắt chuỗi dài hơn maxLength', () => {
    expect(truncate('Hello World', 5)).toBe('Hello...');
  });

  it('giữ nguyên chuỗi ngắn hơn maxLength', () => {
    expect(truncate('Hi', 10)).toBe('Hi');
  });
});
```

### 4.2 Unit Test — React Component

```typescript
// src/components/ui/button.test.tsx
import { render, screen, fireEvent } from "@testing-library/react";
import { Button } from "./button";

describe("Button", () => {
  it("render children text", () => {
    render(<Button>Click me</Button>);
    expect(screen.getByText("Click me")).toBeInTheDocument();
  });

  it("gọi onClick khi click", () => {
    const handleClick = vi.fn();
    render(<Button onClick={handleClick}>Click</Button>);
    fireEvent.click(screen.getByText("Click"));
    expect(handleClick).toHaveBeenCalledOnce();
  });

  it("disabled state ngăn click", () => {
    const handleClick = vi.fn();
    render(<Button disabled onClick={handleClick}>Click</Button>);
    fireEvent.click(screen.getByText("Click"));
    expect(handleClick).not.toHaveBeenCalled();
  });

  it("render variant đúng class", () => {
    const { container } = render(<Button variant="destructive">Delete</Button>);
    expect(container.firstChild).toHaveClass("bg-destructive");
  });
});
```

### 4.3 Integration Test — Custom Hook

```typescript
// src/hooks/use-auth.test.ts
import { renderHook, act } from '@testing-library/react';
import { useAuth } from './use-auth';

// Mock API service
vi.mock('@/services/auth.service', () => ({
  authService: {
    login: vi.fn(),
    logout: vi.fn(),
    getMe: vi.fn(),
  },
}));

describe('useAuth', () => {
  it('khởi tạo với user = null và isAuthenticated = false', () => {
    const { result } = renderHook(() => useAuth());
    expect(result.current.user).toBeNull();
    expect(result.current.isAuthenticated).toBe(false);
  });

  it('login thành công cập nhật user state', async () => {
    const mockUser = { id: '1', email: 'test@test.com', displayName: 'Test' };
    // setup mock...

    const { result } = renderHook(() => useAuth());
    await act(async () => {
      await result.current.login({ email: 'test@test.com', password: '123456' });
    });

    expect(result.current.user).toEqual(mockUser);
    expect(result.current.isAuthenticated).toBe(true);
  });

  it('logout xoá user state', async () => {
    const { result } = renderHook(() => useAuth());
    await act(async () => {
      await result.current.logout();
    });

    expect(result.current.user).toBeNull();
    expect(result.current.isAuthenticated).toBe(false);
  });
});
```

### 4.4 E2E Test — User Flow

```typescript
// e2e/auth/login.spec.ts
import { test, expect } from '@playwright/test';

test.describe('Login Flow', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/vi/login');
  });

  test('hiển thị form login với email và password', async ({ page }) => {
    await expect(page.getByLabel('Email')).toBeVisible();
    await expect(page.getByLabel('Mật khẩu')).toBeVisible();
    await expect(page.getByRole('button', { name: 'Đăng nhập' })).toBeVisible();
  });

  test('hiển thị lỗi khi submit form rỗng', async ({ page }) => {
    await page.getByRole('button', { name: 'Đăng nhập' }).click();
    await expect(page.getByText('Email không được để trống')).toBeVisible();
    await expect(page.getByText('Mật khẩu không được để trống')).toBeVisible();
  });

  test('hiển thị lỗi khi email sai format', async ({ page }) => {
    await page.getByLabel('Email').fill('invalid-email');
    await page.getByLabel('Mật khẩu').fill('password123');
    await page.getByRole('button', { name: 'Đăng nhập' }).click();
    await expect(page.getByText('Email không hợp lệ')).toBeVisible();
  });

  test('đăng nhập thành công và redirect về trang chủ', async ({ page }) => {
    await page.getByLabel('Email').fill('user@example.com');
    await page.getByLabel('Mật khẩu').fill('ValidPass123');
    await page.getByRole('button', { name: 'Đăng nhập' }).click();
    await expect(page).toHaveURL(/\/vi$/);
  });
});
```

---

## 5. Test Cases Theo Tính Năng

### Authentication

| ID      | Test Case                          | Loại        | Priority |
| ------- | ---------------------------------- | ----------- | -------- |
| AUTH-01 | Đăng ký với email hợp lệ           | E2E         | P0       |
| AUTH-02 | Đăng ký với email đã tồn tại → lỗi | Integration | P0       |
| AUTH-03 | Đăng nhập email/password đúng      | E2E         | P0       |
| AUTH-04 | Đăng nhập sai password → lỗi       | Integration | P0       |
| AUTH-05 | Đăng nhập Google OAuth             | E2E         | P0       |
| AUTH-06 | Token hết hạn → auto refresh       | Integration | P0       |
| AUTH-07 | Logout xoá token                   | Integration | P0       |
| AUTH-08 | Rate limit login (>5 lần/phút)     | Integration | P1       |
| AUTH-09 | Quên mật khẩu → nhận email         | E2E         | P1       |
| AUTH-10 | Reset password với token hợp lệ    | Integration | P1       |

### Story CRUD

| ID       | Test Case                                 | Loại        | Priority |
| -------- | ----------------------------------------- | ----------- | -------- |
| STORY-01 | Tạo truyện với đầy đủ thông tin           | E2E         | P0       |
| STORY-02 | Tạo truyện thiếu title → validation error | Unit        | P0       |
| STORY-03 | Xem danh sách truyện (pagination)         | Integration | P0       |
| STORY-04 | Xem chi tiết truyện                       | E2E         | P0       |
| STORY-05 | Sửa truyện (chỉ author)                   | Integration | P0       |
| STORY-06 | Xoá truyện (confirm dialog)               | E2E         | P1       |
| STORY-07 | Publish/Unpublish truyện                  | Integration | P0       |
| STORY-08 | Search truyện theo title                  | E2E         | P1       |
| STORY-09 | Filter theo genre/tag                     | Integration | P1       |
| STORY-10 | Upload cover image                        | E2E         | P1       |

### Chapter

| ID      | Test Case                         | Loại        | Priority |
| ------- | --------------------------------- | ----------- | -------- |
| CHAP-01 | Tạo chapter mới với Tiptap editor | E2E         | P0       |
| CHAP-02 | Sắp xếp thứ tự chapters           | Integration | P1       |
| CHAP-03 | Đọc chapter (reader view)         | E2E         | P0       |
| CHAP-04 | Lưu reading progress              | Integration | P1       |
| CHAP-05 | Chapter navigation (prev/next)    | E2E         | P0       |

### Interaction

| ID     | Test Case                  | Loại        | Priority |
| ------ | -------------------------- | ----------- | -------- |
| INT-01 | Like/Unlike truyện         | Integration | P1       |
| INT-02 | Bookmark truyện            | Integration | P1       |
| INT-03 | Follow/Unfollow author     | Integration | P1       |
| INT-04 | Comment trên chapter       | E2E         | P1       |
| INT-05 | Reply comment              | Integration | P2       |
| INT-06 | Xoá comment (author/admin) | Integration | P2       |

### UI Components

| ID    | Test Case                   | Loại | Priority |
| ----- | --------------------------- | ---- | -------- |
| UI-01 | Button variants render đúng | Unit | P0       |
| UI-02 | Card compound components    | Unit | P0       |
| UI-03 | Dialog open/close           | Unit | P0       |
| UI-04 | Dark mode toggle            | E2E  | P0       |
| UI-05 | Responsive navbar collapse  | E2E  | P1       |
| UI-06 | Skeleton loading states     | Unit | P1       |
| UI-07 | Form validation display     | Unit | P0       |

---

## 6. Browser Testing Workflow

### Khi nào test trên browser?

Agent sử dụng browser tool khi:

1. Dev server đang chạy (`pnpm dev`)
2. Tính năng mới có UI (không chỉ logic)
3. Cần verify responsive/dark mode
4. User yêu cầu visual verification

### Quy trình browser test

```
1. Đảm bảo dev server chạy (pnpm dev → localhost:3000)
2. Mở browser tool
3. Navigate đến page cần test
4. Kiểm tra:
   ├── Element hiển thị đúng
   ├── Click/interact hoạt động
   ├── Form validation hiển thị
   ├── Responsive (resize window)
   └── Dark mode (toggle + verify)
5. Chụp screenshot/recording nếu cần cho report
```

### Breakpoints cần test

| Device  | Width   | Test                             |
| ------- | ------- | -------------------------------- |
| Mobile  | 375px   | Hamburger menu, stacked layout   |
| Tablet  | 768px   | Grid 2 columns, sidebar collapse |
| Desktop | 1024px+ | Full layout, sidebar visible     |

---

## 7. Test Reporting Format

Sau khi chạy tests, báo cáo theo format:

```markdown
## Kết Quả Test: [Tên Feature]

### Tổng quan

- Unit tests: X/Y passed ✅
- Integration tests: X/Y passed ✅
- E2E tests: X/Y passed ✅
- Coverage: XX%

### Chi tiết

| ID      | Test Case            | Kết quả | Ghi chú              |
| ------- | -------------------- | ------- | -------------------- |
| AUTH-01 | Đăng ký email hợp lệ | ✅ Pass |                      |
| AUTH-02 | Email đã tồn tại     | ✅ Pass |                      |
| AUTH-03 | Đăng nhập thành công | ❌ Fail | Token không lưu đúng |

### Issues phát hiện

1. [AUTH-03] Token không lưu vào zustand store — cần fix `auth.store.ts`
```

---

> **Tài liệu liên quan**: [CHECKLIST-TEMPLATES.md](./CHECKLIST-TEMPLATES.md) · [WORKFLOW-GUIDE.md](./WORKFLOW-GUIDE.md) · [CODING-STANDARDS.md](./CODING-STANDARDS.md)
