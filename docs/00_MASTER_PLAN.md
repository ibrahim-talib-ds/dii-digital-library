# DII Digital Library — Master Plan (v2)

**Decision:** Firebase abandoned. Full-stack Postgres architecture.
**Started:** Oct 14, 2026
**Owner:** Ibrahim Talib (240023018) — DII Capstone

---

## 1. Mission

Real university library app for Dushanbe Innovation Institute.

- Student — browse books, request loans, see own loans + history
- Librarian — approve requests, receive returns, manage books
- Admin — manage users, books, librarians, reports

Login: student number only (auto @dii.tj). No Google/Apple. No email self-signup.

Roles: student | librarian | admin

---

## 2. Why we left Firebase

- Rules system became the bottleneck
- No SQL — hard to write reports, joins, aggregations
- Firestore query limitations
- Debugging was opaque (no server logs)
- Vendor lock-in

Postgres gives us: real SQL, transactions, indexes, views, full-text search, JSON, logs.

---

## 3. Architecture

Flutter Web  →  FastAPI  →  Postgres
(UI, JWT)       (backend)    (data)
                + SSE notifications

### Stack

- Frontend: Flutter Web
- Backend: FastAPI (Python)
- ORM: SQLModel
- Migrations: Alembic
- DB: PostgreSQL 16
- Auth: JWT (access + refresh)
- Password hash: bcrypt
- File uploads: Local disk (dev) / S3 (prod)
- Notifications: DB-backed + SSE
- Container: Docker + docker-compose
- Deploy: Fly.io / Railway

---

## 4. Folder layout

DII_Library_v2/
  docs/
  backend/
    app/
      main.py
      config.py
      database.py
      models/
      schemas/
      routers/
      services/
      auth/
      notifications/
    alembic/
    tests/
    Dockerfile
    pyproject.toml
  frontend/
  docker-compose.yml
  README.md

---

## 5. MVP scope

- Login / signup (student number)
- JWT auth
- Browse books (search, filter, paginate)
- Book details
- Request to borrow
- Librarian approves (custom days)
- Librarian marks returned
- My Books / History
- Profile with avatar
- In-app notifications

### V1

- Admin dashboard + stats
- Reports + CSV export
- Reservations
- Fines on overdue
- Email notifications

---

## 6. Database tables

- users — student_number, name, email, role, password_hash, avatar_url, department, year, status
- books — title, author, isbn, category_id, description, cover_url, pdf_url, total_copies, available_copies
- categories — name, slug, icon, color, sort_order
- borrowings — user_id, book_id, status, requested_at, approved_at, due_at, returned_at, days, approved_by
- notifications — user_id, type, title, body, related_id, read, created_at
- settings — key, value
- audit_log — actor_id, action, entity, entity_id, meta

---

## 7. API endpoints

POST   /auth/signup
POST   /auth/login
POST   /auth/refresh
POST   /auth/logout

GET    /books  ?search=&category=&page=
GET    /books/{id}
POST   /books           (staff)
PATCH  /books/{id}      (staff)
DELETE /books/{id}      (staff)

GET    /categories
POST   /categories      (staff)

POST   /borrowings               (student: request)
GET    /borrowings/mine          (student)
GET    /borrowings               (staff)
POST   /borrowings/{id}/approve  body {days}
POST   /borrowings/{id}/reject
POST   /borrowings/{id}/return

GET    /users
GET    /users/{id}
PATCH  /users/{id}
POST   /users/{id}/block   (admin)

GET    /notifications
POST   /notifications/{id}/read
POST   /notifications/read-all
GET    /notifications/stream     (SSE)

GET    /reports/summary          (staff)

---

## 8. Auth flow

1. Signup: student number + name + password → creates user, returns JWT
2. Login: student number + password → verify bcrypt → return JWT + refresh
3. API: Authorization: Bearer <jwt>
4. Access token 30 min, refresh 30 days
5. Flutter auto-refreshes before expiry

---

## 9. Development environment

docker-compose up

- Backend: http://localhost:8000
- Swagger: http://localhost:8000/docs
- Postgres: localhost:5432
- Flutter: localhost:5050

Env file backend/.env:
DATABASE_URL=postgresql+asyncpg://dii:dii@localhost:5432/dii_library
JWT_SECRET=random-32-bytes
ACCESS_TOKEN_EXPIRE_MINUTES=30
REFRESH_TOKEN_EXPIRE_DAYS=30
UPLOAD_DIR=./uploads

---

## 10. Ground rules

1. No guessing. Every problem starts with the error message.
2. Schema first, code second.
3. One endpoint at a time. Test with curl/Swagger.
4. One script per task.
5. Commit after every working step.
6. No vendor code in Flutter. It talks to our API only.
7. Local dev must work offline.

---

## 11. Next steps

1. DONE — Create folder + master plan
2. TODO — Write 01_DATABASE_SCHEMA.md
3. TODO — Write 02_API_ENDPOINTS.md
4. TODO — Write 03_AUTH_FLOW.md
5. TODO — Write 04_FRONTEND_STRUCTURE.md
6. TODO — Write 05_NOTIFICATIONS.md
7. TODO — docker-compose.yml + FastAPI skeleton
8. TODO — Alembic migrations
9. TODO — Auth endpoints
10. TODO — Books CRUD
11. TODO — Borrowings flow
12. TODO — Notifications
13. TODO — Flutter data layer
14. TODO — Test end-to-end
15. TODO — Deploy

---

END OF MASTER PLAN
