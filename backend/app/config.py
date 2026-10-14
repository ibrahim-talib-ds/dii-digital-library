from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Reads from .env at the backend/ root."""

    database_url: str
    jwt_secret: str
    access_token_expire_minutes: int = 30
    refresh_token_expire_days: int = 30
    upload_dir: str = "./uploads"
    cors_origins: str = "http://localhost:5050"
    groq_api_key: str = ""

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore",
    )

    @property
    def cors_origins_list(self) -> list[str]:
        return [o.strip() for o in self.cors_origins.split(",") if o.strip()]


settings = Settings()
