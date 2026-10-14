import re
from pydantic import BaseModel, EmailStr, Field, field_validator

from app.schemas.user import UserOut


STUDENT_NUMBER_RE = re.compile(r"^\d{6,12}$")


class SignupIn(BaseModel):
    student_number: str = Field(min_length=6, max_length=12)
    name: str = Field(min_length=2, max_length=120)
    password: str = Field(min_length=8, max_length=72)
    department: str | None = None
    year: int | None = Field(default=None, ge=1, le=6)

    @field_validator("student_number")
    @classmethod
    def validate_student_number(cls, v: str) -> str:
        if not STUDENT_NUMBER_RE.match(v):
            raise ValueError("student_number must be 6-12 digits")
        return v


class LoginIn(BaseModel):
    student_number: str
    password: str


class TokenOut(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    user: UserOut


class RefreshIn(BaseModel):
    refresh_token: str


class LogoutIn(BaseModel):
    refresh_token: str
