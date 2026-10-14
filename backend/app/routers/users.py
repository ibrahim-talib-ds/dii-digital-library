import uuid
from datetime import datetime, timezone
from typing import Annotated, Optional

from fastapi import APIRouter, Depends, HTTPException, Query, status
from pydantic import BaseModel
from sqlalchemy import func, or_
from sqlmodel import Session, select

from app.database import get_session
from app.models import User, Borrowing, Notification
from app.models.enums import UserRole, UserStatus, BorrowStatus, NotificationType
from app.schemas import UserOut, UserUpdateIn, UserListOut
from app.auth.deps import CurrentUser, StaffUser, AdminUser


router = APIRouter(prefix="/users", tags=["users"])


# ═══════════════════════════════════════════════════════════════
# GET /users — staff only, filter by role + search
# ═══════════════════════════════════════════════════════════════
@router.get("", response_model=UserListOut)
def list_users(
    session: Annotated[Session, Depends(get_session)],
    _staff: StaffUser,
    role: Optional[str] = Query(default=None),
    search: Optional[str] = Query(default=None, min_length=1, max_length=120),
    page: int = Query(default=1, ge=1),
    size: int = Query(default=20, ge=1, le=100),
):
    stmt = select(User).where(User.deleted_at.is_(None))

    if role:
        try:
            stmt = stmt.where(User.role == UserRole(role))
        except ValueError:
            raise HTTPException(status.HTTP_400_BAD_REQUEST, "Invalid role")

    if search:
        like = f"%{search.lower()}%"
        stmt = stmt.where(
            or_(
                func.lower(User.name).like(like),
                func.lower(User.student_number).like(like),
                func.lower(User.email).like(like),
            )
        )

    total = session.exec(
        select(func.count()).select_from(stmt.subquery())
    ).one()

    stmt = stmt.order_by(User.name).offset((page - 1) * size).limit(size)
    rows = session.exec(stmt).all()

    return UserListOut(
        items=[UserOut.model_validate(u) for u in rows],
        total=total, page=page, size=size,
    )


# ═══════════════════════════════════════════════════════════════
# GET /users/{id} — self or staff
# ═══════════════════════════════════════════════════════════════
@router.get("/{user_id}", response_model=UserOut)
def get_user(
    user_id: uuid.UUID,
    session: Annotated[Session, Depends(get_session)],
    me: CurrentUser,
):
    if me.id != user_id and me.role not in (UserRole.librarian, UserRole.admin):
        raise HTTPException(status.HTTP_403_FORBIDDEN, "Not allowed")

    u = session.get(User, user_id)
    if not u or u.deleted_at is not None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "User not found")
    return UserOut.model_validate(u)


# ═══════════════════════════════════════════════════════════════
# PATCH /users/{id} — self (limited) or admin (full)
# ═══════════════════════════════════════════════════════════════
@router.patch("/{user_id}", response_model=UserOut)
def update_user(
    user_id: uuid.UUID,
    body: UserUpdateIn,
    session: Annotated[Session, Depends(get_session)],
    me: CurrentUser,
):
    is_admin = me.role == UserRole.admin
    is_self  = me.id == user_id
    if not (is_self or is_admin):
        raise HTTPException(status.HTTP_403_FORBIDDEN, "Not allowed")

    u = session.get(User, user_id)
    if not u or u.deleted_at is not None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "User not found")

    for k, v in body.model_dump(exclude_unset=True).items():
        setattr(u, k, v)

    u.updated_at = datetime.now(timezone.utc)
    session.add(u)
    session.commit()
    session.refresh(u)
    return UserOut.model_validate(u)


# ═══════════════════════════════════════════════════════════════
# POST /users/{id}/block — admin
# ═══════════════════════════════════════════════════════════════
@router.post("/{user_id}/block", response_model=UserOut)
def block_user(
    user_id: uuid.UUID,
    session: Annotated[Session, Depends(get_session)],
    admin: AdminUser,
):
    if admin.id == user_id:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "Cannot block yourself")

    u = session.get(User, user_id)
    if not u or u.deleted_at is not None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "User not found")

    u.status = UserStatus.blocked
    u.updated_at = datetime.now(timezone.utc)
    session.add(u)
    session.commit()
    session.refresh(u)
    return UserOut.model_validate(u)


# ═══════════════════════════════════════════════════════════════
# POST /users/{id}/unblock — admin
# ═══════════════════════════════════════════════════════════════
@router.post("/{user_id}/unblock", response_model=UserOut)
def unblock_user(
    user_id: uuid.UUID,
    session: Annotated[Session, Depends(get_session)],
    _admin: AdminUser,
):
    u = session.get(User, user_id)
    if not u or u.deleted_at is not None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "User not found")

    u.status = UserStatus.active
    u.updated_at = datetime.now(timezone.utc)
    session.add(u)
    session.commit()
    session.refresh(u)
    return UserOut.model_validate(u)


# ═══════════════════════════════════════════════════════════════
# POST /users/{id}/message — staff sends a message (creates a notification)
# ═══════════════════════════════════════════════════════════════
class MessageIn(BaseModel):
    title: str
    body: str


@router.post("/{user_id}/message")
def send_message(
    user_id: uuid.UUID,
    body: MessageIn,
    session: Annotated[Session, Depends(get_session)],
    staff: StaffUser,
):
    target = session.get(User, user_id)
    if not target or target.deleted_at is not None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "User not found")

    if not body.title.strip() or not body.body.strip():
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "Title and body required")

    n = Notification(
        user_id=user_id,
        type=NotificationType.info,
        title=body.title.strip()[:200],
        body=body.body.strip()[:1000],
    )
    session.add(n)
    session.commit()
    session.refresh(n)

    return {"ok": True, "notification_id": str(n.id)}
