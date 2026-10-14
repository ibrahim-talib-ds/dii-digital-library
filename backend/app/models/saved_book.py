import uuid
from datetime import datetime, timezone
from typing import Optional

from sqlmodel import Field, SQLModel


class SavedBook(SQLModel, table=True):
    __tablename__ = "saved_books"

    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    user_id: uuid.UUID = Field(foreign_key="users.id", index=True)
    book_id: uuid.UUID = Field(foreign_key="books.id")
    created_at: datetime = Field(
        default_factory=lambda: datetime.now(timezone.utc)
    )
