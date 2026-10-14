from collections.abc import Generator

from sqlmodel import Session, SQLModel, create_engine

from app.config import settings

# Sync engine (psycopg3)
engine = create_engine(
    settings.database_url,
    echo=False,
    pool_pre_ping=True,
    future=True,
)


def get_session() -> Generator[Session, None, None]:
    """FastAPI dependency: yields a Session per request."""
    with Session(engine) as session:
        yield session


def init_db() -> None:
    """Create tables from SQLModel metadata (dev only — use Alembic in prod)."""
    SQLModel.metadata.create_all(engine)
