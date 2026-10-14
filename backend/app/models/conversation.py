import uuid
from datetime import datetime, timezone
from typing import Optional

from sqlmodel import Field, SQLModel


class Message(SQLModel, table=True):
    __tablename__ = "messages"

    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    sender_id: uuid.UUID = Field(foreign_key="users.id", index=True)
    recipient_id: uuid.UUID = Field(foreign_key="users.id", index=True)
    body: str
    related_id: Optional[uuid.UUID] = None  # book id or notification id
    related_type: Optional[str] = Field(default=None, max_length=40)
    read: bool = Field(default=False)
    created_at: datetime = Field(
        default_factory=lambda: datetime.now(timezone.utc)
    )
