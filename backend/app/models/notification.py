import uuid
from datetime import datetime, timezone
from typing import Optional

from sqlalchemy import Column, Enum as SAEnum
from sqlmodel import Field, SQLModel

from app.models.enums import NotificationType


class Notification(SQLModel, table=True):
    __tablename__ = "notifications"

    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    user_id: uuid.UUID = Field(foreign_key="users.id", index=True)
    type: NotificationType = Field(
        default=NotificationType.info,
        sa_column=Column(SAEnum(NotificationType, name="notification_type"), nullable=False),
    )
    title: str = Field(max_length=200)
    body: str
    related_id: Optional[uuid.UUID] = None
    related_type: Optional[str] = Field(default=None, max_length=40)
    read: bool = Field(default=False)
    created_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))
