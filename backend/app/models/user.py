import uuid
from datetime import datetime, timezone
from typing import Optional

from sqlalchemy import Column, Enum as SAEnum, SmallInteger
from sqlmodel import Field, SQLModel

from app.models.enums import UserRole, UserStatus


class User(SQLModel, table=True):
    __tablename__ = "users"

    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    student_number: str = Field(max_length=20, unique=True, index=True)
    email: str = Field(max_length=120, unique=True, index=True)
    name: str = Field(max_length=120)
    password_hash: str = Field(max_length=255)
    role: UserRole = Field(
        default=UserRole.student,
        sa_column=Column(SAEnum(UserRole, name="user_role"), nullable=False),
    )
    status: UserStatus = Field(
        default=UserStatus.active,
        sa_column=Column(SAEnum(UserStatus, name="user_status"), nullable=False),
    )
    department: Optional[str] = Field(default=None, max_length=120)
    year: Optional[int] = Field(default=None, sa_column=Column(SmallInteger))
    phone: Optional[str] = Field(default=None, max_length=30)
    avatar_url: Optional[str] = Field(default=None)
    borrow_limit: int = Field(default=3, sa_column=Column(SmallInteger, nullable=False))
    last_login_at: Optional[datetime] = None
    created_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))
    updated_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))
    deleted_at: Optional[datetime] = None
