# DII Digital Library — Auth Flow

## Login identifier
Student number only (e.g. 240023001). Email auto-derived: <number>@dii.tj.

## Signup
POST /auth/signup  {student_number, name, password, department?, year?}
Backend:
  1. Validate student_number format (6-12 digits)
  2. email = student_number + '@dii.tj'
  3. hash = bcrypt(password)
  4. borrow_limit per role (student=3)
  5. Insert users row
  6. Issue tokens
Response: {user, access_token, refresh_token}

## Login
POST /auth/login  {student_number, password}
Backend:
  1. Find user by student_number (deleted_at IS NULL)
  2. Check status == 'active' else 403
  3. Verify bcrypt
  4. Update last_login_at
  5. Issue tokens
Response: same as signup

## Tokens
Access token:
  - JWT HS256, signed with JWT_SECRET
  - claims: sub=user_id, role, exp=now+30min
  - Sent as Authorization: Bearer <token>

Refresh token:
  - Random 64-char URL-safe string
  - Stored hashed (SHA-256) in refresh_tokens table
  - expires_at = now + 30 days
  - Rotated on every /auth/refresh call (old one revoked)

## Refresh
POST /auth/refresh  {refresh_token}
Backend:
  1. Hash token, find row
  2. Check not revoked, not expired
  3. Revoke old
  4. Issue new access + new refresh
  5. Return

## Logout
POST /auth/logout  {refresh_token}
Backend: set revoked_at = now() on that token.

## Middleware (FastAPI)
def current_user(token = Depends(oauth2_scheme)):
    payload = jwt.decode(token, JWT_SECRET, algorithms=['HS256'])
    user = db.get(User, payload['sub'])
    if not user or user.deleted_at or user.status != 'active':
        raise HTTPException(401)
    return user

def require_role(*roles):
    def dep(user = Depends(current_user)):
        if user.role not in roles:
            raise HTTPException(403)
        return user
    return dep

## Flutter side
- Store access + refresh in shared_preferences (mobile) or memory + httpOnly cookie (web better)
- Before each request, if access exp < now+60s, refresh first
- On 401 → try refresh once, retry; if refresh fails → logout and go to /login
- On logout → call POST /auth/logout with refresh, clear storage

## Security notes
- Password min length 8
- bcrypt cost factor 12
- JWT_SECRET: 32 random bytes, base64, in .env (never commit)
- Refresh tokens hashed, never stored plaintext
- Rate limit /auth/login: 10/minute per IP
- CORS: allow only the frontend origin
