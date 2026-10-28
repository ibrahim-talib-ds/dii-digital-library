import uuid
from datetime import datetime, timedelta, timezone
from typing import Annotated, Optional

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import func, or_
from sqlmodel import Session, select

from app.database import get_session
from app.models import Book, Borrowing, Notification, User
from app.models.enums import BorrowStatus, NotificationType, UserRole
from app.schemas import BorrowingIn, BorrowingOut, ApproveIn, BorrowingListOut
from app.auth.deps import CurrentUser, StaffUser


from pydantic import BaseModel, Field

class IssueIn(BaseModel):
    student_number: str = Field(min_length=4, max_length=20)
    book_code: str = Field(min_length=2, max_length=40)
    days: int = Field(default=14, ge=1, le=90)
    notes: Optional[str] = None


router = APIRouter(prefix="/borrowings", tags=["borrowings"])


# ═══════════════════════════════════════════════════════════════
# helpers
# ═══════════════════════════════════════════════════════════════
def _hydrate(session: Session, b: Borrowing) -> BorrowingOut:
    out = BorrowingOut.model_validate(b)
    book = session.get(Book, b.book_id)
    if book:
        out.book_title = book.title
        out.book_cover = book.cover_url
        out.book_code  = book.book_code
    student = session.get(User, b.user_id)
    if student:
        out.student_name   = student.name
        out.student_number = student.student_number
    return out


def _notify(session: Session, user_id: uuid.UUID, ntype: NotificationType,
            title: str, body: str, related_id: uuid.UUID | None = None):
    n = Notification(
        user_id=user_id,
        type=ntype,
        title=title,
        body=body,
        related_id=related_id,
        related_type="borrowing",
    )
    session.add(n)


def _notify_staff(session: Session, ntype: NotificationType,
                  title: str, body: str, related_id: uuid.UUID | None = None):
    staff = session.exec(
        select(User).where(
            User.role.in_([UserRole.librarian, UserRole.admin]),
            User.deleted_at.is_(None),
            User.status == "active",
        )
    ).all()
    for u in staff:
        _notify(session, u.id, ntype, title, body, related_id)


# ═══════════════════════════════════════════════════════════════
# POST /borrowings — student requests a book
# ═══════════════════════════════════════════════════════════════
@router.post("", response_model=BorrowingOut, status_code=status.HTTP_201_CREATED)
def request_borrow(
    body: BorrowingIn,
    session: Annotated[Session, Depends(get_session)],
    user: CurrentUser,
):
    book = session.get(Book, body.book_id)
    if not book or book.deleted_at is not None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Book not found")

    # no duplicate active request
    dup = session.exec(
        select(Borrowing).where(
            Borrowing.user_id == user.id,
            Borrowing.book_id == book.id,
            Borrowing.status.in_([
                BorrowStatus.pending,
                BorrowStatus.approved,
                BorrowStatus.overdue,
            ]),
        )
    ).first()
    if dup:
        raise HTTPException(status.HTTP_409_CONFLICT,
                            "You already have an active request for this book")

    # total active loans check
    active = session.exec(
        select(func.count()).select_from(Borrowing).where(
            Borrowing.user_id == user.id,
            Borrowing.status.in_([BorrowStatus.approved, BorrowStatus.overdue]),
        )
    ).one()
    if active >= user.borrow_limit:
        raise HTTPException(status.HTTP_409_CONFLICT,
                            f"Borrow limit reached ({user.borrow_limit})")

    b = Borrowing(
        user_id=user.id,
        book_id=book.id,
        status=BorrowStatus.pending,
        notes=body.notes,
    )
    session.add(b)
    session.flush()  # get id

    _notify_staff(
        session, NotificationType.request,
        "New borrow request",
        f'{user.name} requested "{book.title}"',
        related_id=b.id,
    )

    session.commit()
    session.refresh(b)
    return _hydrate(session, b)


# ═══════════════════════════════════════════════════════════════
# GET /borrowings/mine — current student's list
# ═══════════════════════════════════════════════════════════════
@router.get("/mine", response_model=list[BorrowingOut])
def my_borrowings(
    session: Annotated[Session, Depends(get_session)],
    user: CurrentUser,
):
    rows = session.exec(
        select(Borrowing)
        .where(Borrowing.user_id == user.id)
        .order_by(Borrowing.requested_at.desc())
    ).all()
    return [_hydrate(session, b) for b in rows]


# ═══════════════════════════════════════════════════════════════
# GET /borrowings — staff view (all or filtered by status)
# ═══════════════════════════════════════════════════════════════
@router.get("", response_model=BorrowingListOut)
def list_borrowings(
    session: Annotated[Session, Depends(get_session)],
    _staff: StaffUser,
    status_filter: Optional[str] = Query(default=None, alias="status"),
    user_id: Optional[uuid.UUID] = Query(default=None),
):
    stmt = select(Borrowing)

    if status_filter:
        try:
            st = BorrowStatus(status_filter)
            stmt = stmt.where(Borrowing.status == st)
        except ValueError:
            raise HTTPException(status.HTTP_400_BAD_REQUEST, "Invalid status")

    if user_id:
        stmt = stmt.where(Borrowing.user_id == user_id)

    stmt = stmt.order_by(Borrowing.requested_at.desc())
    rows = session.exec(stmt).all()

    return BorrowingListOut(
        items=[_hydrate(session, b) for b in rows],
        total=len(rows),
    )


# ═══════════════════════════════════════════════════════════════
# POST /borrowings/{id}/approve
# ═══════════════════════════════════════════════════════════════
@router.post("/{borrowing_id}/approve", response_model=BorrowingOut)
def approve(
    borrowing_id: uuid.UUID,
    body: ApproveIn,
    session: Annotated[Session, Depends(get_session)],
    staff: StaffUser,
):
    b = session.get(Borrowing, borrowing_id)
    if not b:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Borrowing not found")
    if b.status != BorrowStatus.pending:
        raise HTTPException(status.HTTP_409_CONFLICT, "Not pending")

    book = session.get(Book, b.book_id)
    if not book or book.deleted_at is not None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Book not found")
    if book.available_copies <= 0:
        raise HTTPException(status.HTTP_409_CONFLICT, "No copies available")

    now = datetime.now(timezone.utc)
    b.status      = BorrowStatus.approved
    b.days        = body.days
    b.approved_at = now
    b.approved_by = staff.id
    b.due_at      = now + timedelta(days=body.days)

    book.available_copies -= 1

    _notify(
        session, b.user_id, NotificationType.approved,
        "Book approved",
        f'"{book.title}" is ready — due in {body.days} days',
        related_id=b.id,
    )

    session.add(b)
    session.add(book)
    session.commit()
    session.refresh(b)
    return _hydrate(session, b)


# ═══════════════════════════════════════════════════════════════
# POST /borrowings/{id}/reject
# ═══════════════════════════════════════════════════════════════
@router.post("/{borrowing_id}/reject", response_model=BorrowingOut)
def reject(
    borrowing_id: uuid.UUID,
    session: Annotated[Session, Depends(get_session)],
    staff: StaffUser,
):
    b = session.get(Borrowing, borrowing_id)
    if not b:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Borrowing not found")
    if b.status != BorrowStatus.pending:
        raise HTTPException(status.HTTP_409_CONFLICT, "Not pending")

    book = session.get(Book, b.book_id)

    b.status      = BorrowStatus.rejected
    b.rejected_at = datetime.now(timezone.utc)
    b.rejected_by = staff.id

    _notify(
        session, b.user_id, NotificationType.rejected,
        "Request declined",
        f'Your request for "{book.title if book else "book"}" was declined',
        related_id=b.id,
    )

    session.add(b)
    session.commit()
    session.refresh(b)
    return _hydrate(session, b)


# ═══════════════════════════════════════════════════════════════
# POST /borrowings/{id}/return
# ═══════════════════════════════════════════════════════════════
@router.post("/{borrowing_id}/return", response_model=BorrowingOut)
def mark_returned(
    borrowing_id: uuid.UUID,
    session: Annotated[Session, Depends(get_session)],
    staff: StaffUser,
):
    b = session.get(Borrowing, borrowing_id)
    if not b:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Borrowing not found")
    if b.status not in (BorrowStatus.approved, BorrowStatus.overdue):
        raise HTTPException(status.HTTP_409_CONFLICT, "Not currently out")

    book = session.get(Book, b.book_id)

    b.status      = BorrowStatus.returned
    b.returned_at = datetime.now(timezone.utc)
    b.received_by = staff.id

    if book:
        book.available_copies = min(book.total_copies, book.available_copies + 1)
        session.add(book)

    _notify(
        session, b.user_id, NotificationType.returned,
        "Book returned",
        f'Thanks for returning "{book.title if book else "book"}"',
        related_id=b.id,
    )

    session.add(b)
    session.commit()
    session.refresh(b)
    return _hydrate(session, b)

# ═══════════════════════════════════════════════════════════════
# POST /borrowings/issue — staff issues a book directly at counter
# ═══════════════════════════════════════════════════════════════
@router.post("/issue", response_model=BorrowingOut,
             status_code=status.HTTP_201_CREATED)
def issue_book(
    body: IssueIn,
    session: Annotated[Session, Depends(get_session)],
    staff: StaffUser,
):
    # 1) find student
    student = session.exec(
        select(User).where(
            (User.student_number == body.student_number) &
            (User.role == UserRole.student)
        )
    ).first()
    if not student:
        raise HTTPException(status.HTTP_404_NOT_FOUND,
                            "Student not found")

    # 2) find book by code
    book = session.exec(
        select(Book).where(
            (Book.book_code == body.book_code) &
            (Book.deleted_at.is_(None))
        )
    ).first()
    if not book:
        raise HTTPException(status.HTTP_404_NOT_FOUND,
                            "Book not found")

    # 3) availability
    if book.available_copies <= 0:
        raise HTTPException(status.HTTP_409_CONFLICT,
                            "No copies available")

    # 4) student has no active loan for this book
    dup = session.exec(
        select(Borrowing).where(
            Borrowing.user_id == student.id,
            Borrowing.book_id == book.id,
            Borrowing.status.in_([BorrowStatus.approved, BorrowStatus.overdue]),
        )
    ).first()
    if dup:
        raise HTTPException(status.HTTP_409_CONFLICT,
                            "Student already has this book")

    # 5) borrow limit
    active = session.exec(
        select(func.count()).select_from(Borrowing).where(
            Borrowing.user_id == student.id,
            Borrowing.status.in_([BorrowStatus.approved, BorrowStatus.overdue]),
        )
    ).one()
    if active >= student.borrow_limit:
        raise HTTPException(status.HTTP_409_CONFLICT,
                            f"Student at borrow limit ({student.borrow_limit})")

    # 6) create active loan directly
    now = datetime.now(timezone.utc)
    b = Borrowing(
        user_id=student.id,
        book_id=book.id,
        status=BorrowStatus.approved,
        days=body.days,
        approved_at=now,
        approved_by=staff.id,
        due_at=now + timedelta(days=body.days),
        notes=body.notes,
    )
    book.available_copies -= 1
    session.add(b)
    session.add(book)
    session.flush()

    # 7) notify student
    _notify(
        session, student.id, NotificationType.approved,
        "Book issued",
        f'"{book.title}" issued to you at the counter — due in {body.days} days',
        related_id=b.id,
    )

    session.commit()
    session.refresh(b)
    return _hydrate(session, b)

