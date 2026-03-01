# 🐳 Database Setup Guide

> Hướng dẫn setup MySQL bằng Docker và kiểm tra data bằng Prisma Studio.

---

## Yêu cầu

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (Windows/macOS)
- Node.js ≥ 18 + pnpm

---

## 1. Khởi động MySQL bằng Docker

```bash
cd be-reader
docker compose up -d
```

Kiểm tra container đang chạy:

```bash
docker ps
# Expect: be-reader-mysql  mysql:8.0  0.0.0.0:3306->3306/tcp
```

### Thông tin kết nối

| Config         | Value                                                      |
| -------------- | ---------------------------------------------------------- |
| Host           | `localhost`                                                |
| Port           | `3306`                                                     |
| Database       | `be_reader`                                                |
| Username       | `reader_user`                                              |
| Password       | `reader_pass`                                              |
| Root Password  | `root_password`                                            |
| Connection URL | `mysql://reader_user:reader_pass@localhost:3306/be_reader` |

---

## 2. Setup Prisma & Migrate

```bash
cd be-reader

# Copy env file (nếu chưa có)
cp .env.example .env

# Generate Prisma Client
pnpm db:generate

# Chạy migration
pnpm db:migrate

# Seed data mẫu
pnpm db:seed
```

Sau khi seed thành công sẽ có:

- 3 users (admin, author, reader)
- 5 genres + 5 tags
- 8 stories với chapters

---

## 3. Xem data bằng Prisma Studio

Prisma Studio là web UI tích hợp sẵn, không cần cài thêm tool:

```bash
cd be-reader
pnpm db:studio
# Mở browser tại http://localhost:5555
```

### Các tính năng:

- **Xem data**: Click vào bất kỳ model nào (User, Story, Chapter...) để xem records
- **Filter & Sort**: Filter theo field, sort tăng/giảm
- **Edit trực tiếp**: Click vào cell để sửa data, nhấn Save
- **Xem relations**: Click vào field relation để xem data liên kết
- **Thêm record**: Nút "Add record" để thêm data mới

### Models có data sau khi seed:

| Model   | Records | Mô tả                                           |
| ------- | ------- | ----------------------------------------------- |
| User    | 3       | admin, author, reader                           |
| Genre   | 5       | Fantasy, Romance, Horror, Sci-Fi, Slice of Life |
| Tag     | 5       | Trending, New, Complete, Hot, Featured          |
| Story   | 8       | Các truyện mẫu                                  |
| Chapter | 14      | Các chương truyện                               |

---

## 4. MySQL Workbench (tùy chọn)

Nếu cần chạy SQL query phức tạp, cài [MySQL Workbench](https://dev.mysql.com/downloads/workbench/) và kết nối:

| Field    | Value         |
| -------- | ------------- |
| Hostname | `127.0.0.1`   |
| Port     | `3306`        |
| Username | `reader_user` |
| Password | `reader_pass` |

---

## 5. Lệnh thường dùng

```bash
# Docker
docker compose up -d          # Start MySQL
docker compose down            # Stop MySQL
docker compose down -v         # Stop + xoá data
docker compose logs mysql      # Xem logs

# Prisma
pnpm db:generate               # Generate Prisma Client
pnpm db:migrate                # Chạy migrations
pnpm db:seed                   # Seed data mẫu
pnpm db:studio                 # Mở Prisma Studio (web UI)
```

---

## 6. Troubleshooting

### Port 3306 đã bị chiếm

```bash
# Kiểm tra process nào đang dùng port 3306
# Windows:
netstat -ano | findstr :3306

# macOS/Linux:
lsof -i :3306
```

Giải pháp: Tắt MySQL local hoặc đổi port trong `docker-compose.yml`:

```yaml
ports:
  - "3307:3306" # Đổi sang 3307
```

> ⚠️ Nhớ cập nhật `DATABASE_URL` trong `.env` nếu đổi port.

### Lỗi "Access denied"

Kiểm tra lại `.env`:

```
DATABASE_URL="mysql://reader_user:reader_pass@localhost:3306/be_reader"
```

### Lỗi "Access denied" khi migrate (shadow database)

Prisma cần tạo shadow database tạm khi migrate. Fix bằng cách grant quyền:

```bash
docker exec be-reader-mysql mysql -uroot -proot_password \
  -e "GRANT ALL PRIVILEGES ON *.* TO 'reader_user'@'%'; FLUSH PRIVILEGES;"
```

### Reset toàn bộ database

```bash
docker compose down -v         # Xoá volume
docker compose up -d           # Start lại
pnpm db:migrate                # Migrate
pnpm db:seed                   # Seed data
```
