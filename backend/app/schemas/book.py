import uuid
from datetime import datetime
from typing import Optional

from pydantic import BaseModel, Field


class BookIn(BaseModel):
    title: str = Field(min_length=1, max_length=300)
    author: str = Field(min_length=1, max_length=200)
    category_id: Optional[uuid.UUID] = None
    book_code: Optional[str] = Field(default=None, max_length=50)
    isbn: Optional[str] = Field(default=None, max_length=20)
    description: Optional[str] = None
    cover_url: Optional[str] = None
    pdf_url: Optional[str] = None
    pages: Optional[int] = Field(default=None, ge=0)
    language: Optional[str] = Field(default="en", max_length=20)
    total_copies: int = Field(default=1, ge=0)


class BookUpdateIn(BaseModel):
    title: Optional[str] = Field(default=None, min_length=1, max_length=300)
    author: Optional[str] = Field(default=None, min_length=1, max_length=200)
    category_id: Optional[uuid.UUID] = None
    book_code: Optional[str] = Field(default=None, max_length=50)
    isbn: Optional[str] = Field(default=None, max_length=20)
    description: Optional[str] = None
    cover_url: Optional[str] = None
    pdf_url: Optional[str] = None
    pages: Optional[int] = Field(default=None, ge=0)
    language: Optional[str] = Field(default=None, max_length=20)
    total_copies: Optional[int] = Field(default=None, ge=0)


class BookOut(BaseModel):
    id: uuid.UUID
    category_id: Optional[uuid.UUID] = None
    category_name: Optional[str] = None
    title: str
    author: str
    book_code: Optional[str] = None
    isbn: Optional[str] = None
    description: Optional[str] = None
    cover_url: Optional[str] = None
    pdf_url: Optional[str] = None
    pages: Optional[int] = None
    language: Optional[str] = None
    total_copies: int
    available_copies: int
    created_at: datetime
    copy_ids: Optional[list] = None

    model_config = {"from_attributes": True}


class BookListOut(BaseModel):
    items: list[BookOut]
    total: int
    page: int
    size: int
