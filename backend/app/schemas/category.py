import uuid
from datetime import datetime
from typing import Optional

from pydantic import BaseModel, Field


class CategoryOut(BaseModel):
    id: uuid.UUID
    slug: str
    name: str
    description: Optional[str] = None
    icon: Optional[str] = None
    color: Optional[str] = None
    image_url: Optional[str] = None
    sort_order: int
    is_active: bool
    created_at: datetime

    model_config = {"from_attributes": True}


class CategoryIn(BaseModel):
    slug: str = Field(min_length=2, max_length=60)
    name: str = Field(min_length=2, max_length=120)
    description: Optional[str] = None
    icon: Optional[str] = Field(default=None, max_length=60)
    color: Optional[str] = Field(default=None, max_length=9)
    image_url: Optional[str] = None
    sort_order: int = 0
    is_active: bool = True
