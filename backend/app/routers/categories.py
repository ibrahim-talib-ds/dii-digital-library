import uuid
from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException, status
from sqlmodel import Session, select

from app.database import get_session
from app.models import Category, Book
from app.schemas import CategoryOut, CategoryIn
from app.auth.deps import CurrentUser, StaffUser, AdminUser


router = APIRouter(prefix="/categories", tags=["categories"])


# ═══════════════════════════════════════════════════════════════
# GET /categories — public list (signed in only)
# ═══════════════════════════════════════════════════════════════
@router.get("", response_model=list[CategoryOut])
def list_categories(
    session: Annotated[Session, Depends(get_session)],
    _user: CurrentUser,
    include_inactive: bool = False,
):
    stmt = select(Category)
    if not include_inactive:
        stmt = stmt.where(Category.is_active == True)  # noqa: E712
    stmt = stmt.order_by(Category.sort_order, Category.name)
    return session.exec(stmt).all()


# ═══════════════════════════════════════════════════════════════
# GET /categories/{id}
# ═══════════════════════════════════════════════════════════════
@router.get("/{category_id}", response_model=CategoryOut)
def get_category(
    category_id: uuid.UUID,
    session: Annotated[Session, Depends(get_session)],
    _user: CurrentUser,
):
    cat = session.get(Category, category_id)
    if not cat:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Category not found")
    return cat


# ═══════════════════════════════════════════════════════════════
# POST /categories — staff only
# ═══════════════════════════════════════════════════════════════
@router.post("", response_model=CategoryOut, status_code=status.HTTP_201_CREATED)
def create_category(
    body: CategoryIn,
    session: Annotated[Session, Depends(get_session)],
    _user: StaffUser,
):
    # slug uniqueness
    existing = session.exec(
        select(Category).where(Category.slug == body.slug)
    ).first()
    if existing:
        raise HTTPException(status.HTTP_409_CONFLICT, "Slug already exists")

    cat = Category(**body.model_dump())
    session.add(cat)
    session.commit()
    session.refresh(cat)
    return cat


# ═══════════════════════════════════════════════════════════════
# PATCH /categories/{id} — staff only
# ═══════════════════════════════════════════════════════════════
@router.patch("/{category_id}", response_model=CategoryOut)
def update_category(
    category_id: uuid.UUID,
    body: CategoryIn,
    session: Annotated[Session, Depends(get_session)],
    _user: StaffUser,
):
    cat = session.get(Category, category_id)
    if not cat:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Category not found")

    # slug conflict on rename
    if body.slug != cat.slug:
        clash = session.exec(
            select(Category).where(Category.slug == body.slug)
        ).first()
        if clash:
            raise HTTPException(status.HTTP_409_CONFLICT, "Slug already in use")

    for k, v in body.model_dump().items():
        setattr(cat, k, v)
    session.add(cat)
    session.commit()
    session.refresh(cat)
    return cat


# ═══════════════════════════════════════════════════════════════
# DELETE /categories/{id} — admin only (refuse if books reference it)
# ═══════════════════════════════════════════════════════════════
@router.delete("/{category_id}", status_code=status.HTTP_200_OK)
def delete_category(
    category_id: uuid.UUID,
    session: Annotated[Session, Depends(get_session)],
    _user: AdminUser,
):
    cat = session.get(Category, category_id)
    if not cat:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Category not found")

    books = session.exec(
        select(Book).where(Book.category_id == category_id)
    ).first()
    if books:
        raise HTTPException(
            status.HTTP_409_CONFLICT,
            "Cannot delete: books reference this category",
        )

    session.delete(cat)
    session.commit()
    return {"ok": True}
