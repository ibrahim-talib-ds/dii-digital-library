import math
import uuid
from datetime import datetime, timezone
from typing import Annotated, Optional

from fastapi import APIRouter, Depends, HTTPException, Query, status
import httpx
from fastapi.responses import StreamingResponse
from sqlalchemy import or_, func
from sqlmodel import Session, select

from app.database import get_session
from app.models import Book, Category, SavedBook
from app.schemas import BookIn, BookUpdateIn, BookOut, BookListOut
from app.auth.deps import CurrentUser, StaffUser, AdminUser


router = APIRouter(prefix="/books", tags=["books"])


# ═══════════════════════════════════════════════════════════════
# helpers
# ═══════════════════════════════════════════════════════════════
def _to_out(book: Book, cat_name: Optional[str]) -> BookOut:
    out = BookOut.model_validate(book)
    out.category_name = cat_name
    return out


def _fetch_categories(session: Session, ids: list[uuid.UUID]) -> dict[uuid.UUID, str]:
    if not ids:
        return {}
    rows = session.exec(
        select(Category.id, Category.name).where(Category.id.in_(ids))
    ).all()
    return {row[0]: row[1] for row in rows}


# ═══════════════════════════════════════════════════════════════
# GET /books — search + filter + paginate
# ═══════════════════════════════════════════════════════════════
@router.get("", response_model=BookListOut)
def list_books(
    session: Annotated[Session, Depends(get_session)],
    _user: CurrentUser,
    search: Optional[str] = Query(default=None, min_length=1, max_length=120),
    category: Optional[uuid.UUID] = Query(default=None),
    available: Optional[bool] = Query(default=None),
    page: int = Query(default=1, ge=1),
    size: int = Query(default=20, ge=1, le=100),
):
    stmt = select(Book).where(Book.deleted_at.is_(None))

    if search:
        like = f"%{search.lower()}%"
        stmt = stmt.where(
            or_(
                func.lower(Book.title).like(like),
                func.lower(Book.author).like(like),
                func.lower(Book.book_code).like(like),
            )
        )

    if category:
        stmt = stmt.where(Book.category_id == category)

    if available is True:
        stmt = stmt.where(Book.available_copies > 0)

    # total count
    total = session.exec(
        select(func.count()).select_from(stmt.subquery())
    ).one()

    stmt = stmt.order_by(Book.title).offset((page - 1) * size).limit(size)
    books = session.exec(stmt).all()

    cat_map = _fetch_categories(session, [b.category_id for b in books if b.category_id])
    items = [_to_out(b, cat_map.get(b.category_id)) for b in books]

    return BookListOut(items=items, total=total, page=page, size=size)


# ═══════════════════════════════════════════════════════════════
# GET /books/{id}
# ═══════════════════════════════════════════════════════════════
@router.get("/{book_id}", response_model=BookOut)
def get_book(
    book_id: uuid.UUID,
    session: Annotated[Session, Depends(get_session)],
    _user: CurrentUser,
):
    book = session.get(Book, book_id)
    if not book or book.deleted_at is not None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Book not found")

    cat_name = None
    if book.category_id:
        cat = session.get(Category, book.category_id)
        cat_name = cat.name if cat else None

    return _to_out(book, cat_name)


# ═══════════════════════════════════════════════════════════════
# POST /books — staff only
# ═══════════════════════════════════════════════════════════════
@router.post("", response_model=BookOut, status_code=status.HTTP_201_CREATED)
def create_book(
    body: BookIn,
    session: Annotated[Session, Depends(get_session)],
    user: StaffUser,
):
    # optional category check
    cat_name = None
    if body.category_id:
        cat = session.get(Category, body.category_id)
        if not cat:
            raise HTTPException(status.HTTP_400_BAD_REQUEST, "Category not found")
        cat_name = cat.name

    # book_code uniqueness
    if body.book_code:
        clash = session.exec(
            select(Book).where(Book.book_code == body.book_code)
        ).first()
        if clash:
            raise HTTPException(status.HTTP_409_CONFLICT, "book_code already used")

    book = Book(
        **body.model_dump(),
        available_copies=body.total_copies,
        added_by=user.id,
    )
    session.add(book)
    session.commit()
    session.refresh(book)

    return _to_out(book, cat_name)


# ═══════════════════════════════════════════════════════════════
# PATCH /books/{id} — staff only
# ═══════════════════════════════════════════════════════════════
@router.patch("/{book_id}", response_model=BookOut)
def update_book(
    book_id: uuid.UUID,
    body: BookUpdateIn,
    session: Annotated[Session, Depends(get_session)],
    _user: StaffUser,
):
    book = session.get(Book, book_id)
    if not book or book.deleted_at is not None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Book not found")

    data = body.model_dump(exclude_unset=True)

    # book_code uniqueness if changed
    if "book_code" in data and data["book_code"] and data["book_code"] != book.book_code:
        clash = session.exec(
            select(Book).where(Book.book_code == data["book_code"])
        ).first()
        if clash:
            raise HTTPException(status.HTTP_409_CONFLICT, "book_code already used")

    # total_copies change → adjust available_copies by the delta
    if "total_copies" in data and data["total_copies"] is not None:
        old_total = book.total_copies
        new_total = data["total_copies"]
        delta = new_total - old_total
        book.available_copies = max(0, book.available_copies + delta)

    for k, v in data.items():
        setattr(book, k, v)

    book.updated_at = datetime.now(timezone.utc)
    session.add(book)
    session.commit()
    session.refresh(book)

    cat_name = None
    if book.category_id:
        cat = session.get(Category, book.category_id)
        cat_name = cat.name if cat else None

    return _to_out(book, cat_name)


# ═══════════════════════════════════════════════════════════════
# DELETE /books/{id} — soft delete, admin only
# ═══════════════════════════════════════════════════════════════
@router.delete("/{book_id}")
def delete_book(
    book_id: uuid.UUID,
    session: Annotated[Session, Depends(get_session)],
    _user: AdminUser,
):
    book = session.get(Book, book_id)
    if not book or book.deleted_at is not None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Book not found")

    book.deleted_at = datetime.now(timezone.utc)
    session.add(book)
    session.commit()
    return {"ok": True}

# ═══════════════════════════════════════════════════════════════
# GET /books/saved — user's saved books
# ═══════════════════════════════════════════════════════════════
@router.get("/saved/list", response_model=list[BookOut])
def list_saved(
    session: Annotated[Session, Depends(get_session)],
    user: CurrentUser,
):
    rows = session.exec(
        select(SavedBook).where(SavedBook.user_id == user.id)
        .order_by(SavedBook.created_at.desc())
    ).all()

    result = []
    for row in rows:
        book = session.get(Book, row.book_id)
        if not book or book.deleted_at is not None:
            continue
        cat_name = None
        if book.category_id:
            cat = session.get(Category, book.category_id)
            cat_name = cat.name if cat else None
        result.append(_to_out(book, cat_name))
    return result


# ═══════════════════════════════════════════════════════════════
# POST /books/{id}/save
# ═══════════════════════════════════════════════════════════════
@router.post("/{book_id}/save")
def save_book(
    book_id: uuid.UUID,
    session: Annotated[Session, Depends(get_session)],
    user: CurrentUser,
):
    book = session.get(Book, book_id)
    if not book or book.deleted_at is not None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Book not found")

    existing = session.exec(
        select(SavedBook).where(
            SavedBook.user_id == user.id,
            SavedBook.book_id == book_id,
        )
    ).first()
    if existing:
        return {"ok": True, "saved": True}

    saved = SavedBook(user_id=user.id, book_id=book_id)
    session.add(saved)
    session.commit()
    return {"ok": True, "saved": True}


# ═══════════════════════════════════════════════════════════════
# DELETE /books/{id}/save
# ═══════════════════════════════════════════════════════════════
@router.delete("/{book_id}/save")
def unsave_book(
    book_id: uuid.UUID,
    session: Annotated[Session, Depends(get_session)],
    user: CurrentUser,
):
    existing = session.exec(
        select(SavedBook).where(
            SavedBook.user_id == user.id,
            SavedBook.book_id == book_id,
        )
    ).first()
    if existing:
        session.delete(existing)
        session.commit()
    return {"ok": True, "saved": False}

# ═══════════════════════════════════════════════════════════════
# GET /books/proxy-pdf — Bypass CORS for external PDFs
# ═══════════════════════════════════════════════════════════════
@router.get("/proxy-pdf")
async def proxy_pdf(url: str):
    async def stream_pdf():
        async with httpx.AsyncClient() as client:
            async with client.stream("GET", url, follow_redirects=True) as response:
                response.raise_for_status()
                async for chunk in response.aiter_bytes():
                    yield chunk
                    
    return StreamingResponse(stream_pdf(), media_type="application/pdf")

