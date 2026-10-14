from datetime import datetime
from typing import Optional

from sqlalchemy import Column, SmallInteger
from sqlmodel import Field, SQLModel


class StudentRoster(SQLModel, table=True):
    __tablename__ = "students_roster"

    student_number: str = Field(max_length=20, primary_key=True)
    name: str = Field(max_length=120)
    email: str = Field(max_length=120)
    department: Optional[str] = Field(default=None, max_length=120)
    year: Optional[int] = Field(default=None, sa_column=Column(SmallInteger))
    created_at: datetime = Field(default_factory=lambda: datetime.now())
