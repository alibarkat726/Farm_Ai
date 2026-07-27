from functools import lru_cache
from pathlib import Path
import os

from pydantic_settings import BaseSettings, SettingsConfigDict

BASE_DIR = Path(__file__).resolve().parent.parent
KNOWLEDGE_BASE_PATH = BASE_DIR / "data" / "orchard_issues.json"


def _default_database_url() -> str:
    # Vercel serverless filesystem is read-only except /tmp (ephemeral).
    if os.getenv("VERCEL"):
        return "sqlite:////tmp/orchard.db"
    return "sqlite:///./orchard.db"


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=str(BASE_DIR / ".env"),
        env_file_encoding="utf-8",
        extra="ignore",
    )

    openai_api_key: str = ""
    database_url: str = _default_database_url()
    allowed_origins: str = "*"
    openai_model: str = "gpt-4o"
    max_image_bytes: int = 8 * 1024 * 1024  # 8 MB


@lru_cache
def get_settings() -> Settings:
    return Settings()
