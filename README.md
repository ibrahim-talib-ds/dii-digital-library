<div align="center">

<img src="https://raw.githubusercontent.com/ibrahim-talib-ds/dii-digital-library/main/frontend/assets/images/dii_logo.png" alt="DII Library" width="140" />

# DII Digital Library

### A modern full-stack library management system for Dushanbe Innovation Institute

Browse, request, and manage books — for students, librarians, and admins.

<br />

[![FastAPI](https://img.shields.io/badge/FastAPI-0.115-009688?style=for-the-badge&logo=fastapi&logoColor=white)](https://fastapi.tiangolo.com)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-17-4169E1?style=for-the-badge&logo=postgresql&logoColor=white)](https://www.postgresql.org)
[![Flutter](https://img.shields.io/badge/Flutter-3.47-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Python](https://img.shields.io/badge/Python-3.12-3776AB?style=for-the-badge&logo=python&logoColor=white)](https://www.python.org)

[![License: MIT](https://img.shields.io/badge/License-MIT-FFC107?style=for-the-badge)](LICENSE)
[![Status](https://img.shields.io/badge/Status-Active-10B981?style=for-the-badge)]()

<br />

[Features](#-features) · [Architecture](#-architecture) · [Quick Start](#-quick-start) · [API](#-api-reference) · [Team](#-team)

</div>

---

## 📖 Overview

**DII Digital Library** replaces a paper-based workflow at Dushanbe Innovation Institute with a modern, responsive web application. Students browse and request books from a curated catalogue; librarians manage inventory and approve requests in real-time; admins oversee users, roles, and analytics.

The system is built around **three principles**:

- 🎯 **Simplicity** — students log in with a student number only, no email required
- ⚡ **Real-time** — notifications, chat, and inventory updates sync instantly across clients
- 🎨 **Design first** — a disciplined 3-color palette, responsive layouts, and a clean UX across mobile, tablet, and desktop

---

## ✨ Features

### 🎓 For Students

| Feature | Description |
|---|---|
| **Passwordless onboarding** | Login with your student number — the system auto-maps to `@dii.tj` |
| **3-step signup** | Enter number → confirm identity → set password |
| **Browse by category** | 6 categories with live book counts |
| **Advanced search** | Filter by title, author, book code, or availability |
| **Request physical copies** | Librarians get notified instantly |
| **Read PDFs in-app** | Zoom, page navigation, dark mode |
| **Save books** | Personal bookmark list |
| **Loan tracking** | Active loans, due dates, overdue warnings |
| **Real-time notifications** | Bell badge updates via SSE |
| **Chat with librarian** | Reply to messages about specific requests |

### 👨‍🏫 For Librarians

- **Approve or reject requests** — with custom loan duration (1–90 days)
- **Message students** — in-app conversations tied to books
- **Manage inventory** — add, edit, soft-delete with full metadata
- **Receive returns** — inventory updates automatically
- **View student profiles** — full borrow history at a glance
- **Block / unblock students** — with one-click toggle

### 👨‍💼 For Admins

- **Complete user management** — filter by role, block, unblock
- **Reports dashboard** — books, users, active loans, overdue, popular titles
- **Roster management** — bulk pre-register students for signup
- **Librarian self-signup** — staff can register with their own credentials

### 🤖 AI Assistant — Ibro_Ai

Powered by **Groq + Llama 3.3 70B**, available on every page via a floating button.

- Answers library questions in natural language
- Explains borrowing rules and availability
- Suggests books by topic
- Persists conversation history per user

---

## 🏗️ Architecture


### 🧰 Tech Stack

| Layer | Technology | Purpose |
|---|---|---|
| **Frontend** | Flutter 3.47 Web | Single codebase for web + Android |
| **State** | Provider + ChangeNotifier | Simple, low-ceremony state management |
| **Routing** | go_router 18 | Declarative navigation with auth guards |
| **Backend** | FastAPI 0.115 | Async, typed, self-documenting |
| **ORM** | SQLModel | SQLAlchemy + Pydantic in one class |
| **Migrations** | Alembic | Version-controlled schema |
| **Database** | PostgreSQL 17 | Real SQL with joins, indexes, triggers |
| **Auth** | JWT (access + refresh) | Stateless, web-safe |
| **Passwords** | bcrypt (12 rounds) | Industry standard |
| **Notifications** | Server-Sent Events | Real-time without polling |
| **AI** | Groq + Llama 3.3 70B | Free tier, blazing fast |
| **Deploy** | Fly.io + GitHub Pages | 100% free tier |

---

## 📁 Project Structure


---

## 🚀 Quick Start

### Prerequisites

- **Python** 3.12 or newer
- **PostgreSQL** 17
- **Flutter** 3.47 or newer
- *(Optional)* **Groq API key** — [get one free](https://console.groq.com/keys)

### 1. Clone the repository

```bash
git clone https://github.com/ibrahim-talib-ds/dii-digital-library.git
cd dii-digital-library

Terminal 1

cd ~/Projects/DII_Library_v2/backend && source .venv/bin/activate && uvicorn app.main:app --host 0.0.0.0 --port 8002

Terminal 2

cd ~/Projects/DII_Library_v2/frontend/build/web && python3 -m http.server 8080 --bind 0.0.0.0
