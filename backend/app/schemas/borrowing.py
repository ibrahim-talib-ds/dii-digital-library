import uuid
from datetime import datetime
from typing import Optional

from pydantic import BaseModel, Field

from app.models.enums import BorrowStatus


class BorrowingIn(BaseModel):
    book_id: uuid.UUID
    notes: Optional[str] = None


class ApproveIn(BaseModel):
    days: int = Field(default=14, ge=1, le=90)


class BorrowingOut(BaseModel):
    id: uuid.UUID
    user_id: uuid.UUID
    book_id: uuid.UUID
    status: BorrowStatus
    days: int
    notes: Optional[str] = None
    requested_at: datetime
    approved_at: Optional[datetime] = None
    approved_by: Optional[uuid.UUID] = None
    rejected_at: Optional[datetime] = None
    due_at: Optional[datetime] = None
    returned_at: Optional[datetime] = None
    fine: float = 0.0
    # joined convenience
    book_title: Optional[str] = None
    book_cover: Optional[str] = None
    book_code: Optional[str] = None
    student_name: Optional[str] = None
    student_number: Optional[str] = None

    model_config = {"from_attributes": True}


class BorrowingListOut(BaseModel):
    items: list[BorrowingOut]
    total: int
