import uuid
from datetime import datetime, timezone
from typing import Optional

from sqlalchemy import Column, SmallInteger
from sqlmodel import Field, SQLModel


class Category(SQLModel, table=True):
    __tablename__ = "categories"

    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    slug: str = Field(max_length=60, unique=True, index=True)
    name: str = Field(max_length=120)
    description: Optional[str] = None
    icon: Optional[str] = Field(default=None, max_length=60)
    color: Optional[str] = Field(default=None, max_length=9)
    image_url: Optional[str] = None
    sort_order: int = Field(default=0, sa_column=Column(SmallInteger, nullable=False))
    is_active: bool = Field(default=True)
    created_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))
    updated_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))
