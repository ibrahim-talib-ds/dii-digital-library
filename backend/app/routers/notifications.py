import asyncio
import json
import uuid
from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.responses import StreamingResponse
from sqlalchemy import func
from sqlmodel import Session, select

from app.database import get_session, engine
from app.models import Notification
from app.schemas import NotificationOut, NotificationListOut
from app.auth.deps import CurrentUser


router = APIRouter(prefix="/notifications", tags=["notifications"])


# ═══════════════════════════════════════════════════════════════
# GET /notifications — current user's list
# ═══════════════════════════════════════════════════════════════
@router.get("", response_model=NotificationListOut)
def list_notifications(
    session: Annotated[Session, Depends(get_session)],
    user: CurrentUser,
    unread_only: bool = False,
):
    stmt = select(Notification).where(Notification.user_id == user.id)
    if unread_only:
        stmt = stmt.where(Notification.read == False)  # noqa: E712

    stmt = stmt.order_by(Notification.created_at.desc()).limit(100)
    items = session.exec(stmt).all()

    total = session.exec(
        select(func.count()).select_from(Notification)
        .where(Notification.user_id == user.id)
    ).one()

    unread = session.exec(
        select(func.count()).select_from(Notification)
        .where(Notification.user_id == user.id, Notification.read == False)  # noqa: E712
    ).one()

    return NotificationListOut(
        items=[NotificationOut.model_validate(n) for n in items],
        total=total,
        unread=unread,
    )


# ═══════════════════════════════════════════════════════════════
# POST /notifications/{id}/read
# ═══════════════════════════════════════════════════════════════
@router.post("/{notification_id}/read")
def mark_read(
    notification_id: uuid.UUID,
    session: Annotated[Session, Depends(get_session)],
    user: CurrentUser,
):
    n = session.get(Notification, notification_id)
    if not n or n.user_id != user.id:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Notification not found")
    n.read = True
    session.add(n)
    session.commit()
    return {"ok": True}


# ═══════════════════════════════════════════════════════════════
# POST /notifications/read-all
# ═══════════════════════════════════════════════════════════════
@router.post("/read-all")
def mark_all_read(
    session: Annotated[Session, Depends(get_session)],
    user: CurrentUser,
):
    rows = session.exec(
        select(Notification)
        .where(Notification.user_id == user.id, Notification.read == False)  # noqa: E712
    ).all()
    for n in rows:
        n.read = True
        session.add(n)
    session.commit()
    return {"ok": True, "count": len(rows)}


# ═══════════════════════════════════════════════════════════════
# GET /notifications/stream — SSE for real-time unread count
# ═══════════════════════════════════════════════════════════════
@router.get("/stream")
async def stream(user: CurrentUser):
    user_id = user.id

    async def gen():
        last_count = -1
        try:
            while True:
                # new session each tick (session is not thread-safe across awaits)
                with Session(engine) as s:
                    n = s.exec(
                        select(func.count()).select_from(Notification)
                        .where(Notification.user_id == user_id,
                               Notification.read == False)  # noqa: E712
                    ).one()
                if n != last_count:
                    payload = json.dumps({"unread": n})
                    yield f"data: {payload}\n\n"
                    last_count = n
                await asyncio.sleep(3)
        except asyncio.CancelledError:
            return

    return StreamingResponse(
        gen(),
        media_type="text/event-stream",
        headers={
            "Cache-Control": "no-cache",
            "X-Accel-Buffering": "no",
        },
    )
