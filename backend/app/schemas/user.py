import uuid
from datetime import datetime
from typing import Optional

from pydantic import BaseModel, EmailStr, Field

from app.models.enums import UserRole, UserStatus


class UserOut(BaseModel):
    id: uuid.UUID
    student_number: str
    email: EmailStr
    name: str
    role: UserRole
    status: UserStatus
    department: Optional[str] = None
    year: Optional[int] = None
    phone: Optional[str] = None
    avatar_url: Optional[str] = None
    borrow_limit: int
    last_login_at: Optional[datetime] = None
    created_at: datetime

    model_config = {"from_attributes": True}


class UserUpdateIn(BaseModel):
    name: Optional[str] = Field(default=None, min_length=2, max_length=120)
    phone: Optional[str] = Field(default=None, max_length=30)
    department: Optional[str] = Field(default=None, max_length=120)
    year: Optional[int] = Field(default=None, ge=1, le=6)
    avatar_url: Optional[str] = None


class UserListOut(BaseModel):
    items: list[UserOut]
    total: int
    page: int
    size: int
