# DII Digital Library — API Endpoints

Base URL dev: http://localhost:8000
Base URL prod: https://api.dii.tj
Content-Type: application/json
Auth: Authorization: Bearer <access_token>

## Auth

POST /auth/signup
  body: {student_number, name, password, department?, year?}
  out:  {user, access_token, refresh_token}

POST /auth/login
  body: {student_number, password}
  out:  {user, access_token, refresh_token}

POST /auth/refresh
  body: {refresh_token}
  out:  {access_token, refresh_token}

POST /auth/logout
  body: {refresh_token}
  out:  {ok: true}

## Books

GET /books?search=&category=&page=1&size=20
  out: {items:[Book], total, page, size}

GET /books/{id}
  out: Book

POST /books               (staff)
  body: {title, author, category_id, book_code?, isbn?, description?, cover_url?, pdf_url?, pages?, total_copies}
  out: Book

PATCH /books/{id}         (staff)
  body: partial Book
  out: Book

DELETE /books/{id}        (staff, soft delete)
  out: {ok:true}

## Categories

GET /categories
  out: [Category]

POST /categories          (staff)
  body: {slug, name, description?, icon?, color?, sort_order?}
  out: Category

PATCH /categories/{id}    (staff)
DELETE /categories/{id}   (staff)

## Borrowings

POST /borrowings                (student)
  body: {book_id}
  out: Borrowing (status=pending)
  Side: inserts N notifications for staff.

GET /borrowings/mine            (student)
  out: [Borrowing]

GET /borrowings                 (staff, filters: status?, user_id?, overdue?)
  out: [Borrowing]

POST /borrowings/{id}/approve   (staff)
  body: {days}      (1..90)
  out: Borrowing (status=approved, due_at=now+days)
  Side: notifies student.

POST /borrowings/{id}/reject    (staff)
  out: Borrowing (status=rejected)
  Side: notifies student.

POST /borrowings/{id}/return    (staff)
  out: Borrowing (status=returned)
  Side: notifies student.

## Users

GET /users                      (staff)
GET /users/{id}                 (self or staff)
PATCH /users/{id}               (self or admin)
POST /users/{id}/block          (admin)
POST /users/{id}/unblock        (admin)

## Notifications

GET /notifications              (own)
POST /notifications/{id}/read   (own)
POST /notifications/read-all    (own)
GET /notifications/stream       (own, SSE)

## Reports

GET /reports/summary            (staff)
  out: {total_books, total_users, active_loans, overdue_loans}

GET /reports/overdue            (staff)
GET /reports/popular            (staff)

## Errors

400 invalid input
401 missing/invalid token
403 forbidden (wrong role)
404 not found
409 conflict (duplicate, book unavailable)
500 server error

Shape: {"detail": "message"}
