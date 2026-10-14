import uuid
from datetime import datetime, timezone
from typing import Optional

from sqlalchemy import Column
from sqlalchemy.dialects.postgresql import JSONB
from sqlmodel import Field, SQLModel


class Book(SQLModel, table=True):
    __tablename__ = "books"

    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    category_id: Optional[uuid.UUID] = Field(default=None, foreign_key="categories.id")
    title: str = Field(max_length=300)
    author: str = Field(max_length=200)
    book_code: Optional[str] = Field(default=None, max_length=50, unique=True)
    isbn: Optional[str] = Field(default=None, max_length=20)
    description: Optional[str] = None
    cover_url: Optional[str] = None
    pdf_url: Optional[str] = None
    pages: Optional[int] = None
    language: Optional[str] = Field(default="en", max_length=20)
    total_copies: int = Field(default=1)
    available_copies: int = Field(default=1)
    added_by: Optional[uuid.UUID] = Field(default=None, foreign_key="users.id")
    created_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))
    updated_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))
    deleted_at: Optional[datetime] = None
    copy_ids: Optional[list] = Field(default=None, sa_column=Column(JSONB))
