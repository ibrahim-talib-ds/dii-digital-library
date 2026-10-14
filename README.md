# DII Digital Library

A modern full-stack library management system for Dushanbe Innovation Institute.

**Browse, request, and manage books — for students, librarians, and admins.**

---

## Features

### For Students
- Login with student number only (auto-maps to @dii.tj)
- Browse by category — CS, AI, Biotech, Data Science, Business, Math
- Live search by title, author, or book code
- Request physical copies — librarian notified instantly
- Read PDFs in-app with zoom + page navigation
- Save books for later
- Track loans and history with overdue warnings
- Real-time notifications

### For Librarians
- Approve or reject requests with custom loan duration (1–90 days)
- Message students in-app
- Manage inventory (add / edit / soft-delete)
- Receive returns with auto-inventory update
- View student profiles with full borrow history
- Block / unblock students

### For Admins
- Complete user management
- Reports dashboard — books, users, loans, overdue, popular
- Roster management for pre-registered students
- Librarian self-signup

### AI Assistant — Ibro_Ai
- Powered by Groq + Llama 3.3 70B
- Answers library questions, explains rules
- Floating button on every page
- Conversation history persisted

---

## Architecture

Flutter Web  ->  FastAPI  ->  PostgreSQL
(student UI)    (backend)    (data)
                + SSE
                + Groq AI

### Tech Stack

| Layer | Technology |
|---|---|
| Frontend | Flutter 3.47 Web |
| State | Provider + ChangeNotifier |
| Routing | go_router 18 |
| Backend | FastAPI 0.115 |
| ORM | SQLModel |
| Migrations | Alembic |
| Database | PostgreSQL 17 |
| Auth | JWT (access + refresh) |
| Password | bcrypt (12 rounds) |
| Notifications | Server-Sent Events |
| AI | Groq + Llama 3.3 70B |
| Deploy | Fly.io + GitHub Pages |

---

## Project Structure

DII_Library_v2/
  backend/              FastAPI application
    app/
      main.py
      config.py
      database.py
      models/           10 SQLModel tables
      schemas/          Pydantic
      routers/          8 API routers
      auth/             JWT, bcrypt
    alembic/            Migrations
    pyproject.toml
  frontend/             Flutter Web app
    lib/
      core/
      data/
      state/
      ui/
      router/
    pubspec.yaml
  docs/                 Architecture + plans
  README.md

---

## Quick Start

### Prerequisites
- Python 3.12+
- PostgreSQL 17
- Flutter 3.47+

### 1. Clone
git clone https://github.com/YOUR-USERNAME/dii-digital-library.git
cd dii-digital-library

### 2. Backend
cd backend
python3 -m venv .venv
source .venv/bin/activate
pip install -e .
cp .env.example .env

Then edit .env: DATABASE_URL + JWT_SECRET + GROQ_API_KEY

Create the database:
createdb dii_library
alembic upgrade head

Run:
uvicorn app.main:app --port 8002

- API: http://localhost:8002
- Swagger: http://localhost:8002/docs

### 3. Frontend
cd frontend
flutter pub get
flutter run -d web-server --web-port=5050

Open http://localhost:5050

### 4. Test accounts

| Role | Student # | Password |
|---|---|---|
| Admin | 240023018 | 1542004ibrahim |
| Student | 240023001 | test1234 |

---

## API Reference

See docs/02_API_ENDPOINTS.md for the full list.

| Area | Endpoints |
|---|---|
| Auth | signup, login, refresh, logout, librarian-signup, roster lookup |
| Books | CRUD, search, filters, saved list |
| Categories | CRUD |
| Borrowings | request, approve, reject, return |
| Notifications | list, mark read, SSE stream |
| Messages | inbox, thread, send |
| Users | list, filter, block, unblock, message |
| Reports | summary, overdue, popular |
| AI | POST /ai/chat (Ibro_Ai) |

Live docs: http://localhost:8002/docs

---

## Design System

Strict 3-color palette.

| Color | Hex | Usage |
|---|---|---|
| Dark Blue | #0A1E5C | Primary |
| Deep Blue | #061436 | Gradients |
| Yellow | #FFC107 | Accent |
| White | #FFFFFF | Surfaces |
| Danger Red | #B3261E | Overdue only |

Typography: Inter + InterTight
Breakpoints: Phone <600, Tablet 600-1024, Desktop >=1024

---

## Testing

Backend end-to-end test (25 checks):
python3 /tmp/test_student_librarian.py

Frontend type check:
cd frontend && flutter analyze lib/

---

## Roadmap

### Done
- JWT auth with refresh
- Role-based access (student / librarian / admin)
- Full borrow lifecycle
- In-app messaging
- Real-time notifications (SSE)
- PDF reader with controls
- Saved books
- AI assistant (Ibro_Ai)
- Responsive design

### Planned
- Deploy to Fly.io
- GitHub Pages hosting
- Email notifications
- Book reviews
- QR code scanner
- Mobile APK build

---

## Team

| Name | Student # | Role |
|---|---|---|
| **Ibrahim Talib Khatib** | 240023018 | Full-stack, Backend, AI |
| **Muhammadjon Khakimov** | 240023015 | Flutter UI |
| **Muhammadyusuf Bozorov** | 240023010 | Backend + Database |

---

## License

MIT (c) 2026 Dushanbe Innovation Institute

