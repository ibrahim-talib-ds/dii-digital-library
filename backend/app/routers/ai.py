import httpx
import uuid
from datetime import datetime, timezone
from typing import Annotated, Optional

from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel, Field
from sqlmodel import Session, select

from app.config import settings
from app.database import get_session
from app.auth.deps import CurrentUser
from app.models import Message


router = APIRouter(prefix="/ai", tags=["ai"])

GROQ_URL = "https://api.groq.com/openai/v1/chat/completions"
GROQ_MODEL = "openai/gpt-oss-120b"
AI_NAME = "Ibro_Ai"

SYSTEM_PROMPT = (
    f"You are {AI_NAME}, the DII Digital Library assistant for "
    "Dushanbe Innovation Institute. "
    "You help students find books, understand borrowing rules "
    "(students can borrow 3 books at a time for 14 days), "
    "explain how to request physical copies, check availability, and "
    "answer questions about the library system. Be friendly, concise, and clear. "
    "If the user asks about a specific book, suggest they browse the catalogue "
    "or use the search bar. Keep answers under 120 words unless more detail is asked for."
)


class ChatIn(BaseModel):
    message: str = Field(min_length=1, max_length=4000)
    conversation_id: Optional[str] = None


class ChatOut(BaseModel):
    reply: str
    conversation_id: str


@router.post("/chat", response_model=ChatOut)
async def chat(
    body: ChatIn,
    session: Annotated[Session, Depends(get_session)],
    user: CurrentUser,
):
    if not settings.groq_api_key or settings.groq_api_key.startswith("REPLACE"):
        raise HTTPException(
            503,
            "AI not configured. Add GROQ_API_KEY to backend/.env",
        )

    conv_id = body.conversation_id or str(uuid.uuid4())

    # load past messages for this conversation
    past = session.exec(
        select(Message)
        .where(
            Message.sender_id == user.id,
            Message.related_type == "ai_chat",
            Message.related_id == uuid.UUID(conv_id),
        )
        .order_by(Message.created_at.asc())
    ).all()

    # build message history
    messages_payload = [{"role": "system", "content": SYSTEM_PROMPT}]
    for m in past:
        # Message.body in our case is "user: ... || ai: ..." style? No — we store raw
        messages_payload.append({"role": "user", "content": m.body})

    messages_payload.append({"role": "user", "content": body.message})

    headers = {
        "Authorization": f"Bearer {settings.groq_api_key}",
        "Content-Type": "application/json",
    }
    payload = {
        "model": GROQ_MODEL,
        "messages": messages_payload,
        "temperature": 0.7,
        "max_tokens": 500,
    }

    try:
        async with httpx.AsyncClient(timeout=30) as client:
            r = await client.post(GROQ_URL, headers=headers, json=payload)
    except Exception as e:
        raise HTTPException(502, f"Network error: {e}")

    if r.status_code != 200:
        raise HTTPException(r.status_code, f"Groq error: {r.text[:200]}")

    data = r.json()
    reply = (
        data.get("choices", [{}])[0].get("message", {}).get("content", "")
        or "(no reply)"
    )

    # persist user message
    session.add(Message(
        sender_id=user.id,
        recipient_id=user.id,
        body=body.message,
        related_id=uuid.UUID(conv_id),
        related_type="ai_chat",
    ))
    # persist AI reply (as a separate row, sender = self)
    session.add(Message(
        sender_id=user.id,
        recipient_id=user.id,
        body=f"[AI] {reply}",
        related_id=uuid.UUID(conv_id),
        related_type="ai_chat",
    ))
    session.commit()

    return ChatOut(reply=reply, conversation_id=conv_id)


@router.get("/history")
def history(
    session: Annotated[Session, Depends(get_session)],
    user: CurrentUser,
):
    rows = session.exec(
        select(Message)
        .where(
            Message.sender_id == user.id,
            Message.related_type == "ai_chat",
        )
        .order_by(Message.created_at.asc())
    ).all()

    # group by conversation
    convs = {}
    for m in rows:
        cid = str(m.related_id)
        convs.setdefault(cid, []).append({
            "body": m.body,
            "created_at": m.created_at.isoformat(),
        })
    return {"conversations": convs}
