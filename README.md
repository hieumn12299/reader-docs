# 📚 Reader Docs — Shared Documentation

> Tài liệu chung cho cả **Frontend** (`fe-reader`) và **Backend** (`be-reader`).

## Cách sử dụng

Repo này được thêm dưới dạng **git submodule** vào cả `fe-reader` và `be-reader` tại đường dẫn `.document/`.

```bash
# Trong fe-reader hoặc be-reader
git submodule update --init --recursive
```

## Cấu trúc

| File                     | Nội dung                                                    |
| ------------------------ | ----------------------------------------------------------- |
| `ARCHITECTURE.md`        | Kiến trúc tổng thể, tech stack, DB schema                   |
| `CODING-STANDARDS.md`    | Quy tắc code chung (TypeScript, naming, no any)             |
| `FOLDER-STRUCTURE.md`    | Cấu trúc thư mục FE + BE                                    |
| `WORKFLOW-GUIDE.md`      | Quy trình 5 phases cho mọi task                             |
| `CHECKLIST-TEMPLATES.md` | Templates checklist (pre-code, post-code, deploy, security) |
| `TESTING-GUIDE.md`       | Testing strategy, test case templates                       |
| `API-REFERENCE.md`       | BE API endpoints, request/response formats, enums           |
| `DATABASE-SETUP.md`      | Setup MySQL Docker + MySQL Workbench + Prisma               |
| `PLAN-story-platform.md` | Master roadmap                                              |

## Project-specific docs

- **FE** → `fe-reader/.fe-document/REUSABLE-COMPONENTS.md`
- **BE** → `be-reader/.be-document/REUSABLE-MODULES.md`

## Quy tắc cập nhật

1. Sửa file trong bất kỳ project nào (fe-reader hoặc be-reader)
2. Commit + push **trong `.document/` (submodule)** trước
3. Commit + push ở project chính sau
4. Qua project còn lại → `git submodule update --remote`
