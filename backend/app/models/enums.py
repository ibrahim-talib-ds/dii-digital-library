import enum


class UserRole(str, enum.Enum):
    student = "student"
    librarian = "librarian"
    admin = "admin"


class UserStatus(str, enum.Enum):
    active = "active"
    blocked = "blocked"


class BorrowStatus(str, enum.Enum):
    pending = "pending"
    approved = "approved"
    rejected = "rejected"
    returned = "returned"
    overdue = "overdue"
    cancelled = "cancelled"


class NotificationType(str, enum.Enum):
    request = "request"
    approved = "approved"
    rejected = "rejected"
    returned = "returned"
    overdue = "overdue"
    info = "info"
