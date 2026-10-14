import uuid
from datetime import datetime, timezone
from typing import Annotated, Optional

from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel, Field
from sqlmodel import Session, select, or_

from app.database import get_session
from app.models import User, Message, Notification
from app.models.enums import NotificationType
from app.auth.deps import CurrentUser


router = APIRouter(prefix="/messages", tags=["messages"])


class MessageIn(BaseModel):
    recipient_id: uuid.UUID
    body: str = Field(min_length=1, max_length=2000)
    related_id: Optional[uuid.UUID] = None
    related_type: Optional[str] = None


@router.get("/inbox")
def inbox(
    session: Annotated[Session, Depends(get_session)],
    user: CurrentUser,
):
    """All messages involving this user, grouped by conversation partner."""
    rows = session.exec(
        select(Message)
        .where(or_(
            Message.sender_id == user.id,
            Message.recipient_id == user.id,
        ))
        .order_by(Message.created_at.desc())
    ).all()

    # group by partner
    seen = {}
    for m in rows:
        partner_id = m.sender_id if m.recipient_id == user.id else m.recipient_id
        if partner_id not in seen:
            partner = session.get(User, partner_id)
            seen[partner_id] = {
                "partner_id": str(partner_id),
                "partner_name": partner.name if partner else "Unknown",
                "partner_role": partner.role.value if partner else "student",
                "last_body": m.body,
                "last_at": m.created_at.isoformat(),
                "unread": 0,
            }
        if m.recipient_id == user.id and not m.read:
            seen[partner_id]["unread"] += 1

    return {"items": list(seen.values()), "total": len(seen)}


@router.get("/thread/{partner_id}")
def thread(
    partner_id: uuid.UUID,
    session: Annotated[Session, Depends(get_session)],
    user: CurrentUser,
):
    """Full conversation between me and partner."""
    rows = session.exec(
        select(Message)
        .where(or_(
            (Message.sender_id == user.id) & (Message.recipient_id == partner_id),
            (Message.sender_id == partner_id) & (Message.recipient_id == user.id),
        ))
        .order_by(Message.created_at.asc())
    ).all()

    # mark unread as read
    for m in rows:
        if m.recipient_id == user.id and not m.read:
            m.read = True
            session.add(m)
    session.commit()

    partner = session.get(User, partner_id)

    return {
        "partner": {
            "id": str(partner_id),
            "name": partner.name if partner else "Unknown",
            "role": partner.role.value if partner else "student",
        },
        "messages": [
            {
                "id": str(m.id),
                "mine": m.sender_id == user.id,
                "body": m.body,
                "read": m.read,
                "created_at": m.created_at.isoformat(),
            }
            for m in rows
        ],
    }


@router.post("")
def send_message(
    body: MessageIn,
    session: Annotated[Session, Depends(get_session)],
    user: CurrentUser,
):
    recipient = session.get(User, body.recipient_id)
    if not recipient or recipient.deleted_at is not None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Recipient not found")

    if recipient.id == user.id:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "Cannot message yourself")

    msg = Message(
        sender_id=user.id,
        recipient_id=body.recipient_id,
        body=body.body.strip(),
        related_id=body.related_id,
        related_type=body.related_type,
    )
    session.add(msg)
    session.flush()

    # also create a notification so the recipient sees the bell
    # related_id = sender's user id → frontend can navigate to chat thread
    n = Notification(
        user_id=body.recipient_id,
        type=NotificationType.info,
        title=f'New message from {user.name}',
        body=body.body.strip()[:200],
        related_id=user.id,
        related_type='message',
    )
    session.add(n)

    session.commit()
    session.refresh(msg)

    return {"ok": True, "message_id": str(msg.id)}


@router.get("/unread-count")
def unread_count(
    session: Annotated[Session, Depends(get_session)],
    user: CurrentUser,
):
    rows = session.exec(
        select(Message)
        .where(Message.recipient_id == user.id, Message.read == False)
    ).all()
    return {"count": len(rows)}
