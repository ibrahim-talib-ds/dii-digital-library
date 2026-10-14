# DII Digital Library v2 — Progress Log

**Project root:** ~/Projects/DII_Library_v2
**Backend:** FastAPI on port 8002
**Frontend:** Flutter Web on port 5050
**Postgres:** localhost:5432 · db=dii_library · user=ibrahim · password=1542004ibrahim
**Last updated:** Oct 14, 2026

---

## OVERALL STATUS

Backend: 100% complete. 32 endpoints, all tested.
Frontend: ~90% complete. All pages built, flutter analyze clean.

Next: end-to-end test, polish, deploy.

---

## TEST ACCOUNTS

| Role | Student # | Password |
|---|---|---|
| Admin | 240023018 | 1542004ibrahim |
| Student | 240023001 | test1234 |

Admin name: Ibrahim Talib

---

## BACKEND (FastAPI on 8002)

Files under backend/app/:
- config.py       — pydantic-settings from .env
- database.py     — SQLModel engine + get_session
- models/         — 8 SQLModel classes + enums
- schemas/        — 7 Pydantic schemas
- auth/           — password (bcrypt), tokens (JWT), deps (CurrentUser/StaffUser/AdminUser)
- routers/        — 7 routers: auth, categories, books, borrowings, notifications, users, reports
- main.py         — FastAPI app, CORS, all routers

Endpoints (all verified with curl):

Auth
- POST /auth/signup, /auth/login, /auth/refresh, /auth/logout

Categories
- GET /categories, GET /categories/{id}
- POST /categories (staff), PATCH /categories/{id} (staff), DELETE /categories/{id} (admin)

Books
- GET /books (search, category, available, page, size)
- GET /books/{id}
- POST /books (staff) — available_copies = total_copies
- PATCH /books/{id} (staff) — adjusts available_copies on total change
- DELETE /books/{id} (admin, soft delete)

Borrowings
- POST /borrowings (student) — creates pending + notifies staff
- GET /borrowings/mine (student)
- GET /borrowings (staff, filter by status)
- POST /borrowings/{id}/approve (staff, body {days}) — due_at, avail-1, notify
- POST /borrowings/{id}/reject (staff) — notify
- POST /borrowings/{id}/return (staff) — avail+1, notify

Notifications
- GET /notifications
- POST /notifications/{id}/read, POST /notifications/read-all
- GET /notifications/stream — SSE with unread count

Users
- GET /users (staff)
- GET /users/{id} (self or staff)
- PATCH /users/{id} (self or admin)
- POST /users/{id}/block (admin), /unblock (admin)

Reports
- GET /reports/summary, /reports/overdue, /reports/popular

---

## DATABASE (PostgreSQL 17.6)

- 8 tables via Alembic migration a17a93e28fee
- Enums: user_role, user_status, borrow_status, notification_type
- Triggers: set_updated_at on users/books/categories/borrowings
- Seeded: 6 categories, 10 settings

---

## FRONTEND (Flutter Web on 5050)

Files under frontend/lib/:
- core/            — colors, theme, config, constants, breakpoints, result
- data/api/        — api_client (auto-refresh JWT), api_exception, token_store
- data/models/     — 8 typed models
- data/repositories/ — 7 repos
- state/           — auth_state, notifications_state (SSE)
- ui/layout/       — responsive_shell, app_sidebar, app_bottom_nav
- ui/components/   — book_card, borrowing_card, user_avatar, notification_bell
- ui/pages/        — all feature pages
- router/          — go_router config with auth guards

Pages built:
- SplashPage
- LoginPage (student number + password)
- SignupPage
- HomePage (hero, stats, category grid, book sections)
- BrowsePage (search, category chips, availability filter, pagination)
- BookDetailsPage (cover, meta, request button)
- MyBooksPage (active + pending)
- HistoryPage (returned + rejected)
- ProfilePage (view/edit self, sign out)
- librarian/BorrowRequestsPage (approve with days dialog, reject)
- librarian/ReceiveReturnPage (mark returned)
- librarian/ManageBooksPage (add/edit/delete + editor dialog)
- librarian/StudentsPage (list + history sheet + block/unblock)
- admin/ManageUsersPage (all users, role filters, block/unblock)
- admin/ManageLibrariansPage
- admin/ReportsPage (8 stat cards + popular + overdue)
- components/NotificationBell (bell + badge + dropdown + SSE live updates)

---

## NOTIFICATIONS — CONFIRMED WORKING

| Event | Recipient | Status |
|---|---|---|
| Student requests | Every librarian + admin | ✅ |
| Approve | Student | ✅ |
| Reject | Student | ✅ |
| Return | Student | ✅ |

Real-time badge via SSE (Server-Sent Events).

This was the exact feature that failed in the Firebase version.

---

## DESIGN SYSTEM — 3-COLOR PALETTE

- White    — surfaces, cards
- Blue     #0A1E5C — primary brand
- Yellow   #FFC107 — accent only
- Red      #B3261E — ONLY for OUT/OVERDUE/danger

Legacy names (green, purple, cyan) alias to blue.
Categories alternate blue/yellow.
Hover lift on cards, staggered fade-in animations.

---

## TEST DATA

3 books in Computer Science with real Open Library covers:
- CS-001 Clean Code (5 copies)
- CS-002 The Pragmatic Programmer (2 copies)
- CS-003 Introduction to Algorithms (5 copies)

---

## IMMEDIATE NEXT

1. Full end-to-end test pass
   - Login as admin → check every page
   - Add/edit/delete a book
   - Signup new student
   - Student requests → admin approves with days → admin marks returned
   - Confirm notifications fire everywhere
   - Block / unblock a student

2. Polish
   - Check hero on phone widths
   - Empty / loading / error states
   - Build APK, test on Android phone

3. Deploy
   - Backend → Fly.io / Railway
   - DB → Neon or Fly Postgres
   - Frontend → GitHub Pages or Fly static

---

## ENVIRONMENT QUIRKS

1. Postgres 17.6 compiled from source at ~/Databases/postgresql-build
   - system pg 16 cluster exists but DOWN — ignore it

2. Terminal truncation
   - Long heredocs get cut when pasting
   - Use Python-writer method for files over ~40 lines

3. datetime defaults
   - Use datetime.now(timezone.utc), not datetime.utcnow

4. Alembic autogenerate
   - Add `import sqlmodel` after `from alembic import op`

5. passlib + bcrypt 4.x
   - Use bcrypt directly (backend/app/auth/password.py)

6. google_fonts
   - Pin to 6.3.3 (9.0.0 pulls in a broken material_ui package)

7. DWDS Chrome debug
   - `flutter run -d chrome` often times out
   - Use `flutter run -d web-server --web-port=5050` instead

8. Ports in use
   - 8000 ZanNext, 8001 DII Suggestion, 5050 Flutter, 8002 THIS BACKEND

---

## RUN COMMANDS

Backend:
  cd ~/Projects/DII_Library_v2/backend
  source .venv/bin/activate
  uvicorn app.main:app --reload --port 8002
  → Swagger at http://localhost:8002/docs

Frontend:
  cd ~/Projects/DII_Library_v2/frontend
  flutter run -d web-server --web-port=5050
  → http://localhost:5050

Reset admin password:
  python3 -c "import bcrypt,psycopg; pw=bcrypt.hashpw(b'1542004ibrahim', bcrypt.gensalt(12)).decode(); c=psycopg.connect('postgresql://ibrahim:1542004ibrahim@localhost:5432/dii_library', autocommit=True); c.cursor().execute('UPDATE users SET password_hash=%s WHERE student_number=%s',(pw,'240023018')); print('done')"

---

END OF PROGRESS LOG
