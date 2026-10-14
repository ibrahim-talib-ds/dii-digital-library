# DII Digital Library — Database Schema

**Database:** PostgreSQL 16
**ORM:** SQLModel (SQLAlchemy + Pydantic)
**Migrations:** Alembic

## Design principles
1. Every table has id UUID PRIMARY KEY DEFAULT gen_random_uuid()
2. Every table has created_at, updated_at (timestamptz)
3. Soft delete for users/books via deleted_at
4. Enums as Postgres types
5. FK ON DELETE: RESTRICT for critical, CASCADE for orphans
6. snake_case, plural tables
7. Every FK column has an index

## Enums
CREATE TYPE user_role   AS ENUM ('student', 'librarian', 'admin');
CREATE TYPE user_status AS ENUM ('active', 'blocked');
CREATE TYPE borrow_status AS ENUM ('pending','approved','rejected','returned','overdue','cancelled');
CREATE TYPE notification_type AS ENUM ('request','approved','rejected','returned','overdue','info');

## users
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_number VARCHAR(20) UNIQUE NOT NULL,
  email VARCHAR(120) UNIQUE NOT NULL,
  name VARCHAR(120) NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  role user_role NOT NULL DEFAULT 'student',
  status user_status NOT NULL DEFAULT 'active',
  department VARCHAR(120),
  year SMALLINT CHECK (year BETWEEN 1 AND 6),
  phone VARCHAR(30),
  avatar_url TEXT,
  borrow_limit SMALLINT NOT NULL DEFAULT 3,
  last_login_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at TIMESTAMPTZ
);
CREATE INDEX idx_users_role   ON users (role)   WHERE deleted_at IS NULL;
CREATE INDEX idx_users_status ON users (status) WHERE deleted_at IS NULL;

## categories
CREATE TABLE categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  slug VARCHAR(60) UNIQUE NOT NULL,
  name VARCHAR(120) NOT NULL,
  description TEXT,
  icon VARCHAR(60),
  color VARCHAR(9),
  image_url TEXT,
  sort_order SMALLINT NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

## books
CREATE TABLE books (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  category_id UUID REFERENCES categories(id) ON DELETE RESTRICT,
  title VARCHAR(300) NOT NULL,
  author VARCHAR(200) NOT NULL,
  book_code VARCHAR(50) UNIQUE,
  isbn VARCHAR(20),
  description TEXT,
  cover_url TEXT,
  pdf_url TEXT,
  pages INTEGER,
  language VARCHAR(20) DEFAULT 'en',
  total_copies INTEGER NOT NULL DEFAULT 1 CHECK (total_copies >= 0),
  available_copies INTEGER NOT NULL DEFAULT 1 CHECK (available_copies >= 0),
  added_by UUID REFERENCES users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at TIMESTAMPTZ,
  search_vector tsvector
);
CREATE INDEX idx_books_category ON books (category_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_books_fts ON books USING GIN (search_vector);

## borrowings
CREATE TABLE borrowings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
  book_id UUID NOT NULL REFERENCES books(id) ON DELETE RESTRICT,
  status borrow_status NOT NULL DEFAULT 'pending',
  days SMALLINT NOT NULL DEFAULT 14 CHECK (days BETWEEN 1 AND 90),
  notes TEXT,
  requested_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  approved_at TIMESTAMPTZ,
  approved_by UUID REFERENCES users(id) ON DELETE SET NULL,
  rejected_at TIMESTAMPTZ,
  rejected_by UUID REFERENCES users(id) ON DELETE SET NULL,
  due_at TIMESTAMPTZ,
  returned_at TIMESTAMPTZ,
  received_by UUID REFERENCES users(id) ON DELETE SET NULL,
  fine NUMERIC(10,2) NOT NULL DEFAULT 0.00,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_borrowings_user ON borrowings (user_id, status);
CREATE INDEX idx_borrowings_status ON borrowings (status, requested_at DESC);
CREATE UNIQUE INDEX uniq_active_loan ON borrowings (user_id, book_id)
  WHERE status IN ('pending','approved','overdue');

## notifications
CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  type notification_type NOT NULL DEFAULT 'info',
  title VARCHAR(200) NOT NULL,
  body TEXT NOT NULL,
  related_id UUID,
  related_type VARCHAR(40),
  read BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_notif_user_unread ON notifications (user_id, read, created_at DESC);

## settings
CREATE TABLE settings (
  key VARCHAR(60) PRIMARY KEY,
  value JSONB NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

## audit_log
CREATE TABLE audit_log (
  id BIGSERIAL PRIMARY KEY,
  actor_id UUID REFERENCES users(id) ON DELETE SET NULL,
  action VARCHAR(60) NOT NULL,
  entity VARCHAR(60) NOT NULL,
  entity_id UUID,
  meta JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

## refresh_tokens
CREATE TABLE refresh_tokens (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  token_hash VARCHAR(255) NOT NULL UNIQUE,
  expires_at TIMESTAMPTZ NOT NULL,
  revoked_at TIMESTAMPTZ,
  user_agent VARCHAR(200),
  ip INET,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_refresh_user ON refresh_tokens (user_id) WHERE revoked_at IS NULL;

## Triggers
CREATE FUNCTION set_updated_at() RETURNS trigger AS $$
BEGIN NEW.updated_at = now(); RETURN NEW; END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION sync_available_copies() RETURNS trigger AS $$
BEGIN
  IF (OLD.status = 'pending' AND NEW.status IN ('approved','overdue')) THEN
    UPDATE books SET available_copies = available_copies - 1 WHERE id = NEW.book_id;
  ELSIF (OLD.status IN ('approved','overdue') AND NEW.status = 'returned') THEN
    UPDATE books SET available_copies = available_copies + 1 WHERE id = NEW.book_id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

## Row-level access: enforced in FastAPI, not Postgres.
