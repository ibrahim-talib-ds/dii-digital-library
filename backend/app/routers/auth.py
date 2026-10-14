import uuid
from datetime import datetime, timezone
from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel, Field
from sqlmodel import Session, select

from app.database import get_session
from app.models import User, RefreshToken, StudentRoster
from app.models.enums import UserRole, UserStatus
from app.schemas import SignupIn, LoginIn, TokenOut, UserOut
from app.schemas.auth import RefreshIn, LogoutIn
from app.auth.password import hash_password, verify_password
from app.auth.tokens import (
    create_access_token,
    generate_refresh_token,
    hash_refresh_token,
    refresh_expiry,
)
from app.auth.deps import CurrentUser


router = APIRouter(prefix="/auth", tags=["auth"])

DEFAULT_LIMITS = {
    UserRole.student: 3,
    UserRole.librarian: 5,
    UserRole.admin: 10,
}


def _issue_tokens(session: Session, user: User) -> TokenOut:
    access = create_access_token(user.id, user.role.value)
    raw_refresh = generate_refresh_token()
    rt = RefreshToken(
        user_id=user.id,
        token_hash=hash_refresh_token(raw_refresh),
        expires_at=refresh_expiry(),
    )
    session.add(rt)
    session.commit()
    return TokenOut(
        access_token=access,
        refresh_token=raw_refresh,
        user=UserOut.model_validate(user),
    )


# ═══════════════════════════════════════════════════════════════
# GET /auth/roster/{student_number} — lookup student info
# ═══════════════════════════════════════════════════════════════
@router.get("/roster/{student_number}")
def lookup_roster(
    student_number: str,
    session: Annotated[Session, Depends(get_session)],
):
    row = session.get(StudentRoster, student_number)
    if not row:
        raise HTTPException(
            status.HTTP_404_NOT_FOUND,
            "Student number not found. Ask the librarian to register you.",
        )

    # Also check if they've already created an account
    exists = session.exec(
        select(User).where(User.student_number == student_number)
    ).first()

    return {
        "student_number": row.student_number,
        "name": row.name,
        "email": row.email,
        "department": row.department,
        "year": row.year,
        "has_account": exists is not None,
    }


# ═══════════════════════════════════════════════════════════════
# POST /auth/signup
# ═══════════════════════════════════════════════════════════════
@router.post("/signup", response_model=TokenOut, status_code=status.HTTP_201_CREATED)
def signup(
    body: SignupIn,
    session: Annotated[Session, Depends(get_session)],
):
    roster = session.get(StudentRoster, body.student_number)
    if not roster:
        raise HTTPException(
            status.HTTP_403_FORBIDDEN,
            "Student number not registered. Ask the librarian.",
        )

    existing = session.exec(
        select(User).where(User.student_number == body.student_number)
    ).first()
    if existing:
        raise HTTPException(status.HTTP_409_CONFLICT, "Account already exists")

    user = User(
        student_number=roster.student_number,
        email=roster.email,
        name=roster.name,
        password_hash=hash_password(body.password),
        role=UserRole.student,
        status=UserStatus.active,
        department=roster.department,
        year=roster.year,
        borrow_limit=DEFAULT_LIMITS[UserRole.student],
    )
    session.add(user)
    session.commit()
    session.refresh(user)
    return _issue_tokens(session, user)




# ═══════════════════════════════════════════════════════════════
# POST /auth/librarian-signup — allow staff self-registration
# ═══════════════════════════════════════════════════════════════
class LibrarianSignupIn(BaseModel):
    staff_number: str = Field(min_length=4, max_length=20)
    name: str = Field(min_length=2, max_length=120)
    password: str = Field(min_length=8, max_length=72)
    department: str | None = None


@router.post("/librarian-signup", response_model=TokenOut, status_code=201)
def librarian_signup(
    body: LibrarianSignupIn,
    session: Annotated[Session, Depends(get_session)],
):
    email = f"{body.staff_number}@dii.tj"

    existing = session.exec(
        select(User).where(
            (User.student_number == body.staff_number) | (User.email == email)
        )
    ).first()
    if existing:
        raise HTTPException(status.HTTP_409_CONFLICT,
                            "Staff ID already registered")

    user = User(
        student_number=body.staff_number,
        email=email,
        name=body.name,
        password_hash=hash_password(body.password),
        role=UserRole.librarian,
        status=UserStatus.active,
        department=body.department,
        borrow_limit=DEFAULT_LIMITS[UserRole.librarian],
    )
    session.add(user)
    session.commit()
    session.refresh(user)
    return _issue_tokens(session, user)


@router.post("/login", response_model=TokenOut)
def login(
    body: LoginIn,
    session: Annotated[Session, Depends(get_session)],
):
    user = session.exec(
        select(User).where(User.student_number == body.student_number)
    ).first()
    if not user or user.deleted_at is not None:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "Invalid credentials")
    if not verify_password(body.password, user.password_hash):
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "Invalid credentials")
    if user.status != UserStatus.active:
        raise HTTPException(status.HTTP_403_FORBIDDEN, "Account blocked")

    user.last_login_at = datetime.now(timezone.utc)
    session.add(user)
    session.commit()
    session.refresh(user)
    return _issue_tokens(session, user)


@router.post("/refresh", response_model=TokenOut)
def refresh(
    body: RefreshIn,
    session: Annotated[Session, Depends(get_session)],
):
    token_hash = hash_refresh_token(body.refresh_token)
    rt = session.exec(
        select(RefreshToken).where(RefreshToken.token_hash == token_hash)
    ).first()
    if not rt or rt.revoked_at is not None:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "Invalid refresh token")
    if rt.expires_at < datetime.now(timezone.utc):
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "Refresh token expired")

    user = session.get(User, rt.user_id)
    if not user or user.deleted_at is not None:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "User not found")
    if user.status != UserStatus.active:
        raise HTTPException(status.HTTP_403_FORBIDDEN, "Account blocked")

    rt.revoked_at = datetime.now(timezone.utc)
    session.add(rt)
    session.commit()
    return _issue_tokens(session, user)


@router.post("/logout")
def logout(
    body: LogoutIn,
    session: Annotated[Session, Depends(get_session)],
    _user: CurrentUser,
):
    token_hash = hash_refresh_token(body.refresh_token)
    rt = session.exec(
        select(RefreshToken).where(RefreshToken.token_hash == token_hash)
    ).first()
    if rt and rt.revoked_at is None:
        rt.revoked_at = datetime.now(timezone.utc)
        session.add(rt)
        session.commit()
    return {"ok": True}
