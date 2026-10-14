from datetime import datetime, timezone
from typing import Annotated

from fastapi import APIRouter, Depends
from sqlalchemy import func
from sqlmodel import Session, select

from app.database import get_session
from app.models import Book, Borrowing, User
from app.models.enums import BorrowStatus, UserRole
from app.auth.deps import StaffUser


router = APIRouter(prefix="/reports", tags=["reports"])


# ═══════════════════════════════════════════════════════════════
# GET /reports/summary — dashboard cards
# ═══════════════════════════════════════════════════════════════
@router.get("/summary")
def summary(
    session: Annotated[Session, Depends(get_session)],
    _staff: StaffUser,
):
    total_books = session.exec(
        select(func.count()).select_from(Book).where(Book.deleted_at.is_(None))
    ).one()

    total_copies = session.exec(
        select(func.coalesce(func.sum(Book.total_copies), 0)).where(Book.deleted_at.is_(None))
    ).one()

    available_copies = session.exec(
        select(func.coalesce(func.sum(Book.available_copies), 0)).where(Book.deleted_at.is_(None))
    ).one()

    total_users = session.exec(
        select(func.count()).select_from(User).where(User.deleted_at.is_(None))
    ).one()

    total_students = session.exec(
        select(func.count()).select_from(User).where(
            User.deleted_at.is_(None), User.role == UserRole.student
        )
    ).one()

    active_loans = session.exec(
        select(func.count()).select_from(Borrowing).where(
            Borrowing.status == BorrowStatus.approved
        )
    ).one()

    pending_requests = session.exec(
        select(func.count()).select_from(Borrowing).where(
            Borrowing.status == BorrowStatus.pending
        )
    ).one()

    now = datetime.now(timezone.utc)
    overdue_loans = session.exec(
        select(func.count()).select_from(Borrowing).where(
            Borrowing.status == BorrowStatus.approved,
            Borrowing.due_at < now,
        )
    ).one()

    returned_total = session.exec(
        select(func.count()).select_from(Borrowing).where(
            Borrowing.status == BorrowStatus.returned
        )
    ).one()

    return {
        "books": {
            "titles": total_books,
            "total_copies": int(total_copies),
            "available_copies": int(available_copies),
        },
        "users": {
            "total": total_users,
            "students": total_students,
        },
        "loans": {
            "active": active_loans,
            "pending": pending_requests,
            "overdue": overdue_loans,
            "returned_total": returned_total,
        },
    }


# ═══════════════════════════════════════════════════════════════
# GET /reports/overdue — list of overdue loans
# ═══════════════════════════════════════════════════════════════
@router.get("/overdue")
def overdue(
    session: Annotated[Session, Depends(get_session)],
    _staff: StaffUser,
):
    now = datetime.now(timezone.utc)
    stmt = (
        select(Borrowing, Book.title, User.name, User.student_number)
        .join(Book, Book.id == Borrowing.book_id)
        .join(User, User.id == Borrowing.user_id)
        .where(
            Borrowing.status == BorrowStatus.approved,
            Borrowing.due_at < now,
        )
        .order_by(Borrowing.due_at)
    )
    rows = session.exec(stmt).all()

    result = []
    for b, book_title, user_name, student_number in rows:
        days_overdue = (now - b.due_at).days if b.due_at else 0
        result.append({
            "borrowing_id": str(b.id),
            "user_id": str(b.user_id),
            "student_name": user_name,
            "student_number": student_number,
            "book_id": str(b.book_id),
            "book_title": book_title,
            "due_at": b.due_at.isoformat() if b.due_at else None,
            "days_overdue": days_overdue,
        })
    return {"items": result, "total": len(result)}


# ═══════════════════════════════════════════════════════════════
# GET /reports/popular — top borrowed books
# ═══════════════════════════════════════════════════════════════
@router.get("/popular")
def popular(
    session: Annotated[Session, Depends(get_session)],
    _staff: StaffUser,
    limit: int = 10,
):
    stmt = (
        select(
            Book.id,
            Book.title,
            Book.author,
            Book.book_code,
            func.count(Borrowing.id).label("borrow_count"),
        )
        .join(Borrowing, Borrowing.book_id == Book.id)
        .where(
            Book.deleted_at.is_(None),
            Borrowing.status.in_([
                BorrowStatus.approved,
                BorrowStatus.returned,
                BorrowStatus.overdue,
            ]),
        )
        .group_by(Book.id, Book.title, Book.author, Book.book_code)
        .order_by(func.count(Borrowing.id).desc())
        .limit(limit)
    )
    rows = session.exec(stmt).all()

    items = [
        {
            "book_id": str(row[0]),
            "title": row[1],
            "author": row[2],
            "book_code": row[3],
            "borrow_count": row[4],
        }
        for row in rows
    ]
    return {"items": items, "total": len(items)}
