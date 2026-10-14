from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.config import settings
from app.database import engine
from app.routers import auth as auth_router
from app.routers import categories as categories_router
from app.routers import books as books_router
from app.routers import borrowings as borrowings_router
from app.routers import notifications as notifications_router
from app.routers import users as users_router
from app.routers import reports as reports_router
from app.routers import messages as messages_router
from app.routers import ai as ai_router
from sqlmodel import Session, text


app = FastAPI(
    title="DII Digital Library API",
    version="0.1.0",
    docs_url="/docs",
    redoc_url=None,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins_list,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/", tags=["meta"])
def root():
    return {"name": "DII Digital Library API", "version": "0.1.0"}


@app.get("/health", tags=["meta"])
def health():
    with Session(engine) as s:
        s.exec(text("SELECT 1"))
    return {"status": "ok", "database": "reachable"}

app.include_router(auth_router.router)
app.include_router(categories_router.router)
app.include_router(books_router.router)
app.include_router(borrowings_router.router)
app.include_router(notifications_router.router)
app.include_router(users_router.router)
app.include_router(reports_router.router)
app.include_router(messages_router.router)
app.include_router(ai_router.router)
