import uuid
from datetime import datetime, timezone
from typing import Optional

from sqlalchemy import Column, Enum as SAEnum, SmallInteger
from sqlmodel import Field, SQLModel

from app.models.enums import BorrowStatus


class Borrowing(SQLModel, table=True):
    __tablename__ = "borrowings"

    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    user_id: uuid.UUID = Field(foreign_key="users.id", index=True)
    book_id: uuid.UUID = Field(foreign_key="books.id", index=True)
    status: BorrowStatus = Field(
        default=BorrowStatus.pending,
        sa_column=Column(SAEnum(BorrowStatus, name="borrow_status"), nullable=False),
    )
    days: int = Field(default=14, sa_column=Column(SmallInteger, nullable=False))
    notes: Optional[str] = None
    requested_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))
    approved_at: Optional[datetime] = None
    approved_by: Optional[uuid.UUID] = Field(default=None, foreign_key="users.id")
    rejected_at: Optional[datetime] = None
    rejected_by: Optional[uuid.UUID] = Field(default=None, foreign_key="users.id")
    due_at: Optional[datetime] = None
    returned_at: Optional[datetime] = None
    received_by: Optional[uuid.UUID] = Field(default=None, foreign_key="users.id")
    fine: float = Field(default=0.0)
    created_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))
    updated_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))
